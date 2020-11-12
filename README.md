
# htmldf <img src="man/figures/hex.png" align="right" width="150" />

[![Build
Status](https://travis-ci.org/alastairrushworth/htmldf.svg?branch=master)](https://travis-ci.org/alastairrushworth/htmldf)
[![codecov](https://codecov.io/gh/alastairrushworth/htmldf/branch/master/graph/badge.svg)](https://codecov.io/gh/alastairrushworth/htmldf)
[![CRAN
status](https://www.r-pkg.org/badges/version/htmldf)](https://cran.r-project.org/package=htmldf)
[![](https://cranlogs.r-pkg.org/badges/htmldf)](https://cran.r-project.org/package=htmldf)
[![cran
checks](https://cranchecks.info/badges/summary/htmldf)](https://cran.r-project.org/web/checks/check_results_htmldf.html)

## Overview

The package `htmldf` contains a single function `html_df()` which
accepts a vector of urls as an input and from each will attempt to
download each page, extract and parse the html. The result is returned
as a `tibble` where each row corresponds to a document, and the columns
contain page attributes and metadata extracted from the html, including:

  - page title
  - inferred language
  - RSS feeds
  - tables coerced to tibbles, where possible
  - hyperlinks
  - image links
  - social media profiles
  - the inferred programming language of any text with code tags
  - page size, generator and server
  - page accessed date
  - page published or last updated dates

## Installation

To install the CRAN version of the package:

``` r
install.packages('htmldf')
```

To install the development version of the package:

``` r
remotes::install_github('alastairrushworth/htmldf')
```

## Usage

First define a vector of URLs you want to gather information from. The
function `html_df()` returns a `tibble` where each row corresponds to a
webpage, and each column corresponds to an attribute of that webpage:

``` r
library(htmldf)
library(dplyr)

# An example vector of URLs to fetch data for
urlx <- c("https://alastairrushworth.github.io/Visualising-Tour-de-France-data-in-R/",
          "https://www.tensorflow.org/tutorials/images/cnn", 
          "https://www.robertmylesmcdonnell.com/content/posts/mtcars/")

# use html_df() to gather data
z <- html_df(urlx, show_progress = FALSE)
z
```

    ## # A tibble: 3 x 16
    ##   url   title lang  url2  links rss   tables images social code_lang   size
    ##   <chr> <chr> <chr> <chr> <lis> <chr> <list> <list> <list>     <dbl>  <int>
    ## 1 http… Visu… en    http… <tib… http… <lgl … <tibb… <tibb…     1      38445
    ## 2 http… Conv… en    http… <tib… <NA>  <name… <tibb… <tibb…    -0.936 114238
    ## 3 http… Robe… en    http… <tib… <NA>  <name… <tibb… <tibb…     1     291099
    ## # … with 5 more variables: server <chr>, accessed <dttm>, published <dttm>,
    ## #   generator <chr>, source <chr>

To see the page titles, look at the `titles` column.

``` r
z %>% select(title, url2)
```

    ## # A tibble: 3 x 2
    ##   title                              url2                                       
    ##   <chr>                              <chr>                                      
    ## 1 Visualising Tour De France Data I… https://alastairrushworth.github.io/Visual…
    ## 2 Convolutional Neural Network (CNN… https://www.tensorflow.org/tutorials/image…
    ## 3 Robert Myles McDonnell             https://www.robertmylesmcdonnell.com/conte…

Where there are tables embedded on a page in the `<table>` tag, these
will be gathered into the list column `tables`. `html_df` will attempt
to coerce each table to `tibble` - where that isn’t possible, the raw
html is returned instead.

``` r
z$tables
```

    ## [[1]]
    ## [1] NA
    ## 
    ## [[2]]
    ## [[2]]$uncoercible
    ## [1] "<table class=\"tfo-notebook-buttons\" align=\"left\">\n<td>\n    <a target=\"_blank\" href=\"https://www.tensorflow.org/tutorials/images/cnn\">\n    <img src=\"https://www.tensorflow.org/images/tf_logo_32px.png\">\n    View on TensorFlow.org</a>\n  </td>\n  <td>\n    <a target=\"_blank\" href=\"https://colab.research.google.com/github/tensorflow/docs/blob/master/site/en/tutorials/images/cnn.ipynb\">\n    <img src=\"https://www.tensorflow.org/images/colab_logo_32px.png\">\n    Run in Google Colab</a>\n  </td>\n  <td>\n    <a target=\"_blank\" href=\"https://github.com/tensorflow/docs/blob/master/site/en/tutorials/images/cnn.ipynb\">\n    <img src=\"https://www.tensorflow.org/images/GitHub-Mark-32px.png\">\n    View source on GitHub</a>\n  </td>\n  <td>\n    <a href=\"https://storage.googleapis.com/tensorflow_docs/docs/site/en/tutorials/images/cnn.ipynb\"><img src=\"https://www.tensorflow.org/images/download_logo_32px.png\">Download notebook</a>\n  </td>\n</table>\n"
    ## 
    ## 
    ## [[3]]
    ## [[3]]$`no-caption`
    ## # A tibble: 32 x 2
    ##    model             car  
    ##    <chr>             <lgl>
    ##  1 Mazda RX4         NA   
    ##  2 Mazda RX4 Wag     NA   
    ##  3 Datsun 710        NA   
    ##  4 Hornet 4 Drive    NA   
    ##  5 Hornet Sportabout NA   
    ##  6 Valiant           NA   
    ##  7 Duster 360        NA   
    ##  8 Merc 240D         NA   
    ##  9 Merc 230          NA   
    ## 10 Merc 280          NA   
    ## # … with 22 more rows

`html_df` does its best to find RSS feeds embedded in the page:

``` r
z$rss
```

    ## [1] "https://alastairrushworth.github.io/feed.xml"
    ## [2] NA                                            
    ## [3] NA

Social profiles embedded on the page. At present, Twitter, Facebook and
Linkedin are extracted.

``` r
z$social
```

    ## [[1]]
    ## # A tibble: 3 x 3
    ##   site     handle                     profile                                   
    ##   <chr>    <chr>                      <chr>                                     
    ## 1 twitter  @rushworth_a               https://twitter.com/rushworth_a           
    ## 2 github   @alastairrushworth         https://github.com/alastairrushworth      
    ## 3 linkedin @in/alastair-rushworth-25… https://linkedin.com/in/alastair-rushwort…
    ## 
    ## [[2]]
    ## # A tibble: 2 x 3
    ##   site    handle      profile                       
    ##   <chr>   <chr>       <chr>                         
    ## 1 twitter @tensorflow https://twitter.com/tensorflow
    ## 2 github  @tensorflow https://github.com/tensorflow 
    ## 
    ## [[3]]
    ## # A tibble: 5 x 3
    ##   site     handle                     profile                                   
    ##   <chr>    <chr>                      <chr>                                     
    ## 1 twitter  @robertmylesmc             https://twitter.com/robertmylesmc         
    ## 2 github   @coolbutuseless            https://github.com/coolbutuseless         
    ## 3 github   @robertmyles               https://github.com/robertmyles            
    ## 4 github   @wilkelab                  https://github.com/wilkelab               
    ## 5 linkedin @in/robert-mcdonnell-7475… https://linkedin.com/in/robert-mcdonnell-…

Code language is inferred from `<code>` chunks using simple machine
learning. The `code_lang` column contains score where values near 1
indicate mostly R code, values near -1 indicate mostly Python code:

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
