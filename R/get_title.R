#' @importFrom rvest html_nodes
#' @importFrom rvest html_text
#' @importFrom urltools path
get_title <- function(page, url){
  # initialise title_out as NA
  title_out <- NA
  if('xml_document' %in% class(page)){
    # attempt to read page title from title tag
    text_nodes <- function(page, node) page %>% html_nodes(node) %>% html_text()
    title      <- try(unlist(sapply(c('title', 'h1', 'h2', 'h3'), text_nodes, page = page)), silent = TRUE)
    if(length(title) > 0) title <- title[nchar(title, type = 'bytes') > 0]
    # if no error in fetching title, and there is something there...
    if((!'try_error' %in% class(title)) & (length(title) > 0)) title_out <- title[1]
    # if this is a Github repo, use the repo name as the page title
    if(grepl('https://github\\.com', url)){
      gh_title     <- github_title_read(page)
      title_out    <- ifelse(length(gh_title) > 0, gh_title, title[1])
      url_bits     <- unlist(strsplit(path(url), '/'))
      repo_name    <- url_bits[length(url_bits)]
      title_out    <- paste0(repo_name, ' \u2022 ', title_out)
      # tidy up github titles
      title_out    <- gsub('GitHub -(.*)\\: ', '', title_out)
      # replace dashes with bullets
      title_out    <- gsub(' - |: ', ' \u2022 ', title_out)
    }
    title_out <- clean_string(title_out)
  } 
  return(title_out)
}

github_title_read <- function(html_doc){
  txt <- html_doc %>%
    html_nodes(xpath = '//*[@id="js-repo-pjax-container"]/div[2]/div/div[2]/div/span[1]') %>%
    html_text() %>%
    gsub('  |\n', '', .)
  return(txt)
}
