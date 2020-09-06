#' @importFrom dplyr arrange
#' @importFrom dplyr desc
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom rvest html_text
#' @importFrom stringr str_count
#' @importFrom tidyr pivot_longer
#' @import ranger
#' @import ranger

guess_code_lang <- function(x){
  if('xml_document' %in% class(x)){
    # combine pre, code and text area tags
    pre_tags  <- html_text(html_nodes(x, "pre"))
    code_tags <- html_text(html_nodes(x, "code"))
    area_tags <- html_text(html_nodes(x, "textarea"))
    code      <- c(pre_tags, code_tags, area_tags)
    # remove everything between # and \n - these are usually comments
    code <- gsub("#.*?\n", " ", code)
    # split by \n
    code <- unlist(strsplit(code, "\n"))
    # remove \r code
    code <- paste(gsub("\r", "", code), collapse = " ")
    
    # get the number of occurences of certain syntaxes
    items <- c("<-", "::", "\\.", "%>%", "\\(\\)", "\\(", "\\)", 
               "\\[", "\\]", "__", " + ", "\\{", "\\}", 
               "\\$", "function\\((.*?)\\)", 
               "library\\((.*?)\\)", "install.packages\\((.*?)\\)",
               "import ", "def ", "pandas", "from ",  "numpy",
               "geom_", "pip install", "python", "dplyr",
               "\\.py", "\\.r")
    # count up the number of occurences of the patterns above
    code_pattern_counts <- lapply(tolower(code), str_count, pattern = items)
    xout           <- as.data.frame(do.call("rbind", code_pattern_counts))
    if(sum(xout[1, ]) > 0){
      cnts           <- rowSums(xout)
      cnts[cnts == 0] <- 1
      xout           <- xout / cnts
      
      # score with the language classifier
      z <- predict(code_lang_classifier, data = xout)$predictions %>%
        tibble::as_tibble()  %>%
        tidyr::pivot_longer(cols = c('r', 'py')) %>%
        dplyr::arrange(desc(value))
      if(all(z$value == z$value[1]) | is.na(z$value[1])){
        lang <- NA 
      } else {
        lang <- z$name[1]
      }
    } else {
      lang <- NA
    }
  } else {
    lang <- NA
  }
  return(lang)
}