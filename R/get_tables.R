
#' @importFrom dplyr arrange
#' @importFrom dplyr desc
#' @importFrom rvest html_nodes
#' @importFrom rvest html_table
#' @importFrom rvest html_text
#' @importFrom tibble tibble
#' @importFrom xml2 read_html

get_tables <- function(html_content){
  # get tables from the page source
  tables <- try(
    html_content %>%
      html_nodes('table'), 
    silent = TRUE)
  table_out <- NA
  if(!'try-error' %in% class(tables)){
    if(length(tables) > 0){
      # gather captions, sort tables descending by size
      vv        <- lapply(tables, table_to_tibble)
      tbl_list  <- lapply(vv, function(v) v[[1]])
      capt_vec  <- sapply(vv, function(v) ifelse(length(v) == 2, ifelse(length(v[[2]]) > 0, v[[2]], 'no-caption'), 'uncoercible'))
      tbl_size  <- sapply(vv, function(v) ifelse('data.frame' %in% class(v), prod(dim(v[[1]])), 0))
      tbl_tbl   <- 
        tibble(table = tbl_list, caption = capt_vec, table_size = tbl_size) %>% 
        arrange(desc(table_size))
      table_out <- tbl_tbl$table
      names(table_out) <- tbl_tbl$caption
    }
  }
  return(table_out)
}

table_to_tibble <- function(v){
  table_tibble <- 
    try(suppressWarnings(suppressMessages(html_table(v))), silent = TRUE)
  table_caption <- 
    try(v %>%
          html_nodes('caption') %>%
          html_text(), 
        silent = TRUE)
  if('try-error' %in% class(table_tibble)){
    return(as.character(v))
  } else {
    return(list(table_tibble, table_caption))
  }
}
