#' @importFrom tibble tibble

get_headers <- function(pages, show_progress = TRUE){
  if(show_progress) message('Extracting from headers...\r', appendLF = FALSE)
  n_page     <- length(pages)
  size_out   <- vector('integer', length = n_page)
  server_out <- vector('character', length = n_page)
  url_out    <- vector('character', length = n_page)
  pb         <- start_progress(prefix = "Getting headers", total = n_page)
  for(i in 1:n_page){
    update_progress(bar = pb, iter = i, total = n_page, what = '')
    if(class(pages[[i]]) == 'response') {
      try_size <- try(length(pages[[i]]$content), silent = TRUE)
      try_server <- try(pages[[i]]$headers$server, silent = TRUE)
      try_url <- try(pages[[i]]$url, silent = TRUE)
      # add to vectors if no error
      size_out[i] <- ifelse('try_error' %in% class(try_size), NA, try_size)
      server_out[i] <- ifelse('try_error' %in% class(try_server), NA, try_server)
      url_out[i] <- ifelse('try_error' %in% class(try_url), NA, try_url)
    } else {
      size_out[i] <- server_out[i] <- url_out[i] <- NA
    }
  }
  out_df <- tibble(size = size_out, server = server_out, url2 = url_out)
  if(show_progress) flush.console()
  return(out_df)
}
