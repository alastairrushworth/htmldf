#' @importFrom processx run
#' @importFrom xml2 read_html

chrome_read_html <- function(url, chrome_bin, chrome_args, timeout){
  
  # set default chromium arguments
  default_args <- c(
    "--headless ", 
    "--disable-gpu ",
    "--no-sandbox ",
    "--allow-no-sandbox-job ",
    "--dump-dom ",
    "--virtual-time-budget=100000 ",
    '--user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36" '
 )
  # combine default with user-provided arguments
  if(!is.null(chrome_args)){
    # replace virtual time budget if included in chrome args
    if(any(grepl('^--virtual-time-budget\\=', chrome_args))){
      default_args <- default_args[-grep("^--virtual-time-budget\\=", default_args)]
    }
    # replace user agent if included in chrome args
    if(any(grepl('^--user-agent\\=', chrome_args))){
      default_args <- default_args[-grep("^--user-agent\\=", default_args)]
    }
    # combine new arguments with default ones
    default_args <- c(default_args, chrome_args)
  }
  
  # combine arguments with url to fetch
  args <- c(default_args, url)
  
  # go fetch
  res <- processx::run(
    command = chrome_bin,
    args = args,
    error_on_status = FALSE,
    echo_cmd = FALSE,
    echo = FALSE, 
    timeout = timeout
  )
  
  return(res$stdout)
}
