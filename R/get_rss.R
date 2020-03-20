#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_rss_links <- function(page){
  x <- page %>% read_html()
  # get rss feeds
  links_rss <- x %>% 
    html_nodes('link[type="application/rss+xml"]') %>% 
    html_attr('href')
  # atom feeds
  links_atom <- x %>% 
    html_nodes('link[type="application/atom+xml"]') %>% 
    html_attr('href')
  # feedburner links
  links_feedburner <- x %>%
    html_nodes('a') %>% 
    html_attr('href') %>%
    grep('feeds\\.feedburner\\.com', ., value = TRUE)
  # combine, get absolute
  links <- c(links_rss, links_atom, links_feedburner) %>%
    xml2::url_absolute(base = page$url) %>%
    tolower() %>% unique()
  # if nothing found, return NA
  if(length(links) == 0) links <- NA
  return(links)
}

get_rss <- function(pages){
  rss_vec <- vector("list", length = length(pages))
  for(i in seq_along(pages)){
    rss_char <- try(get_rss_links(pages[[i]]), silent = TRUE)
    if(!'try-error' %in% class(rss_char)){
      rss_vec[[i]] <- rss_char
    } else {
      rss_vec[[i]] <- NA
    }
  }
  return(rss_vec)
}



