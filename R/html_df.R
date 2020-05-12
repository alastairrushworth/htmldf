#' Get a tabular summary of webpage content from a vector of urls
#'
#' @description From a vector of urls, \code{html_df} will attempt to fetch the html.  From the 
#' html, html_df will attempt to look for a page title, rss feeds, images, embedded social media
#' profile handles and other page metadata.  Page language is inferred using the package \code{cld3}
#' which uses Google's Compact Language Detector 3.
#'
#' @param urlx A character vector containing urls.
#' @param show_progress Logical, defaults to \code{TRUE}. Whether to print progress 
#' messages to the console while download and parse is in progress.
#' @param max_size Maximum size in bytes of pages to attempt to parse, defaults to \code{5000000}.
#'   This is to avoid reading very large base64 encoded pages can cause \code{read_html()} to hang.
#' @param time_out Time in seconds to wait for \code{httr::GET()} when fetching the page.  Defaults 
#' to 10 seconds. 
#' @return A tibble with columns 
#' \itemize{
#' \item \code{url} the original vector of urls provided
#' \item \code{title} the page title, if found
#' \item \code{lang} inferred page language
#' \item \code{url2} the fetched url this may be different to the original eg. if it was redirected
#' \item \code{rss} a list of embedded rss feeds found on the page
#' \item \code{images} list of tibbles containing image links found on the page
#' \item \code{twitter} character vector of twitter handles found on the page
#' \item \code{github} character vector of github profile pages found on the page
#' \item \code{linkedin} character vectors of linkedin profile pages found on the page 
#' \item \code{size} the size of the downloaded page in bytes
#' \item \code{server} the page server
#' \item \code{generator} the page generator (if found)
#' \item \code{source} list column containing page xml documents
#' }
#'
#' @author Alastair Rushworth
#' @examples
#' urlx <- c("https://ropensci.org/blog/2020/02/21/ropensci-leadership/",
#'           "https://es.wikipedia.org/wiki/Wikipedia_en_espa%C3%B1ol")
#' html_df(urlx)
#'
#' @importFrom tibble tibble
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom magrittr `%>%`
#' @importFrom tidyr unnest_wider
#' @importFrom tibble tibble
#' @export

html_df <- function(urlx, max_size = 5000000, time_out = 10, show_progress = TRUE){
  fetch_list <- vector('list', length = length(urlx))
  # loop over pages and fetch
  if(show_progress) pb <- start_progress(total = length(urlx), prefix = 'Parsing link: ')
  for(i in seq_along(urlx)){
    if(show_progress) update_progress(bar = pb, iter = i, total = length(urlx), what = urlx[i])
    fetch_list[[i]] <- fetch_page(urlx[i], max_size = max_size, time_out = time_out)
  }
  # combine into dataFrame
  z <- tibble(z = fetch_list) %>% 
    unnest_wider(z) %>%
    select(url, pub_date, title, lang, url2, rss, images, 
           twitter, github, linkedin, size, server, generator, source)
  # progress print and flush
  if(show_progress){
    flush.console()
    message('Done.                         ', appendLF = FALSE)
    flush.console()
  }
  return(z)
}


fetch_page <- function(url, time_out, max_size){
  # download page
  pg_dl  <- get_pages(url, time_out = time_out)
  pg_hdr <- get_headers(pg_dl)
  if(class(pg_dl) == "response"){
    if(!is.null(max_size)){
      if(max_size < pg_hdr$size){
        pg_dl <- NA
      }
    }
    url2  <- pg_dl$url
  } else {
    url2 <- url
  }

  # get attributes from html
  pg_htm <- get_html(pg_dl)
  pg_img <- get_imgs(pg_htm, url2)
  pg_ttl <- get_title(pg_htm, url = url2)
  pg_scl <- get_social(pg_htm)
  pg_lng <- get_language(pg_htm)
  pg_rss <- get_rss(pg_htm, url = url2)
  pg_gen <- get_generator(pg_htm)
  pg_tim <- get_time(pg_htm, url = url2)

  # combine into list
  pg_features <- c(
    list(url = url, 
         url2 = url2, 
         rss = pg_rss, 
         title = pg_ttl, 
         source = list(pg_htm), 
         images = pg_img, 
         generator = pg_gen, 
         lang = pg_lng, 
         server = pg_hdr$server, 
         size = pg_hdr$size, 
         pub_date = pg_tim), 
    pg_scl)
  return(pg_features)
}
