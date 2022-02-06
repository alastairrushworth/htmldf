
# htmldf <img src="man/figures/hex.png" align="right" width="150" />

[![codecov](https://codecov.io/gh/alastairrushworth/htmldf/branch/master/graph/badge.svg)](https://app.codecov.io/gh/alastairrushworth/htmldf)
[![CRAN
status](https://www.r-pkg.org/badges/version/htmldf)](https://CRAN.R-project.org/package=htmldf)
[![](https://cranlogs.r-pkg.org/badges/htmldf)](https://CRAN.R-project.org/package=htmldf)
[![cran
checks](https://cranchecks.info/badges/summary/htmldf)](https://cran.r-project.org/web/checks/check_results_htmldf.html)

## Overview

The package `htmldf` contains a single function `html_df()` which
accepts a vector of urls as an input and from each will attempt to
download each page, extract and parse the html. The result is returned
as a `tibble` where each row corresponds to a document, and the columns
contain page attributes and metadata extracted from the html, including:

-   page title
-   inferred language (uses Google’s compact language detector)
-   RSS feeds
-   tables coerced to tibbles, where possible
-   hyperlinks
-   image links
-   social media profiles
-   the inferred programming language of any text with code tags
-   page size, generator and server
-   page accessed date
-   page published or last updated dates
-   HTTP status code
-   full page source html

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

# have a quick look at the first page
glimpse(z[1, ])
```

    ## Rows: 1
    ## Columns: 17
    ## $ url       <chr> "https://alastairrushworth.github.io/Visualising-Tour-de-Fra…
    ## $ title     <chr> "Visualising Tour De France Data In R -"
    ## $ lang      <chr> "en"
    ## $ url2      <chr> "https://alastairrushworth.github.io/Visualising-Tour-de-Fra…
    ## $ links     <list> [<tbl_df[27 x 2]>]
    ## $ rss       <chr> "https://alastairrushworth.github.io/feed.xml"
    ## $ tables    <list> NA
    ## $ images    <list> [<tbl_df[8 x 3]>]
    ## $ social    <list> [<tbl_df[3 x 3]>]
    ## $ code_lang <dbl> 1
    ## $ size      <int> 38445
    ## $ server    <chr> "GitHub.com"
    ## $ accessed  <dttm> 2022-02-06 17:20:06
    ## $ published <dttm> 2019-11-24
    ## $ generator <chr> NA
    ## $ status    <int> 200
    ## $ source    <chr> "<!DOCTYPE html>\n<!--\n  Minimal Mistakes Jekyll Theme 4.4.…

To see the page titles, look at the `titles` column.

``` r
z %>% select(title, url2)
```

    ## # A tibble: 4 × 2
    ##   title                                                              url2       
    ##   <chr>                                                              <chr>      
    ## 1 Visualising Tour De France Data In R -                             https://al…
    ## 2 A Gentle Introduction to PyTorch 1.2 | by elvis | DAIR.AI | Medium https://me…
    ## 3 Convolutional Neural Network (CNN)  |  TensorFlow Core             https://ww…
    ## 4 Pytorch | Getting Started With Pytorch                             https://ww…

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
    ## [[3]]$`no-caption`
    ## # A tibble: 0 × 0
    ## 
    ## 
    ## [[4]]
    ## [[4]]$`no-caption`
    ## # A tibble: 11 × 2
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

`html_df()` will try to parse out any social profiles embedded or
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
    ## # A tibble: 3 × 3
    ##   site     handle                           profile                             
    ##   <chr>    <chr>                            <chr>                               
    ## 1 twitter  @rushworth_a                     https://twitter.com/rushworth_a     
    ## 2 github   @alastairrushworth               https://github.com/alastairrushworth
    ## 3 linkedin @in/alastair-rushworth-253137143 https://linkedin.com/in/alastair-ru…
    ## 
    ## [[2]]
    ## # A tibble: 3 × 3
    ##   site    handle    profile                     
    ##   <chr>   <chr>     <chr>                       
    ## 1 twitter @dair_ai  https://twitter.com/dair_ai 
    ## 2 twitter @omarsar0 https://twitter.com/omarsar0
    ## 3 github  @omarsar  https://github.com/omarsar  
    ## 
    ## [[3]]
    ## # A tibble: 2 × 3
    ##   site    handle      profile                       
    ##   <chr>   <chr>       <chr>                         
    ## 1 twitter @tensorflow https://twitter.com/tensorflow
    ## 2 github  @tensorflow https://github.com/tensorflow 
    ## 
    ## [[4]]
    ## # A tibble: 4 × 3
    ##   site     handle                    profile                                    
    ##   <chr>    <chr>                     <chr>                                      
    ## 1 twitter  @analyticsvidhya          https://twitter.com/analyticsvidhya        
    ## 2 facebook @analyticsvidhya          https://facebook.com/analyticsvidhya       
    ## 3 linkedin @company/analytics-vidhya https://linkedin.com/company/analytics-vid…
    ## 4 youtube  UCH6gDteHtH4hg3o2343iObA  https://youtube.com/channel/UCH6gDteHtH4hg…

Code language is inferred from `<code>` chunks using a preditive model.
The `code_lang` column contains a numeric score where values near 1
indicate mostly R code, values near -1 indicate mostly Python code:

``` r
z %>% select(code_lang, url2)
```

    ## # A tibble: 4 × 2
    ##   code_lang url2                                                                
    ##       <dbl> <chr>                                                               
    ## 1     1     https://alastairrushworth.github.io/Visualising-Tour-de-France-data…
    ## 2    -0.860 https://medium.com/dair-ai/pytorch-1-2-introduction-guide-f6fa9bb75…
    ## 3    -0.983 https://www.tensorflow.org/tutorials/images/cnn                     
    ## 4    -1     https://www.analyticsvidhya.com/blog/2019/09/introduction-to-pytorc…

Publication dates

``` r
z %>% select(published, url2)
```

    ## # A tibble: 4 × 2
    ##   published           url2                                                      
    ##   <dttm>              <chr>                                                     
    ## 1 2019-11-24 00:00:00 https://alastairrushworth.github.io/Visualising-Tour-de-F…
    ## 2 2019-09-01 18:03:22 https://medium.com/dair-ai/pytorch-1-2-introduction-guide…
    ## 3 2022-01-26 00:00:00 https://www.tensorflow.org/tutorials/images/cnn           
    ## 4 2019-09-17 03:09:28 https://www.analyticsvidhya.com/blog/2019/09/introduction…

## Comments? Suggestions? Issues?

Any feedback is welcome! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
