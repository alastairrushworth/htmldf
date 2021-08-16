#' @importFrom rvest html_text
#' @importFrom rvest html_node
#' @importFrom rvest html_attr

get_generator <- function(page){
    if('xml_document' %in% class(page)){
      html_gen <- try(
        page %>%
          rvest::html_node('meta[name="generator"]') %>%
          rvest::html_attr('content'), silent = TRUE)
      if(!'try-error' %in% class(html_gen)){
        if(is.na(html_gen)){
          # check comments for pkgdown
          generator <- page %>%
            html_nodes(xpath=".//comment()") %>%
            grepl(' pkgdown ', x = .) %>%
            any() %>%
            ifelse(., 'pkgdown', NA)
        } else{
          generator <- html_gen
        }
        
      } else {
        generator <- NA
      }
    } else {
      generator <- NA
    }
  return(generator)
}