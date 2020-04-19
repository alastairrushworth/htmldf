#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom stringr str_extract
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url

get_img_links <- function(html_content, url){
  # Extract the link text
  link_ <- html_content %>%
    rvest::html_nodes("img") %>%
    rvest::html_attr('src') %>%
    xml2::url_absolute(base = url) %>%
    unique(.) %>%
    sort(.)
  # return vector of links
  return(link_)
}

get_imgs <- function(html_list, urls, show_progress = TRUE){
  if(show_progress) message('Extracting image links...\r', appendLF = FALSE)
  img_list <- vector("list", length = length(html_list))
  for(i in seq_along(html_list)){
    links_vec <- try(get_img_links(html_list[[i]], url = urls[i]), silent = TRUE)
    if(!'try-error' %in% class(links_vec)){
      isbase64    <- grepl("data:image/([a-zA-Z]*);base64,", links_vec)
      image_ext   <- file_ext(links_vec)
      if(sum(isbase64) > 0){
        base_info <- stringr::str_extract(links_vec, "data:image/([a-zA-Z]*);base64,")
        image_ext[which(isbase64)] <- gsub(';base64,|data:image/', '', 
                                           base_info[which(isbase64)])
      }
      img_list[[i]] <- tibble(image_url = links_vec, 
                              image_ext = image_ext,
                              isbase64  = isbase64
                              )
    } else {
      img_list[[i]] <- tibble(image_url = NA, 
                              image_ext = NA, 
                              isbase64  = NA)
    }
  }
  if(show_progress) flush.console()
  return(img_list)
}
