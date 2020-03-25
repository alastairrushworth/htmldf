#' @importFrom cld3 detect_language
#' @importFrom rvest html_text
get_language <- function(page, show_progress = TRUE){
  if(show_progress) message('Inferring page language...\r', appendLF = FALSE)
  lang_vec  <- character(length = length(page))
  for(i in 1:length(page)){
    if('xml_document' %in% class(page[[i]])){
      html_txt <- try(page[[i]] %>% html_text(), silent = TRUE)
      if(!'try-error' %in% class(html_txt)){
        lang_vec[i] <- gsub('  |\\\n', '', html_txt) %>%
          cld3::detect_language(.)
      } else {
        lang_vec[i] <- NA
      }
    } else {
      lang_vec[i] <- NA
    }
  }
  if(show_progress) flush.console()
  return(lang_vec)
}
