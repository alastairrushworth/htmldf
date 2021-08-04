#' @importFrom cld3 detect_language
#' @importFrom rvest html_text




get_language <- function(page){
  lang <- NA
  if('xml_document' %in% class(page)){
    # First try to find a language tag in the header
    lang <- try(
      page %>% html_attr('lang'), 
      silent = TRUE)
    if(!'try-error' %in% class(lang)){
      if(length(lang) > 0 & !is.na(lang)){
        if(nchar(lang[1]) > 0) return(tolower(lang[1]))
      }
    }
    html_txt <- try(page %>% html_text(), silent = TRUE)
    if(!'try-error' %in% class(html_txt)){
      lang <- gsub('  |\\\n', '', html_txt) %>%
        cld3::detect_language(.)
    }
  }
  return(lang)
}