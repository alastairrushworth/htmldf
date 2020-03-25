get_nice_url <- function(page, show_progress = TRUE){
  if(show_progress) message('Checking page urls...\r', appendLF = FALSE)
  n_page    <- length(page)
  url_out   <- vector('character', length = n_page)
  for(i in 1:n_page){
    if(class(page[[i]]) == 'response') {
      url_out[i] <- page[[i]]$url
    } else {
      url_out[i] <- NA
    }
  }
  if(show_progress) flush.console()
  return(url_out)
}
