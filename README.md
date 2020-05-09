
# htmldf

The package `htmldf` contains a single function `html_df()` which
accepts a vector of urls as an input and from each will attempt to
download each page, extract and parse the html. The result is returned
as a `tibble` where each row corresponds to a document, and the columns
contain page attributes and metadata extracted from the html, including:

  - page title
  - inferred language
  - RSS feeds
  - image links
  - twitter, github and linkedin profiles
  - page size and server

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
z <- html_df(urlx, show_progress = FALSE)
z
```

    ## # A tibble: 3 x 13
    ##   url   title lang  url2  rss   images twitter github linkedin   size server
    ##   <chr> <chr> <chr> <chr> <chr> <list> <list>  <list> <lgl>     <int> <chr> 
    ## 1 http… rOpe… en    http… <NA>  <tibb… <chr [… <chr … NA        22725 cloud…
    ## 2 http… Wiki… es    http… http… <tibb… <lgl [… <lgl … NA       202630 mw127…
    ## 3 http… Juli… en    http… http… <tibb… <lgl [… <lgl … NA        21844 Netli…
    ## # … with 2 more variables: generator <chr>, source <list>

Page titles

``` r
z$title
```

    ## [1] "rOpenSci | rOpenSci's Leadership in #rstats Culture"    
    ## [2] "Wikipedia en español • Wikipedia, la enciclopedia libre"
    ## [3] "Julia Silge"

RSS feeds

``` r
z$rss
```

    ## [1] NA                                                                              
    ## [2] "https://es.wikipedia.org/w/index.php?title=especial:cambiosrecientes&feed=atom"
    ## [3] "https://juliasilge.com/index.xml"

Twitter handles

``` r
z$twitter
```

    ## [[1]]
    ## [1] "@_inundata"   "@ben_d_best"  "@jamiecmonty" "@jcheng"      "@juliesquid" 
    ## [6] "@leafletjs"   "@ropensci"   
    ## 
    ## [[2]]
    ## [1] NA
    ## 
    ## [[3]]
    ## [1] NA

## Comments? Suggestions? Issues?

Any feedback is welcome\! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
