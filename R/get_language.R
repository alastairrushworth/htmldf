#' @importFrom cld3 detect_language
#' @importFrom rvest html_text
get_language <- function(html_list){
  lang_vec  <- character(length = length(html_list))
  for(i in 1:length(html_list)){
    html_txt <- try(html_list[[i]] %>% html_text())
    if(!'try-error' %in% class(html_txt)){
      lang_vec[i] <- gsub('  |\\\n', '', html_txt) %>%
        cld3::detect_language(.)
    } else {
      lang_vec[i] <- NA
    }
  }
  return(lang_vec)
}
