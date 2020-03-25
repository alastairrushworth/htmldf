#' @importFrom httr GET
#' @importFrom httr timeout

get_pages <- function(url, show_progress = TRUE){
  n_url   <- length(url)
  url_out <- vector('list', length = length(url))
  if(show_progress) pb <- start_progress(prefix = "Downloading from url ", total = n_url)
  for(i in 1:n_url){
    Sys.sleep(1)
    if(show_progress) update_progress(bar = pb, iter = i, total = n_url, what = url[i])
    parse_attempt <- try(httr::GET(url[i], httr::timeout(5)), silent = TRUE)
    # just try again if it fails...
    if(class(parse_attempt) == 'try-error'){
      parse_attempt <- try(httr::GET(url[i], httr::timeout(5)), silent = TRUE)
    }
    # return NA if the URL could not be read
    if(class(parse_attempt) == 'try-error'){
      url_out[[i]] <- NA
    } else {
      url_out[[i]] <- parse_attempt
    }
  }
  return(url_out)
}
