#' @importFrom xml2 read_html
#' @importFrom R.utils withTimeout
get_html <- function(page){
  if(class(page) == 'response') {
    html_out <- try(
      withTimeout(xml2::read_html(page), 
                  onTimeout = 'error', 
                  timeout = 10), 
      silent = TRUE)
  } else html_out <- NA
  if('try_error' %in% class(html_out)) html_out <- NA
  return(html_out)
}