
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

-   page title
-   inferred language
-   RSS feeds
-   tables coerced to tibbles, where possible
-   hyperlinks
-   image links
-   social media profiles
-   the inferred programming language of any text with code tags
-   page size, generator and server
-   page accessed date
-   page published or last updated dates

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
          "https://medium.com/dair-ai/pytorch-1-2-introduction-guide-f6fa9bb7597c",
          "https://www.tensorflow.org/tutorials/images/cnn", 
          "https://www.analyticsvidhya.com/blog/2019/09/introduction-to-pytorch-from-scratch/")

# use html_df() to gather data
z <- html_df(urlx, show_progress = FALSE)
z
```

    ## # A tibble: 4 x 16
    ##   url   title lang  url2  links rss   tables images social code_lang   size
    ##   <chr> <chr> <chr> <chr> <lis> <chr> <list> <list> <list>     <dbl>  <int>
    ## 1 http… Visu… en    http… <tib… http… <lgl … <tibb… <tibb…     1      38445
    ## 2 http… A Ge… en    http… <tib… <NA>  <lgl … <tibb… <tibb…    -0.860 228304
    ## 3 http… Conv… en    http… <tib… <NA>  <name… <tibb… <tibb…    -0.936 117802
    ## 4 http… Pyto… en    http… <tib… <NA>  <name… <tibb… <tibb…    -1     191515
    ## # … with 5 more variables: server <chr>, accessed <dttm>, published <dttm>,
    ## #   generator <chr>, source <chr>

To see the page titles, look at the `titles` column.

``` r
z %>% select(title, url2)
```

    ## # A tibble: 4 x 2
    ##   title                                url2                                     
    ##   <chr>                                <chr>                                    
    ## 1 Visualising Tour De France Data In … https://alastairrushworth.github.io/Visu…
    ## 2 A Gentle Introduction to PyTorch 1.… https://medium.com/dair-ai/pytorch-1-2-i…
    ## 3 Convolutional Neural Network (CNN) … https://www.tensorflow.org/tutorials/ima…
    ## 4 Pytorch | Getting Started With Pyto… https://www.analyticsvidhya.com/blog/201…

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
    ## [1] NA
    ## 
    ## [[3]]
    ## [[3]]$uncoercible
    ## [1] "<table class=\"tfo-notebook-buttons\" align=\"left\">\n<td>\n    <a target=\"_blank\" href=\"https://www.tensorflow.org/tutorials/images/cnn\">\n    <img src=\"https://www.tensorflow.org/images/tf_logo_32px.png\">\n    View on TensorFlow.org</a>\n  </td>\n  <td>\n    <a target=\"_blank\" href=\"https://colab.research.google.com/github/tensorflow/docs/blob/master/site/en/tutorials/images/cnn.ipynb\">\n    <img src=\"https://www.tensorflow.org/images/colab_logo_32px.png\">\n    Run in Google Colab</a>\n  </td>\n  <td>\n    <a target=\"_blank\" href=\"https://github.com/tensorflow/docs/blob/master/site/en/tutorials/images/cnn.ipynb\">\n    <img src=\"https://www.tensorflow.org/images/GitHub-Mark-32px.png\">\n    View source on GitHub</a>\n  </td>\n  <td>\n    <a href=\"https://storage.googleapis.com/tensorflow_docs/docs/site/en/tutorials/images/cnn.ipynb\"><img src=\"https://www.tensorflow.org/images/download_logo_32px.png\">Download notebook</a>\n  </td>\n</table>\n"
    ## 
    ## 
    ## [[4]]
    ## [[4]]$`no-caption`
    ## # A tibble: 11 x 2
    ##    X1    X2         
    ##    <chr> <chr>      
    ##  1 Label Description
    ##  2 0     T-shirt/top
    ##  3 1     Trouser    
    ##  4 2     Pullover   
    ##  5 3     Dress      
    ##  6 4     Coat       
    ##  7 5     Sandal     
    ##  8 6     Shirt      
    ##  9 7     Sneaker    
    ## 10 8     Bag        
    ## 11 9     Ankle boot

`html_df()` does its best to find RSS feeds embedded in the page:

``` r
z$rss
```

    ## [1] "https://alastairrushworth.github.io/feed.xml"
    ## [2] NA                                            
    ## [3] NA                                            
    ## [4] NA

`html_df()` will try to parese out any social profiles embedded or
mentioned on the page. Currently, this includes profiles for the sites

-   bitbucket
-   devto
-   facebook
-   github
-   gitlab
-   instagram
-   keybase
-   linkedin
-   mastodon
-   orcid
-   patreon
-   researchgate
-   stackoverflow
-   twitter
-   youtube

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
    ## # A tibble: 3 x 3
    ##   site    handle    profile                     
    ##   <chr>   <chr>     <chr>                       
    ## 1 twitter @dair_ai  https://twitter.com/dair_ai 
    ## 2 twitter @omarsar0 https://twitter.com/omarsar0
    ## 3 github  @omarsar  https://github.com/omarsar  
    ## 
    ## [[3]]
    ## # A tibble: 2 x 3
    ##   site    handle      profile                       
    ##   <chr>   <chr>       <chr>                         
    ## 1 twitter @tensorflow https://twitter.com/tensorflow
    ## 2 github  @tensorflow https://github.com/tensorflow 
    ## 
    ## [[4]]
    ## # A tibble: 4 x 3
    ##   site     handle                  profile                                      
    ##   <chr>    <chr>                   <chr>                                        
    ## 1 twitter  @analyticsvidhya        https://twitter.com/analyticsvidhya          
    ## 2 facebook @analyticsvidhya        https://facebook.com/analyticsvidhya         
    ## 3 linkedin @company/analytics-vid… https://linkedin.com/company/analytics-vidhya
    ## 4 youtube  UCH6gDteHtH4hg3o2343iO… https://youtube.com/channel/UCH6gDteHtH4hg3o…

Code language is inferred from `<code>` chunks using a preditive model.
The `code_lang` column contains a numeric score where values near 1
indicate mostly R code, values near -1 indicate mostly Python code:

``` r
z %>% select(code_lang, url2)
```

    ## # A tibble: 4 x 2
    ##   code_lang url2                                                                
    ##       <dbl> <chr>                                                               
    ## 1     1     https://alastairrushworth.github.io/Visualising-Tour-de-France-data…
    ## 2    -0.860 https://medium.com/dair-ai/pytorch-1-2-introduction-guide-f6fa9bb75…
    ## 3    -0.936 https://www.tensorflow.org/tutorials/images/cnn                     
    ## 4    -1     https://www.analyticsvidhya.com/blog/2019/09/introduction-to-pytorc…

Publication dates

``` r
z %>% select(published, url2)
```

    ## # A tibble: 4 x 2
    ##   published           url2                                                      
    ##   <dttm>              <chr>                                                     
    ## 1 2019-11-24 00:00:00 https://alastairrushworth.github.io/Visualising-Tour-de-F…
    ## 2 2019-09-01 18:03:22 https://medium.com/dair-ai/pytorch-1-2-introduction-guide…
    ## 3 NA                  https://www.tensorflow.org/tutorials/images/cnn           
    ## 4 2019-09-17 03:09:28 https://www.analyticsvidhya.com/blog/2019/09/introduction…

## Comments? Suggestions? Issues?

Any feedback is welcome! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
