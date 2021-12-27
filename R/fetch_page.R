#' @importFrom httr GET
#' @importFrom httr RETRY
#' @importFrom httr HEAD
#' @importFrom httr timeout

fetch_page <- function(url, time_out, retry_times, max_size, keep_source, chrome_bin, ...){
  # attempt to read from  url
  parse_attempt <- try(
    httr::RETRY("GET", url, timeout = httr::timeout(time_out), times = retry_times, ...), 
    silent = TRUE)
  if(!is.null(chrome_bin)){
    parse_attempt2 <- try(
      chrome_read_html(
        url, 
        timeout = time_out, 
        chrome_bin = chrome_bin), 
      silent = TRUE)
  }
  
  # return NA if the URL could not be read
  if(class(parse_attempt) == 'try-error'){
    pg_dl <- NA
  } else {
    pg_dl <- parse_attempt
  }

  # extract headers from the page
  if(class(pg_dl) == "response"){
    pg_hdr     <- get_headers(pg_dl)
    hdr_server <- pg_hdr$server
    hdr_acc    <- pg_hdr$accessed
    hdr_size   <- pg_hdr$size
    hdr_url2   <- pg_hdr$url2
    hdr_status <- pg_hdr$status
  } else {
    hdr_server <- hdr_acc <- hdr_size <- hdr_url2 <- hdr_status <- NA
  }
  
  # if using headless chrome, replace page source with chrome document
  if(!is.null(chrome_bin)) pg_dl <- parse_attempt2

  # get attributes from html
  pg_htm       <- if(grepl('file://', url)) read_html(file(url)) else get_html(pg_dl) 
  pg_img       <- get_imgs(pg_htm, hdr_url2)
  pg_lnk       <- get_links(pg_htm, hdr_url2)
  pg_ttl       <- get_title(pg_htm, url = hdr_url2)
  pg_scl       <- get_social(pg_htm)
  pg_lng       <- get_language(pg_htm)
  pg_rss       <- get_rss(pg_htm, url = hdr_url2)
  pg_gen       <- get_generator(pg_htm)
  pg_tim       <- get_time(pg_htm, url = hdr_url2)
  pg_tbl       <- get_tables(pg_htm)
  pg_code_lang <- guess_code_lang(pg_htm)
  
  # source - sometimes coercion to character will fail
  pg_source    <- ifelse(
    keep_source, 
    ifelse(
      'try-error' %in% class(try(as.character(pg_htm), silent = TRUE)),
      NA, 
      as.character(pg_htm)
    ), 
    NA
  )
  
  # combine into list
  pg_features <- 
    list(url    = url, 
         url2   = hdr_url2, 
         rss    = pg_rss, 
         title  = pg_ttl, 
         links  = pg_lnk,
         tables = pg_tbl,
         source = pg_source,
         social = pg_scl,
         images = pg_img, 
         generator = pg_gen, 
         lang = pg_lng, 
         server = hdr_server, 
         size = hdr_size,
         accessed = hdr_acc,
         published = pg_tim,
         code_lang = pg_code_lang, 
         status    = hdr_status)
  
  return(pg_features)
}
