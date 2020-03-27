
# htmldf

The package `htmldf` contains a single function `html_df()` which
accepts a vector of urls as an input and from each will attempt to
download each page, extract and parse the html. The result is returned
as a `tibble` where each row corresponds to a document, and the columns
contain useful page attributes extracted from the html, including:

  - page title
  - language
  - RSS feeds
  - image links
  - twitter, github and linkedin profiles
  - page size

## Installation and usage

To install the package:

``` r
remotes::install_github('alastairrushworth/htmldf)
```

To use `html_df`

``` r
library(htmldf)
urlx <- c("https://ropensci.org/blog/2020/02/21/ropensci-leadership/",
          "https://es.wikipedia.org/wiki/Wikipedia_en_espa%C3%B1ol", 
          "https://juliasilge.com/")
html_df(urlx, show_progress = FALSE)
```

    ## # A tibble: 3 x 11
    ##   url    title  lang  url2   rss    images twitter  github linkedin   size html 
    ##   <chr>  <chr>  <chr> <chr>  <list> <list> <chr>    <chr>  <chr>     <int> <lis>
    ## 1 https… rOpen… en    https… <lgl … <tibb… "https:… ""     ""        23291 <xml…
    ## 2 https… Wikip… es    https… <chr … <tibb… ""       ""     ""       198001 <xml…
    ## 3 https… Julia… en    https… <chr … <tibb… "https:… ""     "https:…  27966 <xml…

## Comments? Suggestions? Issues?

Any feedback is welcome\! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
