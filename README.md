
[![Build
Status](https://travis-ci.org/alastairrushworth/htmldf.svg?branch=master)](https://travis-ci.org/alastairrushworth/htmldf)
[![codecov](https://codecov.io/gh/alastairrushworth/htmldf/branch/master/graph/badge.svg)](https://codecov.io/gh/alastairrushworth/htmldf)

# htmldf

The package `htmldf` contains a single function `html_df()` which
accepts a vector of urls as an input and from each will attempt to
download each page, extract and parse the html. The result is returned
as a `tibble` where each row corresponds to a document, and the columns
contain page attributes and metadata extracted from the html, including:

  - page title
  - inferred language
  - RSS feeds
  - hyperlinks
  - image links
  - twitter, github and linkedin profiles
  - the inferred programming language of any text with code tags
  - page size, generator and server
  - page accessed date
  - page published or last updated dates

## Installation and usage

To install the package:

``` r
remotes::install_github('alastairrushworth/htmldf')
```

To use `html_df`

``` r
library(htmldf)
library(dplyr)
```

    ## Warning: package 'dplyr' was built under R version 4.0.2

``` r
urlx <- c("https://alastairrushworth.github.io/Visualising-Tour-de-France-data-in-R/",
          "https://www.tensorflow.org/tutorials/images/cnn", 
          "https://www.robertmylesmcdonnell.com/content/posts/mtcars/")
z <- html_df(urlx, show_progress = FALSE)
z
```

    ## # A tibble: 3 x 15
    ##   url   title lang  url2  links rss   images social code_lang   size server
    ##   <chr> <chr> <chr> <chr> <lis> <chr> <list> <list>     <dbl>  <int> <chr> 
    ## 1 http… Visu… en    http… <tib… http… <tibb… <tibb…     1      38445 GitHu…
    ## 2 http… Conv… en    http… <tib… <NA>  <tibb… <tibb…    -0.936 110231 Googl…
    ## 3 http… Robe… en    http… <tib… <NA>  <tibb… <tibb…     1     291099 Netli…
    ## # … with 4 more variables: accessed <dttm>, published <dttm>, generator <chr>,
    ## #   source <chr>

Page titles

``` r
z %>% select(title, url2)
```

    ## # A tibble: 3 x 2
    ##   title                              url2                                       
    ##   <chr>                              <chr>                                      
    ## 1 Visualising Tour De France Data I… https://alastairrushworth.github.io/Visual…
    ## 2 Convolutional Neural Network (CNN… https://www.tensorflow.org/tutorials/image…
    ## 3 Robert Myles McDonnell             https://www.robertmylesmcdonnell.com/conte…

RSS feeds

``` r
z$rss
```

    ## [1] "https://alastairrushworth.github.io/feed.xml"
    ## [2] NA                                            
    ## [3] NA

Social profiles

``` r
z$social
```

    ## [[1]]
    ## # A tibble: 3 x 3
    ##   site     handle                    profile                                    
    ##   <chr>    <chr>                     <chr>                                      
    ## 1 twitter  @rushworth_a              https://twitter.com/rushworth_a            
    ## 2 linkedin @alastair-rushworth-2531… https://linkedin.com/in/alastair-rushworth…
    ## 3 github   @alastairrushworth        https://github.com/alastairrushworth       
    ## 
    ## [[2]]
    ## # A tibble: 1 x 3
    ##   site    handle      profile                       
    ##   <chr>   <chr>       <chr>                         
    ## 1 twitter @tensorflow https://twitter.com/tensorflow
    ## 
    ## [[3]]
    ## # A tibble: 4 x 3
    ##   site     handle                   profile                                     
    ##   <chr>    <chr>                    <chr>                                       
    ## 1 twitter  @robertmylesmc           https://twitter.com/robertmylesmc           
    ## 2 linkedin @robert-mcdonnell-7475b… https://linkedin.com/in/robert-mcdonnell-74…
    ## 3 github   @coolbutuseless          https://github.com/coolbutuseless           
    ## 4 github   @robertmyles             https://github.com/robertmyles

Inferred code language (near 1 = R; near -1 = Python)

``` r
z %>% select(code_lang, url2)
```

    ## # A tibble: 3 x 2
    ##   code_lang url2                                                                
    ##       <dbl> <chr>                                                               
    ## 1     1     https://alastairrushworth.github.io/Visualising-Tour-de-France-data…
    ## 2    -0.936 https://www.tensorflow.org/tutorials/images/cnn                     
    ## 3     1     https://www.robertmylesmcdonnell.com/content/posts/mtcars/

## Comments? Suggestions? Issues?

Any feedback is welcome\! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
