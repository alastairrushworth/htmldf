#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom stringr str_extract
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url

get_imgs <- function(page, url){
  links_vec <- try(get_img_links(page, url = url), silent = TRUE)
  if(!'try-error' %in% class(links_vec)){
    isbase64    <- grepl("data:image/([a-zA-Z]*);base64,", links_vec)
    image_ext   <- file_ext(links_vec)
    if(sum(isbase64) > 0){
      base_info <- stringr::str_extract(links_vec, "data:image/([a-zA-Z]*);base64,")
      image_ext[which(isbase64)] <- gsub(';base64,|data:image/', '', 
                                         base_info[which(isbase64)])
    }
    img_df <- tibble(image_url = links_vec, 
                     image_ext = image_ext,
                     isbase64  = isbase64)
  } else {
    img_df <- tibble(image_url = NA, 
                     image_ext = NA, 
                     isbase64  = NA)
  }
  return(img_df)
}

get_img_links <- function(page, url){
  # Extract the link text
  link_ <- page %>%
    rvest::html_nodes("img") %>%
    rvest::html_attr('src') %>%
    xml2::url_absolute(base = url) %>%
    unique(.) %>%
    sort(.)
  # return vector of links
  return(link_)
}