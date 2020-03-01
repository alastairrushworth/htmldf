get_nice_url <- function(page){
  n_page    <- length(page)
  url_out   <- vector('character', length = n_page)
  pb        <- start_progress(prefix = "Nice url", total = n_page)
  for(i in 1:n_page){
    update_progress(bar = pb, iter = i, total = n_page, what = '')
    if(class(page[[i]]) == 'response') {
      url_out[i] <- page[[i]]$url
    } else {
      url_out[i] <- NA
    }
  }
  return(url_out)
}
