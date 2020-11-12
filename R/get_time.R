#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr

get_time <- function(page, url){
  if('xml_document' %in% class(page)){
    if(!grepl('github\\.com', url)){
      # check first if there are any times in the page header
      time_tags <- c(
        'meta[property="article:published_time"]', 
        'meta[property="og:updated_time"]',
        'meta[property="article:published"]', 
        'meta[property="article:created"'
      )
      pub_time  <- unlist(lapply(time_tags, get_tags, page = page))
      # if no header times, then check for other stuff
      if(length(pub_time == 0)){
        node_list <- c(
          "h2[class='date-header']",
          "span[class='date-container minor-meta meta-color']",
          "span[class='postdate']",
          "time", 
          "p[class='dateline']",
          "div[class='date']"
        )
        pub_time  <- unlist(lapply(node_list, get_time_text, page = page))
      }
    } else {
      pub_time <- try(
        page %>% 
          html_nodes('relative-time') %>% 
          html_attr('datetime'), 
        silent = TRUE
      )
    }
    pub_time <- sort(unique(pub_time))
    if(length(pub_time) > 1) pub_time  <- pub_time[1]
    if(length(pub_time) == 0) pub_time <- NA
  } else {
    pub_time <- NA
  }
  return(pub_time)
}

get_tags  <- function(tag, page){
  tag_chr <- try(
    page %>% 
      html_nodes(tag) %>% 
      html_attr('content'), 
    silent = TRUE
  )
  tag_chr <- ifelse('try-error' %in% class(tag_chr), NA, tag_chr)
  return(tag_chr)
}

get_time_text <- function(tag, page){
  tag_chr <- try(
    page %>% 
      html_nodes(tag) %>% 
      html_text(), 
    silent = TRUE
  )
  tag_chr <- ifelse('try-error' %in% class(tag_chr), NA, tag_chr)
  return(tag_chr)
}
  