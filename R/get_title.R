#' @importFrom rvest html_nodes
#' @importFrom rvest html_text
#' @importFrom urltools path
get_title <- function(page, url){
  if('xml_document' %in% class(page)) {
    title <- try(page %>% html_nodes('title') %>% html_text(), silent = TRUE)
    if(length(title) > 0){
      title_out <- title[1]
      # if this is a Github repo, use the repo name as the page title
      if(grepl('https://github\\.com', url)){
        gh_title     <- github_title_read(page)
        title_out    <- ifelse(length(gh_title) > 0, gh_title, title[1])
        url_bits     <- unlist(strsplit(path(url), '/'))
        repo_name    <- url_bits[length(url_bits)]
        title_out    <- paste0(repo_name, ' • ', title_out)
      }
    } else {
      title_out <- NA
    }
  } else {
    title_out <- NA
  }
  if('try_error' %in% class(title_out)){
    title_out <- NA
  }
  # tidy up Github titles
  title_out <- gsub('GitHub -(.*)\\: ', '', title_out)
  # tidy up titles with html tags
  title_out <- gsub('\\\n|\\\t|\\\r', '', title_out)
  # replace dashes with bullets
  title_out <- gsub(' - |: | – ', ' • ', title_out)
  # remove trailling / leading white space
  title_out <- gsub('^\\s+|\\s+$', '', title_out)
  return(title_out)
}

github_title_read <- function(html_doc){
  txt <- html_doc %>%
    html_nodes(xpath = '//*[@id="js-repo-pjax-container"]/div[2]/div/div[2]/div/span[1]') %>%
    html_text() %>%
    gsub('  |\n', '', .)
  return(txt)
}
