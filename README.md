
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
remotes::install_github('alastairrushworth/htmldf)
```

To use `html_df`

``` r
library(htmldf)
library(dplyr)

urlx <- c("https://alastairrushworth.github.io/Visualising-Tour-de-France-data-in-R/",
          "https://www.tensorflow.org/tutorials/images/cnn", 
          "https://www.robertmylesmcdonnell.com/content/posts/mtcars/")
z <- html_df(urlx, show_progress = FALSE)
z
```

    ## # A tibble: 3 x 15
    ##   url   title lang  url2  links rss   images social code_lang   size server
    ##   <chr> <chr> <chr> <chr> <lis> <chr> <list> <list> <chr>      <int> <chr> 
    ## 1 http… Visu… en    http… <tib… http… <tibb… <tibb… r          38198 GitHu…
    ## 2 http… Conv… en    http… <tib… <NA>  <tibb… <tibb… py         96547 Googl…
    ## 3 http… Robe… en    http… <tib… <NA>  <tibb… <tibb… r         290976 Netli…
    ## # … with 4 more variables: accessed <dttm>, published <dttm>, generator <chr>,
    ## #   source <list>

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
    ## # A tibble: 2 x 3
    ##   site    handle             profile                             
    ##   <chr>   <chr>              <chr>                               
    ## 1 twitter @rushworth_a       https://twitter.com/rushworth_a     
    ## 2 github  @alastairrushworth https://github.com/alastairrushworth
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

Inferred code language

``` r
z %>% select(code_lang, url2)
```

    ## # A tibble: 3 x 2
    ##   code_lang url2                                                                
    ##   <chr>     <chr>                                                               
    ## 1 r         https://alastairrushworth.github.io/Visualising-Tour-de-France-data…
    ## 2 py        https://www.tensorflow.org/tutorials/images/cnn                     
    ## 3 r         https://www.robertmylesmcdonnell.com/content/posts/mtcars/

## Comments? Suggestions? Issues?

Any feedback is welcome\! Feel free to write a github issue or send me a
message on [twitter](https://twitter.com/rushworth_a).
