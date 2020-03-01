#' @importFrom xml2 read_html
get_html <- function(page){
  n_page    <- length(page)
  html_out  <- vector('list', length = n_page)
  pb        <- start_progress(prefix = "Getting html", total = n_page)
  for(i in 1:n_page){
    update_progress(bar = pb, iter = i, total = n_page, what = '')
    if(class(page[[i]]) == 'response') {
      html_out[[i]] <- try(page[[i]] %>% xml2::read_html(), silent = TRUE)
    } else {
      html_out[[i]] <- NA
    }
    if('try_error' %in% class(html_out[[i]])){
      html_out[[i]] <- NA
    }
  }
  return(html_out)
}
