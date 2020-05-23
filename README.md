
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
  - page size, generator and server
  - page accessed date
  - page published or last updated dates

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
    ##   url   title lang  url2  rss   images social   size server accessed           
    ##   <chr> <chr> <chr> <chr> <chr> <list> <list>  <int> <chr>  <dttm>             
    ## 1 http… rOpe… en    http… <NA>  <tibb… <tibb…  22725 cloud… 2020-05-23 10:17:16
    ## 2 http… Wiki… es    http… http… <tibb… <tibb… 209260 mw136… 2020-05-23 05:30:24
    ## 3 http… Juli… en    http… http… <tibb… <tibb…  21497 Netli… 2020-05-21 23:04:03
    ## # … with 3 more variables: published <dttm>, generator <chr>, source <list>

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

Social profiles

``` r
z$social
```

    ## [[1]]
    ## # A tibble: 9 x 3
    ##   site    handle        profile                        
    ##   <chr>   <chr>         <chr>                          
    ## 1 twitter @_inundata    https://twitter.com/_inundata  
    ## 2 twitter @ben_d_best   https://twitter.com/ben_d_best 
    ## 3 twitter @jamiecmonty  https://twitter.com/jamiecmonty
    ## 4 twitter @jcheng       https://twitter.com/jcheng     
    ## 5 twitter @juliesquid   https://twitter.com/juliesquid 
    ## 6 twitter @leafletjs    https://twitter.com/leafletjs  
    ## 7 twitter @ropensci     https://twitter.com/ropensci   
    ## 8 github  @ropensci     https://github.com/ropensci    
    ## 9 github  @ropenscilabs https://github.com/ropenscilabs
    ## 
    ## [[2]]
    ## # A tibble: 0 x 3
    ## # … with 3 variables: site <chr>, handle <chr>, profile <chr>
    ## 
    ## [[3]]
    ## # A tibble: 0 x 3
    ## # … with 3 variables: site <chr>, handle <chr>, profile <chr>

## Comments? Suggestions? Issues?

Any feedback is welcome\! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
