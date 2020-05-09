#' @importFrom httr GET
#' @importFrom httr timeout

get_pages <- function(url, time_out){
  parse_attempt <- try(httr::GET(url, httr::timeout(time_out)), silent = TRUE)
  # just try again if it fails...
  if(class(parse_attempt) == 'try-error'){
    parse_attempt <- try(httr::GET(url, httr::timeout(time_out)), silent = TRUE)
  }
  # return NA if the URL could not be read
  if(class(parse_attempt) == 'try-error'){
    page <- NA
  } else {
    page <- parse_attempt
  }
  return(page)
}
