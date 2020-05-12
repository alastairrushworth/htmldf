#' @export
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr

get_time <- function(page, url){
  if('xml_document' %in% class(page)){
    if(!grepl('github\\.com', url)){
      time_tags <- c('meta[property="article:published_time"]', 
                     'meta[property="og:updated_time"]')
      pub_time  <- unlist(lapply(time_tags, get_tags, page = page))
    } else {
      pub_time <- try(page %>% 
                        html_nodes('relative-time') %>% 
                        html_attr('datetime'), 
                      silent = TRUE)
    }
    pub_time <- sort(unique(pub_time))
    if(length(pub_time) > 1) pub_time <- pub_time[1]
    if(length(pub_time) == 0) pub_time <- NA
  } else {
    pub_time <- NA
  }
  return(pub_time)
}

get_tags  <- function(tag, page){
  tag_chr <- try(page %>% html_nodes(tag) %>% html_attr('content'), silent = TRUE)
  tag_chr <- ifelse('try-error' %in% class(tag_chr), NA, tag_chr)
  return(tag_chr)
}
