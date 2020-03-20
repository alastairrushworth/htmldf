#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_social_links <- function(page){
  x <- page %>% read_html()
  links    <- x %>% html_nodes("a") %>% html_attr('href') %>% tolower() %>% unique()
  # remove empty links
  links <- links[!links == '']
  # twitter links - remove shares and queries
  twitter  <- links %>% 
    gsub(',', '', .) %>%
    grep('(?<!developer\\.)twitter\\.com/', .,  value = TRUE, perl = TRUE) %>%
    gsub('\\?(.*)', '', .) %>% # remove query components
    gsub('/status/(.*)|/statuses/(.*)', '', .) %>% # remove status
    grep('twitter.com/(?!share$)(?!status/)(?!search$)(?!hashtag/)(?!intent/)', ., value = TRUE, perl = TRUE) %>%
    gsub('http://', 'https://', .) %>% # use secure http
    gsub('www\\.twitter\\.com', 'twitter.com', .) %>% # remove the 'www.'
    unique(.) %>%
    sort(.)
  # linkedin links
  linkedin <- links %>% grep('linkedin.com/', ., value = TRUE)
  # github links
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



