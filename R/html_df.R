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
#' @param retry_times Number of times to retry a URL after failure.
#' @param max_size Maximum size in bytes of pages to attempt to parse, defaults to \code{5000000}.
#'   This is to avoid reading very large pages that may cause \code{read_html()} to hang.
#' @param keep_source Logical argument - whether or not to retain the contents of the page \code{source} 
#' column in the output tibble.  Useful to reduce memory usage when scraping many pages.  Defaults to \code{TRUE}.
#' @param time_out Time in seconds to wait for \code{httr::GET()} to complete before exiting.  Defaults 
#' to 30. 
#' @param chrome_bin (Optional) Path to a Chromium install to use Chrome in headless mode for scraping
#' @param chrome_args (Optional) Vector of additional command-line arguments to pass to chrome
#' @param ... Additional arguments to `httr::GET()`.
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
#' \item \code{status} HTTP status code 
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
#' @importFrom utils object.size
#' @export

html_df <- function(
  urlx, 
  max_size = 5000000, 
  wait = 0,
  retry_times = 0,
  time_out = 30, 
  show_progress = TRUE, 
  keep_source = TRUE, 
  chrome_bin = NULL,
  chrome_args = NULL,
  ...
){
  fetch_list <- vector('list', length = length(urlx))
  # loop over pages and fetch
  if(show_progress) pb <- start_progress(total = length(urlx), prefix = 'Parsing link: ')
  for(i in seq_along(urlx)){
    if(wait > 0) Sys.sleep(wait)
    if(show_progress){
      # update progress bar
      update_progress(
        bar = pb, iter = i, total = length(urlx), 
        what = ifelse(is.na(urlx[i]), 'URL is NA', urlx[i])
      )
    }
    # cycle through urls and attempt to request each page
    fetch_list[[i]] <- fetch_page(
      urlx[i], 
      max_size    = max_size, 
      time_out    = time_out, 
      retry_times = retry_times,
      keep_source = keep_source, 
      chrome_bin  = chrome_bin, 
      chrome_args = chrome_args,
      ...)
  }
  # combine into dataFrame
  z <- tibble(z = fetch_list) %>% 
    unnest_wider(
      z, 
      simplify = list('social' = FALSE, 'tables' = FALSE, 'images' = FALSE, 'links' = FALSE)) %>%
    select(url, title, lang, url2, links, rss, tables, 
           images, social, code_lang, size, server, 
           accessed, published, generator, status,
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



