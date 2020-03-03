#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_img_links <- function(page){
  # Extract the link text
  link_ <- page %>%
    xml2::read_html() %>%
    rvest::html_nodes("img") %>%
    rvest::html_attr('src') %>%
    xml2::url_absolute(base = page$url) %>%
    unique(.) %>%
    sort(.)
  # return vector of links
  return(link_)
}

get_imgs <- function(pages){
  img_list <- vector("list", length = length(pages))
  for(i in seq_along(pages)){
    links_vec <- try(get_img_links(pages[[i]]), silent = TRUE)
    if(!'try-error' %in% class(links_vec)){
      img_list[[i]] <- tibble(image_url = links_vec, image_ext = file_ext(links_vec))
    } else {
      img_list[[i]] <- tibble(image_url = NA, image_ext = NA)
    }
  }
  return(img_list)
}
