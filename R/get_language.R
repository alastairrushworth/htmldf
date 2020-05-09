#' @importFrom cld3 detect_language
#' @importFrom rvest html_text

get_language <- function(page){
  if('xml_document' %in% class(page)){
    html_txt <- try(page %>% html_text(), silent = TRUE)
    if(!'try-error' %in% class(html_txt)){
      lang <- gsub('  |\\\n', '', html_txt) %>%
        cld3::detect_language(.)
    } else {
      lang <- NA
    }
  } else {
    lang <- NA
  }
  return(lang)
}