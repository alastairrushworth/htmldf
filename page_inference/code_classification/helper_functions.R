get_code_text <- function(x){
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
  } else {
    code <- NA
  }
  # return code text
  code
}

code_features <- function(code){
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
  cnts           <- rowSums(xout)
  cnts[cnts == 0] <- 1
  xout           <- xout / cnts
  xout
}