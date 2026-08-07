# Governance Package — Normalization & Index Plan

**Goal:** Focus the `governance` package on **normalizing 990 governance fields
and creating the governance index for a given sample**. Table retrieval from the
NCCS S3 archive is being built separately and is treated here as an **external,
already-solved dependency**.

**Scope partition:**

| Concern | Owner | Status here |
| --- | --- | --- |
| Download / manage efile tables from S3 | Separate retrieval package (in progress) | **Out of scope** — assume done. Define only the input contract. |
| Normalize raw fields → binary features | `governance::get_features` | **In scope** |
| Create the index (factor scores) for a sample | `governance::get_scores` | **In scope** |
| Docs / tutorials / website | this repo | **In scope**, reframed around "given a sample" |

We still pull live test files during development to confirm variable names and
value formats have not drifted (they have — see findings).

---

## Input contract (the partition boundary)

`get_features()` consumes a data.frame of **one row per filing** that the
retrieval layer produces. Verified against a live v2.1 sample
(`efile_v2_1`, 2022, 3,000 rows). What the retrieval layer must deliver:

- **Identifiers:** `ORG_EIN` (9-digit numeric string, e.g. `432031361`).
  Note v2.1 now also ships a pre-formatted `EIN2` (`EIN-43-2031361`) — decide
  which is the canonical key.
- **Join keys drifted:** version column is now **`VERSION`** (was
  `RETURN_VERSION` in old scratch); year is **`TAX_YEAR`**. `RETURN_TYPE`
  present (used to drop `990EZ`).
- **Required raw fields** (unchanged names, all present in v2.1):
  - Part IV: `F9_04_AFS_IND_X`, `F9_04_BIZ_TRANSAC_DTK_X`,
    `F9_04_BIZ_TRANSAC_DTK_FAM_X`, `F9_04_BIZ_TRANSAC_DTK_ENTITY_X`,
    `F9_04_CONTR_NONCSH_MT_25K_X`, `F9_04_CONTR_ART_HIST_X`
  - Part VI: `F9_06_GVRN_NUM_VOTING_MEMB`, `F9_06_GVRN_NUM_VOTING_MEMB_IND`,
    `F9_06_GVRN_DTK_FAMBIZ_RELATION_X`, `F9_06_GVRN_DELEGATE_MGMT_DUTY_X`,
    `F9_06_GVRN_DOC_GVRN_BODY_X`, `F9_06_POLICY_FORM990_GVRN_BODY_X`,
    `F9_06_POLICY_COI_X`, `F9_06_POLICY_COI_DISCLOSURE_X`,
    `F9_06_POLICY_COI_MONITOR_X`, `F9_06_POLICY_WHSTLBLWR_X`,
    `F9_06_POLICY_DOC_RETENTION_X`, `F9_06_POLICY_COMP_PROCESS_CEO_X`,
    `F9_06_DISCLOSURE_AVBL_OTH_X`, `F9_06_DISCLOSURE_AVBL_OTH_WEB_X`,
    `F9_06_DISCLOSURE_AVBL_REQUEST_X`, `F9_06_DISCLOSURE_AVBL_OWN_WEB_X`
  - Part XII: `F9_12_FINSTAT_METHOD_ACC_ACCRU_X`,
    `F9_12_FINSTAT_METHOD_ACC_CASH_X`, `F9_12_FINSTAT_METHOD_ACC_OTH`
    (+ new `F9_12_FINSTAT_METHOD_ACC_OTH_X` flag — see bug below)
  - Schedule M: `SM_01_REVIEW_PROCESS_UNUSUAL_X`
- **Value formats vary and must be handled robustly** (confirmed):
  - Boolean fields mix `{"true","false","1","0",""}` **within the same column**.
  - Flag fields are `{"X",""}`.
  - Empty is `""` (from `fread`), **not `NA`** — this breaks current code.
  - Count fields are integer strings (`"20"`, `"0"`).

Deliverable: encode this as a documented validator so a bad sample fails loudly
with the *correct* missing/way-off columns named.

---

## Phase A — Normalization (`get_features`) hardening

