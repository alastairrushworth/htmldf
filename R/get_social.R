#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_social_links <- function(page){
  x <- page %>% read_html()
  links    <- x %>% html_nodes("a") %>% html_attr('href')
  twitter  <- links %>% grep('twitter.com/(?!search.*)(?!.*/)', .,  value = TRUE, perl = TRUE)
  linkedin <- links %>% grep('linkedin.com/', ., value = TRUE)
  github   <- links %>% grep('https://github.com/(?!security$)(?!events$)(?!about$)(?!pricing$)(?!contact$)(?!.*/)([a-z0-9]+)', ., value = TRUE, perl = TRUE)
  linklist <- lapply(list(twitter, github, linkedin), paste, collapse = ",")
  social   <- tibble(twitter = linklist[[1]], github = linklist[[2]], linkedin = linklist[[3]])
  return(social)
}

get_social <- function(pages){
  social_list <- vector("list", length = length(pages))
  for(i in seq_along(pages)){
    soc_df <- try(get_social_links(pages[[i]]), silent = TRUE)
    if(!'try-error' %in% class(soc_df)){
      social_list[[i]] <- soc_df
    } else {
      social_list[[i]] <- tibble(github = NA, twitter = NA, linkedin = NA)
    }
  }
  social_df <- bind_rows(social_list)
  return(social_df)
}
