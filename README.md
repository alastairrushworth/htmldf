
# htmldf

From a vector of urls, `htmldf::html_df()` will attempt to fetch the
html, page title, language, image urls and social tags returning the
result as a dataframe.

To install the package:

``` r
remotes::install_github('alastairrushworth/htmldf)
```

To get summaries of two webpages:

``` r
library(htmldf)
urlx <- c("https://ropensci.org/blog/2020/02/21/ropensci-leadership/",
           "https://es.wikipedia.org/wiki/Wikipedia_en_espa%C3%B1ol")
html_df(urlx)
```

    ## # A tibble: 2 x 10
    ##   url      title   lang  url2     images twitter   github   linkedin page  html 
    ##   <chr>    <chr>   <chr> <chr>    <list> <chr>     <chr>    <chr>    <lis> <lis>
    ## 1 https:/… rOpenS… en    https:/… <tibb… "https:/… "https:… ""       <res… <xml…
    ## 2 https:/… Wikipe… es    https:/… <tibb… ""        ""       ""       <res… <xml…
