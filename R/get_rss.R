#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_rss_links <- function(html_content, url){
  # get rss feeds
  links_rss <- html_content %>% 
    html_nodes('link[type="application/rss+xml"]') %>% 
    html_attr('href')
  # atom feeds
  links_atom <- html_content %>% 
    html_nodes('link[type="application/atom+xml"]') %>% 
    html_attr('href')
  # feedburner links
  links_feedburner <- html_content %>%
    html_nodes('a') %>% 
    html_attr('href') %>%
    grep('feeds\\.feedburner\\.com', ., value = TRUE)
  # combine, get absolute
  links <- c(links_rss, links_atom, links_feedburner) %>%
    xml2::url_absolute(base = url) %>%
    tolower() %>% unique()
  # if no links were found, try manually looking for index.xmls in the html
  if(length(links) == 0){
    # index.xml
    links <- html_content %>%
      html_nodes('a') %>% 
      html_attr('href') %>%
      grep('index\\.xml$', ., value = TRUE) %>%
      xml2::url_absolute(base = url) %>%
      tolower() %>% unique()
  }
  # if nothing found, return NA
  if(length(links) == 0) links <- NA
  return(links)
}

get_rss <- function(html_list, urls, show_progress = TRUE){
  if(show_progress) message('Finding RSS feeds...\r', appendLF = FALSE)
  rss_vec <- vector("list", length = length(html_list))
  for(i in seq_along(html_list)){
    rss_char <- try(get_rss_links(html_list[[i]], url = urls[i]), silent = TRUE)
    if(!'try-error' %in% class(rss_char)){
      rss_vec[[i]] <- rss_char
    } else {
      rss_vec[[i]] <- NA
    }
  }
  if(show_progress) flush.console()
  return(rss_vec)
}
