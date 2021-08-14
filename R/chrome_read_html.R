#' @importFrom processx run
#' @importFrom xml2 read_html

chrome_read_html <- function(url, chrome_bin, timeout){
  
  args <- c("--headless", 
            "--disable-gpu", 
            "--no-sandbox", 
            "--allow-no-sandbox-job",  
            "--dump-dom",
            "--virtual-time-budget=10000",
            url)
  
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
