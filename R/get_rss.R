#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_rss_links <- function(page){
  x <- page %>% read_html()
  links    <- x %>% html_nodes("a") %>% html_attr('href') %>% 
    grep('\\.xml$|\\.rss|/feed/$', ., value = TRUE) %>% tolower() %>% unique()
  if(length(links) > 0){
    links <- paste(links, collapse = ',') 
  } else {
    links <- NA
  }
  return(links)
}

get_rss <- function(pages){
  rss_vec <- vector("character", length = length(pages))
  for(i in seq_along(pages)){
    rss_char <- try(get_rss_links(pages[[i]]), silent = TRUE)
    if(!'try-error' %in% class(rss_char)){
      rss_vec[i] <- rss_char
    } else {
      rss_vec[i] <- NA
    }
  }
  return(rss_vec)
}



