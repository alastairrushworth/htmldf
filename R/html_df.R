#' Get a tabular summary of webpage content from a vector of urls
#'
#' @description From a vector of urls, \code{html_df} will attempt to fetch the html,
#' get the page title and the language, returning the result as a dataframe.
#'
#' @param urlx A character vector containing urls.
#' @param show_progress Logical, defaults to \code{TRUE}. Whether to print progress 
#' messages to the console.
#' @param max_size Maximum size in bytes of pages to attempt to parse, defaults to \code{NULL}.
#'   Very large pages can cause \code{read_html()} to hang. 
#' @return A tibble with columns 
#' \itemize{
#' \item \code{url} the original vector of urls
#' \item \code{title} the page title
#' \item \code{lang} a guess of the page language
#' \item \code{url2} the fetched url (for example, if the original was a redirect) 
#' \item \code{rss} a list of embedded rss feeds found on the page
#' \item \code{images} list column containing page images
#' \item \code{twitter} comma separated string containing embedded links to twitter profiles 
#' \item \code{github} comma separated string containing embedded links to github profiles 
#' \item \code{linkedin} comma separated string containing embedded links to linkedin profiles 
#' \item \code{size} the size of the downloaded page in bytes
#' \item \code{html} list column containing page xml documents
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
#' @importFrom dplyr bind_cols
#' @importFrom magrittr `%>%`
#' @export

html_df <- function(urlx, show_progress = TRUE, max_size = NULL){
  
  # fetch the pages from url and exract url & size from header
  z <- tibble(url = urlx) %>%
    mutate(page   = get_pages(url, show_progress = show_progress))  %>%
    bind_cols(get_headers(.$page))
  
  # if any pages exceed the max size, replace page with NA
  if(!is.null(max_size)) z$page[z$size > max_size] <- NA
  
  # extract stuff from html
  z <- z %>%
    mutate(html   = get_html(page, show_progress = show_progress)) %>%
    mutate(title  = get_title(html, urls = url2, show_progress = show_progress)) %>%
    mutate(lang   = get_language(html, show_progress = show_progress)) %>%
    mutate(images = get_imgs(html, urls = url2, show_progress = show_progress)) %>%
    mutate(rss    = get_rss(html, urls = url2, show_progress = show_progress)) 
  
  # get social handles, reorder columns and return
  z <- bind_cols(z, 
                 get_social(z$html, show_progress = show_progress)) %>%
    select(url, title, lang, url2, rss, images, 
           twitter, github, linkedin, size, server, html)
  
  # progress print and flush
  if(show_progress){
    flush.console()
    message('Done.                         ', appendLF = FALSE)
    flush.console()
  }
  return(z)
}


