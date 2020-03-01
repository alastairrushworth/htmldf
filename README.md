
# htmldf

From a vector of urls, `htmldf::html_df()` will attempt to fetch the
html, get the page title and the language, returning the result as a
dataframe.

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

    ## # A tibble: 2 x 6
    ##   url                 title               lang  url2               page   html  
    ##   <chr>               <chr>               <chr> <chr>              <list> <list>
    ## 1 https://ropensci.o… rOpenSci | rOpenSc… en    https://ropensci.… <resp… <xml_…
    ## 2 https://es.wikiped… Wikipedia en españ… es    https://es.wikipe… <resp… <xml_…
