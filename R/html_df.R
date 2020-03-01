#' Get a tabular summary of webpage content from a vector of urls
#'
#' @description From a vector of urls, \code{html_df} will attempt to fetch the html,
#' get the page title and the language, returning the result as a dataframe.
#'
#' @param urlx A character vector containing urls
#'
#' @return A tibble with columns \code{url} the original vector of urls;
#' \code{title} the page title' \code{url2} the final url if the original was a
#' redirect; \code{page} the result of a \code{GET} command; \code{html} the
#' html content.
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
#' @export

html_df <- function(urlx){
  z <- tibble(url = urlx) %>%
    mutate(page = get_pages(url)) %>%
    mutate(url2 = get_nice_url(page)) %>%
    mutate(html = get_html(page)) %>%
    mutate(title = get_title(html, urls = url2)) %>%
    mutate(lang = get_language(html)) %>%
    select(url, title, lang, url2, page, html)
  return(z)
}