The current [R/get-features.R](R/get-features.R) works on the bundled
`dat_example` but is brittle against freshly-retrieved tables. Fixes
(**DONE — verified: no regression except the intended missing→0 change; NA- and
""-encoded inputs now produce identical features**):

- [x] **BUG — Part XII "other" misclassification (confirmed on live data).**
  `!is.na(F9_12_FINSTAT_METHOD_ACC_OTH) ~ "other"` fired for everyone because the
  field is `""` not `NA` in ~99.7% of `fread` rows → `P12_LINE_1` collapsed to 0
  for all. Fixed: detect "other" as non-blank **and** non-NA, with accrual as the
  primary signal (`ACCRU_X == "X" → 1`, cash/other → 0, none reported → NA).
  Recovers the correct 138/57/5 split on `""`-encoded data.
- [x] **BUG — copy-paste in missing-column checks.** The Part IV/VI/XII checks
  reported from `cols_partM$old`; now each reports its own columns.
- [x] **Robust boolean coercion.** NA-safe mapping in Part IV (`case_when` else →
  `"no"`) and Part VI (`!is.na(.) & …`) so blank/missing → 0 **regardless of
  whether blanks are NA or ""**. Missing→0 is now deterministic, not an accident
  of `ifelse`.
- [x] **EIN handling.** Added internal `.pad_ein()` (strips non-digits, pads to 9)
  replacing `sprintf("%0*d", 9, as.numeric(ORG_EIN))`; accepts integer/character
  EINs and `EIN2`-style strings.
- [x] **Member counts coerced** with `as.numeric()` before the independence ratio,
  so character input from `fread` no longer errors.
- [x] **Doc/code mismatch.** Removed `F9_04_AFS_CONSOL_X` (never used) from the
  `@details` required list.
- [x] **Derived-feature logic kept intact** (P4_LINE_28 OR-collapse,
  P6_LINE_12/13/14 composite, P6_LINE_18 own-website precedence, P4_29_30 + Sched
  M interaction) — confirmed byte-identical output on `dat_example` apart from the
  2 intended `P6_LINE_15A` cells.

**Residual NAs (by design):** `P6_LINE_1` (independence ratio, undefined when
member counts are 0/missing) and `P12_LINE_1` (no accounting method reported) can
still be NA — these are genuinely unknowable, distinct from a blank policy field,
and are left for `get_scores` to impute. Roxygen `@details` should document this.

## Phase B — Index creation (`get_scores`) for a sample  (**DONE**)

- [x] **Dependencies:** moved `psych` to `Imports` (runtime `psych::factor.scores`).
  `Matrix` stays in `Suggests` — it's used only in the methodology vignette, not
  in `R/` (verified). `data.table`/`purrr`/`stringr` appear only in comments →
  not added.
- [x] **All-NA guard:** `get_scores` now stops with a named-column message when a
  feature is entirely NA (would have caught the P12 bug). Tested.
- [x] **Reproducibility:** confirmed scores from the stored `model6`/`rho2` are
  identical across runs on a fixed sample. (Expected-output fixture → Phase C.)
- [x] Both scoring paths (`factor.scores` vs by-hand) left intact.
- [x] **Packaging hygiene:** fixed DESCRIPTION typos ("Goveranace"/"Inistitue"),
  bumped `RoxygenNote` 7.2.3 → 7.3.3, regenerated `NAMESPACE` + `man/`.
- [x] Moved build-breaking `R/get-efile.R` → `data-raw/get-efile-scratch.R`
  (see below). Output columns are `V1`–`V6` + `total.score` (generic factor
  names — optional rename to meaningful labels is a later polish).

## Phase C — Canonical worked sample (test fixture + example)  (**DONE**)

- [x] **Rebuilt `dat_example` from v2.1** (tax year 2022, 5,000 orgs) via a
  one-off S3 pull → `data-raw/make-dat-example.R` (clean provenance replacing the
  broken v2 scratch). The shipped example now carries genuine current formats
  (`""` blanks, `"X"` flags, mixed `true`/`false`/`1`/`0`, character `ORG_EIN`).
- [x] **Proven fix on real data:** `P12_LINE_1` resolves to 2,957 accrual of 4,896
  (≈60%) on the new `""`-encoded example — the old code would have produced 0.
