## Updating Packagedown Documentation 

Use these steps to initialize pkgdown, build the website documents, and push to GitHub main/doc (not the "git-pages" branch that is the default in pkgdown). 

1. Initialize Package in R - https://usethis.r-lib.org/reference/use_github_pages.html 

```
library(usethis)
path <- file.path(tempdir(), "mypkg")
create_package(path)
```

2. Initialize pkgdown in R https://pkgdown.r-lib.org/articles/pkgdown.html#configuration

```
# Run once to configure package to use pkgdown
usethis::use_pkgdown()
# Run to build the website
pkgdown::build_site()
```



2.1 Some small checks 

- Make sure "^docs$" is **IN** the .Rbuildignore

- Make sure "docs/" is **NOT IN** .gitignore

- Add "destination: docs" to line 2 of _pkgdown.yml in main directory. 




Do not use `usethis::use_pkgdown_github_pages()`. We do not want their defaults so we will do it manually. 


DO NOT PUSH TO GITHUB YET

3. Open repo on Github.com. Go to Settings> Pages > Build and Deployment. Under Branch, choose "main" then "/docs"

<img width="747" alt="Screenshot 2024-02-21 at 12 38 47 PM" src="https://github.com/Nonprofit-Open-Data-Collective/governance/assets/55454718/0a1d523e-fc52-40e4-818f-d654f7abc236">

<br>

At this point, when you push to GitHub, the site is active at username.github.io/packagename ( you can see the link in the settings>pages page), but the link is not active on your main github.com/username/packagename site. To do that, open the website github.com/username/packagename, on the "About" section click the gear icon, then check the "Use your GitHub Pages website" box. Once you hit save, the package site link will appear on the repo main page. 

<img width="627" alt="Screenshot 2024-02-21 at 3 21 00 PM" src="https://github.com/Nonprofit-Open-Data-Collective/governance/assets/55454718/478bf7c3-07c1-450f-a93e-3d7daa957407">

<br>

This should be all you need to do initialize the GitHub pages website. 

Every time you update the functions in the  package:

- Update documentation with `devtools::document()` (and do any other devtools updates you need to do)
- Check package 
- `devtools::document()`
- Build package 
- Run `devtools::install()`
- Update website with `pkgdown::build_site()`
- Push - After you push to GitHub, there will be an action to update the website, it will take a few minutes. 

See section 4.1. of <https://fanwangecon.github.io/R4Econ/support/development/fs_packaging.pdf> for details.

To add the correct citation to the pkgdown site, 
- Run `usethis::use_citation()`. This will create a new file inst/CITATION.
- Fill in the blanks with appropriate information. See `utils::bibentry` for details.
- If CITATION.cff is in the main directory to be used as the package citation in the R documentation, you can just add the inst/ directory to the .Rbuildingnore.
- Once you run `pkgdown::build_site()` from above, it should add the correct citation on the citation page of the website. 
