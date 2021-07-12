#' Get a tabular summary of webpage content from a vector of urls
#'
#' @description From a vector of urls, \code{html_df()} will attempt to fetch the html.  From the 
#' html, \code{html_df()} will attempt to look for a page title, rss feeds, images, embedded social media
#' profile handles and other page metadata.  Page language is inferred using the package \code{cld3}
#' which wraps Google's Compact Language Detector 3.
#'
#' @param urlx A character vector containing urls.  Local files must be prepended with \code{file://}.
#' @param show_progress Logical, defaults to \code{TRUE}. Whether to show progress during download.
#' @param wait Time in seconds to wait between successive requests. Defaults to 0.
#' @param max_size Maximum size in bytes of pages to attempt to parse, defaults to \code{5000000}.
#'   This is to avoid reading very large pages that may cause \code{read_html()} to hang.
#' @param keep_source Logical argument - whether or not to retain the contents of the page \code{source} 
#' column in the output tibble.  Useful to reduce memory usage when scraping many pages.  Defaults to \code{TRUE}.
#' @param time_out Time in seconds to wait for \code{httr::GET()} to complete before exiting.  Defaults 
#' to 10. 
#' @return A tibble with columns 
#' \itemize{
#' \item \code{url} the original vector of urls provided
#' \item \code{title} the page title, if found
#' \item \code{lang} inferred page language
#' \item \code{url2} the fetched url, this may be different to the original, for example if redirected
#' \item \code{links} a list of tibbles of hyperlinks found in \code{<a>} tags
#' \item \code{rss} a list of embedded RSS feeds found on the page
#' \item \code{tables} a list of tables found on the page in descending order of size, coerced to
#'  \code{tibble} wherever possible.  
#' \item \code{images} list of tibbles containing image links found on the page
#' \item \code{social} list of tibbles containing twitter, linkedin and github user info found on page
#' \item \code{code_lang} numeric indicating inferred code language.  A negative values near -1 
#' indicates high likelihood that the language is python, positive values near 1 indicate R. 
#' If not code tags are detected, or the language could not be inferred, value is \code{NA}.
#' \item \code{size} the size of the downloaded page in bytes
#' \item \code{server} the page server
#' \item \code{accessed} datetime when the page was accessed
#' \item \code{published} page publication or last updated date, if detected 
#' \item \code{generator} the page generator, if found
#' \item \code{source} character string of xml documents.  These can each be coerced to \code{xml_document}
#' for further processing using \code{rvest} using \code{xml2:read_html()}.
#' }
#'
#' @author Alastair Rushworth
#' @examples
#' # Examples require an internet connection...
#' urlx <- c("https://github.com/alastairrushworth/htmldf", 
#'           "https://alastairrushworth.github.io/")
#' dl   <- html_df(urlx)
#' # preview the dataframe
#' head(dl)
#' # social tags
#' dl$social
#' # page titles
#' dl$title
#' # page language
#' dl$lang
#' # rss feeds
#' dl$rss
#' # inferred code language
#' dl$code_lang
#' # print the page source
#' dl$source
#' 
#'
#' @importFrom tibble tibble
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom magrittr `%>%`
#' @importFrom tidyr unnest_wider
#' @importFrom tibble tibble
#' @importFrom lubridate parse_date_time
#' @importFrom utils flush.console
#' @export

html_df <- function(urlx, 
                    max_size = 5000000, 
                    wait = 0,
                    time_out = 10, 
                    show_progress = TRUE, 
                    keep_source = TRUE){
  fetch_list <- vector('list', length = length(urlx))
  # loop over pages and fetch
  if(show_progress) pb <- start_progress(total = length(urlx), prefix = 'Parsing link: ')
  for(i in seq_along(urlx)){
    if(wait > 0) Sys.sleep(wait)
    if(show_progress) update_progress(bar = pb, iter = i, total = length(urlx), what = ifelse(is.na(urlx[i]), 'URL is NA', urlx[i]))
    fetch_list[[i]] <- fetch_page(urlx[i], max_size = max_size, time_out = time_out, keep_source = keep_source)
  }
  # combine into dataFrame
  z <- tibble(z = fetch_list) %>% 
    unnest_wider(z) %>%
    select(url, title, lang, url2, links, rss, tables, 
           images, social, code_lang, size, server, 
           accessed, published, generator,
           source)
  # coerce the accessed dt to datetime
  accessed_dt <- suppressWarnings(try(as_datetime(z$accessed), silent = TRUE))
  if(!'try-error' %in% class(accessed_dt)){
    z$accessed <- accessed_dt
  }
  # coerce the pub_date to datetime
  # attempt to parse the published date colunn to datetime
  date_patterns <- c("d m y", "d B Y", "m/d/y", "Y/m/d", 'd b Y HM', 
                     'b d', 'Y-m-dH:M:S', "ymdTz", "ymdT")
  published_dt <- try(
    suppressWarnings(
      parse_date_time(x = z$published, orders = date_patterns)
    ), 
    silent = TRUE
  )
  
  if(!'try-error' %in% class(published_dt)){
    z$published <- published_dt
  }
  # progress print and flush
  if(show_progress){
    flush.console()
    message('Done.                         ', appendLF = FALSE)
    flush.console()
  }
  return(z)
}


fetch_page <- function(url, time_out, max_size, keep_source){
  # download page
  pg_dl  <- get_pages(url, time_out = time_out)
  # extract headers from the 
  pg_hdr <- get_headers(pg_dl)
  if(class(pg_dl) == "response"){
    if(!is.null(max_size)){
      if(max_size < pg_hdr$size){
        pg_dl <- NA
        url2  <- NA
      } else {
        url2  <- pg_dl$url
      }
    } else {
      url2  <- pg_dl$url
    }
  } else {
    url2 <- url
  }
  
  # get attributes from html
  pg_htm       <- if(grepl('file://', url)) read_html(file(url)) else get_html(pg_dl) 
  pg_img       <- get_imgs(pg_htm, url2)
  pg_lnk       <- get_links(pg_htm, url2)
  pg_ttl       <- get_title(pg_htm, url = url2)
  pg_scl       <- get_social(pg_htm)
  pg_lng       <- get_language(pg_htm)
  pg_rss       <- get_rss(pg_htm, url = url2)
  pg_gen       <- get_generator(pg_htm)
  pg_tim       <- get_time(pg_htm, url = url2)
  pg_tbl       <- get_tables(pg_htm)
  pg_code_lang <- guess_code_lang(pg_htm)
  # source - sometimes coerciion to character will fail
  pg_source    <- ifelse(
    keep_source, 
    ifelse(
      'try-error' %in% class(try(as.character(pg_htm), silent = TRUE)),
      NA, 
      as.character(pg_htm)
    ), 
    NA
  )
  
  # combine into list
  pg_features <- 
    list(url = url, 
         url2 = url2, 
         rss = pg_rss, 
         title = pg_ttl, 
         links = pg_lnk,
         tables = pg_tbl,
         source = pg_source,
         social = pg_scl,
         images = pg_img, 
         generator = pg_gen, 
         lang = pg_lng, 
         server = pg_hdr$server, 
         size = pg_hdr$size, 
         accessed = pg_hdr$accessed,
         published = pg_tim,
         code_lang = pg_code_lang)

  return(pg_features)
}
