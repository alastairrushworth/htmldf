#' @export
#' @importFrom rvest html_nodes
#' @importFrom rvest html_text
#' @importFrom urltools path
get_title <- function(page, urls){
  n_page     <- length(page)
  title_out  <- vector('character', length = n_page)
  pb         <- start_progress(prefix = "Page titles", total = n_page)
  for(i in 1:n_page){
    update_progress(bar = pb, iter = i, total = n_page, what = '')
    if('xml_document' %in% class(page[[i]])) {
      title <- try(page[[i]] %>% html_nodes('title') %>% html_text(), silent = TRUE)
      if(length(title) > 0){
        title_out[i] <- title[1]
        # if this is a Github repo, paste in the repo name
        if(grepl('https://github\\.com', urls[i])){
          gh_title <- github_title_read(page[[i]])
          title_out[i] <- ifelse(length(gh_title) > 0, gh_title, title[1])
          url_bits <- unlist(strsplit(path(urls[i]), '/'))
          repo_name <- url_bits[length(url_bits)]
          title_out[i] <- paste0(repo_name, ' • ', title_out[i])
        }
      } else {
        title_out[i] <- NA
      }
    } else {
      title_out[i] <- NA
    }
    if('try_error' %in% class(title_out[i])){
      title_out[i] <- NA
    }
  }
  # tidy up Github titles
  title_out <- gsub('GitHub -(.*)\\: ', '', title_out)
  # tidy up titles with html tags
  title_out <- gsub('\\\n|\\\t|\\\r', '', title_out)
  # replace dashes with bullets
  title_out <- gsub(' - |: | – ', ' • ', title_out)
  return(title_out)
}

github_title_read <- function(html_doc){
  txt <- html_doc %>%
    html_nodes(xpath = '//*[@id="js-repo-pjax-container"]/div[2]/div/div[2]/div/span[1]') %>%
    html_text() %>%
    gsub('  |\n', '', .)
  return(txt)
}
