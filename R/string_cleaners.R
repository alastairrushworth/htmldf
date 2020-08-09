clean_string <- function(v){
  # tidy up titles with html tags
  v <- gsub('\\\n|\\\t|\\\r', '', v)
  # remove trailing / leading white space
  v <- gsub('^\\s+|\\s+$', '', v)
  # remove multiple white space with single space
  v <- gsub(' {2,}', ' ', v)
  # return 
  return(v)
}
