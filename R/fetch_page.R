#' @importFrom httr GET
#' @importFrom httr timeout

fetch_page <- function(url, time_out, max_size, keep_source, chrome_bin){
  # attempt to read from  url
  if(is.null(chrome_bin)){
    parse_attempt <- try(httr::GET(url, httr::timeout(time_out)), silent = TRUE)
  } else {
    parse_attempt <- try(
      chrome_read_html(
        url, 
        timeout = time_out, 
        chrome_bin = chrome_bin), 
      silent = TRUE)
  }
  
  # just try again if it fails...
  if(class(parse_attempt) == 'try-error'){
    if(is.null(chrome_bin)){
      parse_attempt <- try(httr::GET(url, httr::timeout(time_out)), silent = TRUE)
    } else {
      parse_attempt <- try(
        chrome_read_html(
          url, 
          timeout = time_out, 
          chrome_bin = chrome_bin), 
        silent = TRUE)
    }
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
    hdr_size   <- pg_hdr$size
    if(!is.null(max_size)){
      if(max_size < pg_hdr$size){
        pg_dl <- NA
        url2  <- NA
      } else {
        url2  <- pg_dl$url
      }
    } else {
      url2  <- pg_dl$url
    }
  } else {
    url2       <- url
    hdr_server <- NA
    hdr_size   <- NA
  }
  
  # get attributes from html
  pg_htm       <- if(grepl('file://', url)) read_html(file(url)) else get_html(pg_dl) 
  pg_img       <- get_imgs(pg_htm, url2)
  pg_lnk       <- get_links(pg_htm, url2)
  pg_ttl       <- get_title(pg_htm, url = url2)
  pg_scl       <- get_social(pg_htm)
  pg_lng       <- get_language(pg_htm)
  pg_rss       <- get_rss(pg_htm, url = url2)
  pg_gen       <- get_generator(pg_htm)
  pg_tim       <- get_time(pg_htm, url = url2)
  pg_tbl       <- get_tables(pg_htm)
  pg_code_lang <- guess_code_lang(pg_htm)
  # source - sometimes coerciion to character will fail
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
    list(url = url, 
         url2 = url2, 
         rss = pg_rss, 
         title = pg_ttl, 
         links = pg_lnk,
         tables = pg_tbl,
         source = pg_source,
         social = pg_scl,
         images = pg_img, 
         generator = pg_gen, 
         lang = pg_lng, 
         server = hdr_server, 
         size = ifelse(is.na(pg_source), NA, as.integer(object.size(pg_source))), 
         accessed = Sys.time(),
         published = pg_tim,
         code_lang = pg_code_lang)
  
  return(pg_features)
}
