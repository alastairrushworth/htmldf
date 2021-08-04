#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom rvest html_text
#' @importFrom tibble tibble
#' @importFrom xml2 url_absolute


get_links <- function(html_content, url){
  links_df <- try(get_page_links(html_content, url), silent = TRUE)
  if('try-error' %in% class(links_df)){
    links_df  <- tibble(href = character(), 
                        text = character())
  }
  return(links_df)
}

get_page_links <- function(html_content, url){
  # get a tags
  links    <- html_content %>% html_nodes("a")
  # get hrefs
  l_hrefs  <- links %>% html_attr('href')
  # ensure the hrefs are absolute, not relative
  l_hrefs  <- xml2::url_absolute(l_hrefs, url)
  # get text
  l_text   <- links %>% html_text()
  # clean up text a bit
  l_text   <- clean_string(l_text)
  # combine into a single tibble
  links_df <- tibble(href = l_hrefs, text = l_text)
  # return tibble
  return(links_df)
}