#' @importFrom xml2 read_html
#' @importFrom R.utils withTimeout
get_html <- function(page, show_progress = TRUE){
  if(show_progress) message('Extracting html content...\r', appendLF = FALSE)
  n_page    <- length(page)
  html_out  <- vector('list', length = n_page)
  pb        <- start_progress(prefix = "Getting html", total = n_page)
  for(i in seq_along(page)){
    update_progress(bar = pb, iter = i, total = n_page, what = '')
    if(class(page[[i]]) == 'response') {
      html_out[[i]] <- try(withTimeout(xml2::read_html(page[[i]]), 
                                       onTimeout = 'error', 
                                       timeout = 10), 
                           silent = TRUE)
    } else {
      html_out[[i]] <- NA
    }
    if('try_error' %in% class(html_out[[i]])){
      html_out[[i]] <- NA
    }
  }
  if(show_progress) flush.console()
  return(html_out)
}