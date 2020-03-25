get_size <- function(page, show_progress = TRUE){
  if(show_progress) message('Extracting headers...\r', appendLF = FALSE)
  n_page    <- length(page)
  size_out  <- vector('integer', length = n_page)
  pb        <- start_progress(prefix = "Getting headers", total = n_page)
  for(i in seq_along(page)){
    update_progress(bar = pb, iter = i, total = n_page, what = '')
    if(class(page[[i]]) == 'response') {
      try_size <- try(length(page[[i]]$content), silent = TRUE)
      if('try_error' %in% class(try_size)){
        size_out[i] <- NA
      } else {
        size_out[i] <- try_size
      }
    } else {
      size_out[i] <- NA
    }
  }
  if(show_progress) flush.console()
  return(size_out)
}