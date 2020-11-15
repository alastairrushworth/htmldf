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
  try(
    {
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
        # code patterns to check code chunks for 
        items <- c(
          "<-", "::", "\\.", "%>%", "\\(\\)", "\\(", "\\)", 
          "\\[", "\\]", "__", " + ", "\\{", "\\}", 
          "\\$", "function\\((.*?)\\)", 
          "library\\((.*?)\\)", "install.packages\\((.*?)\\)",
          "import ", "def ", "pandas", "from ",  "numpy",
          "geom_", "pip install", "python", "dplyr",
          "\\.py", "\\.r"
        )
        # count up the number of occurrences of the patterns above
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
            lang <- ifelse(z$name[1] == 'py', -z$value[1], z$value) 
          }
        } else {
          # if no embedded code, check for code gists and use file ext as the code guess
          gist_score <- x %>%
            html_nodes('script') %>%
            html_attr('src') %>%
            grep('gist.github.com', ., value = TRUE) %>%
            grep('.py$|.r$', ., value = TRUE, ignore.case = TRUE) %>%
            grepl('.py$', ., ignore.case = TRUE) 
          lang <- ifelse(length(gist_score) > 0, c(1, -1)[1 + (mean(gist_score) > 0.5)], NA)
        }
      } else {
        lang <- NA
      }
    },
    silent = TRUE)
  # if the above fails, lang is NA
  if(!exists('lang')) lang <- NA
  return(lang)
}