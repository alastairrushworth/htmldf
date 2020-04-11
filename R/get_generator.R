#' @importFrom rvest html_text
#' @importFrom rvest html_node
#' @importFrom rvest html_attr
get_generator <- function(page, show_progress = TRUE){
  if(show_progress) message('Finding page generator...\r', appendLF = FALSE)
  generator  <- character(length = length(page))
  for(i in 1:length(page)){
    if('xml_document' %in% class(page[[i]])){
      html_gen <- try(page[[i]] %>% 
        rvest::html_node('meta[name="generator"]') %>%
        rvest::html_attr('content'), silent = TRUE)
      if(!'try-error' %in% class(html_gen)){
        if(is.na(html_gen)){
          # check comments for pkgdown
          generator[i] <- page[[i]] %>%
            html_nodes(xpath=".//comment()") %>%
            grepl(' pkgdown ', x = .) %>%
            any() %>%
            ifelse(., 'pkgdown', NA)
        } else{
          generator[i] <- html_gen
        }

      } else {
        generator[i] <- NA
      }
    } else {
      generator[i] <- NA
    }
  }
  if(show_progress) flush.console()
  return(generator)
}