- [x] **`tests/testthat/` (edition 3), 15 tests passing:** 12-binary-feature
  shape; all-1 fixture; **P12 accrual regression** (accrual/cash/other);
  **NA-vs-`""` parity**; EIN normalization (`"EIN-.."` and integer → 9-digit);
  correct missing-column error; scores shape/reproducibility; all-NA guard.
- [x] **Bonus bug fixed:** the output `ORG_EIN` normalization (and the original
  `sprintf`) was dead code — it was computed on a column that gets dropped, so
  the returned EIN came straight from the input. Now `.pad_ein` is applied to the
  returned identifier (idempotent on already-clean 9-digit EINs).
- [x] Updated `R/data.R` `dat_example` docs; regenerated `man/`.

Note: an expected-scores fixture (golden file) was left out deliberately — the
scores depend on the stored `model6`, so a golden file would just restate the
model; the reproducibility test covers regressions there.

## Phase D — Docs / tutorials / website  (**DONE**)

- [x] `governance.Rmd` (Getting Started) — reframed around the two-step workflow
  and the panel990 retrieval package; self-contained, uses the bundled 2022
  example. Knits network-free.
- [x] `governance-workflow.Rmd` — reframed; added a feature-pass-rate chart and a
  score histogram; the BMF join is now an illustrative (non-evaluated) snippet on
  the unified BMF, so the build needs no network.
- [x] `download-data.Rmd` — rewritten around the **input contract** + panel990;
  clean field table; v2.1 endpoint/columns; download code shown but not run
  (mirrors `make-dat-example.R`).
- [x] `README.md`, `NEWS.md`, `_pkgdown.yml` (`reference:` grouping added),
  DESCRIPTION Suggests for vignette deps.
- [x] Rebuilt the pkgdown site (`lazy=TRUE` — the download-heavy
  `making-gov-scores` article is reused, not re-knit).
- [x] `.Rbuildignore`: excluded `PLAN.md` and `data-raw/` from the package tarball.

### Methodology vignette migrated to offline build (Option 2) — **DONE**

- [x] `making-gov-scores.Rmd`: the four table-download chunks are now
  `eval=FALSE` (kept as provenance, with a pointer to `vignette("download-data")`
  for current v2.1 retrieval). A new chunk loads the committed
  `data-raw/dat-train-raw.rda`, so the whole article builds **offline** — the
  wrangling, `polycor::hetcor`, and `psych::fa` steps run on the saved 2018
  training data. Verified: renders in ~38s with no network; full `pkgdown`
  site rebuilds clean.
- Note: `polycor` and `ggcorrplot` were missing from the local library and were
  installed; both are declared in `Suggests`.

**Still deferred (flagged, not done):**
- `inst/` is excluded by `.Rbuildignore` (`^inst$`), which drops `inst/CITATION`
  from the built package — pre-existing, worth revisiting.
- Release version left at `0.0.0.9000` (a release bump is a maintainer decision).
- `PLAN.md` (this file) renders to `PLAN.html` on a full `pkgdown` rebuild even
  though it is in `.Rbuildignore`; drop `docs/PLAN.html` or relocate this file if
  it should stay off the public site.

---

## Deferred / out of scope (retrieval package)

Not built here; the earlier draft ingestion (`get_efile_table`,
`get_governance_data`, `format_ein`, S3 URL handling) belongs to the separate
retrieval package. The build-breaking `R/get-efile.R` scratch (top-level
`cat()`/bare URLs would fail `R CMD build`) has been **moved to
`data-raw/get-efile-scratch.R`** — preserved but out of the build. When the
retrieval package lands, revisit whether `governance` should re-export a thin
`get_governance_scores(sample)` convenience wrapper.

---

## Open questions

1. **Canonical key:** standardize on numeric `ORG_EIN` or pre-formatted `EIN2`?
2. **Missing-value policy:** should `""`/`NA` on a policy field score as 0
   ("no policy") — the current implicit behavior — or propagate `NA` so
   `get_scores` imputes? This changes scores for filers with sparse Part VI.
3. **Version pinning:** default sample/example built on `efile_v2_1`, 2022 — is
   that the reference vintage the team wants for the shipped fixtures?
