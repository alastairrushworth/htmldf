#' @importFrom tibble tibble
#' @importFrom lubridate as_datetime
get_headers <- function(page){
  if(class(page) == 'response') {
    try_size   <- try(length(page$content), silent = TRUE)
    try_server <- try(page$headers$server, silent = TRUE)
    try_url    <- try(page$url, silent = TRUE)
    try_dt     <- try(as.character(page$date), silent = TRUE)
    # add to vectors if no error
    size_out      <- ifelse('try_error' %in% class(try_size), NA, try_size)
    server_out    <- ifelse(any(c('try_error', 'NULL') %in% class(try_server)), NA, try_server)
    url_out       <- ifelse('try_error' %in% class(try_url), NA, try_url)
    dt_out        <- ifelse('try_error' %in% class(try_dt), NA, try_dt)
  } else {
    size_out <- server_out <- url_out <- dt_out <- NA
  }
  hdr_list <- list(size = size_out, server = server_out, url2 = url_out, accessed = dt_out)
  return(hdr_list)
}