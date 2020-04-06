#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_social_links <- function(html_content){
  links    <- html_content %>% html_nodes("a") %>% html_attr('href') %>% tolower() %>% unique()
  # remove empty links
  links <- links[!links == '']
  # twitter links - remove shares and queries
  twitter  <- links %>% 
    gsub(',', '', .) %>%
    grep('(?<!developer\\.)twitter\\.com/', .,  value = TRUE, perl = TRUE) %>%
    gsub('\\?(.*)', '', .) %>% # remove query components
    gsub('/status/(.*)|/statuses/(.*)', '', .) %>% # remove status
    grep('twitter.com/(?!share$)(?!status/)(?!search$)(?!hashtag/)(?!intent/)', 
         ., value = TRUE, perl = TRUE) %>%
    gsub('http://', 'https://', .) %>% # use secure http
    gsub('www\\.twitter\\.com', 'twitter.com', .) %>% # remove the 'www.'
    gsub('https://twitter.com/', '@', .) %>%# drop scheme and domain, leaving handle
    unique(.) %>%
    sort(.) 
  # linkedin links
  linkedin <- links %>% grep('linkedin.com/', ., value = TRUE)
  # github links
  github   <- links %>% grep('https://github.com/(?!security$)(?!events$)\
                             (?!about$)(?!pricing$)(?!contact$)(?!.*/)([a-z0-9]+)', 
                             ., value = TRUE, perl = TRUE)
  # combine and return a dataframe
  social   <- tibble(twitter  = list(twitter), 
                     github   = list(github), 
                     linkedin = list(linkedin))
  return(social)
}

get_social <- function(html_list, show_progress = TRUE){
  if(show_progress) message('Finding social handles...\r', appendLF = FALSE)
  social_list <- vector("list", length = length(html_list))
  for(i in seq_along(html_list)){
    soc_df <- try(get_social_links(html_list[[i]]), silent = TRUE)
    if(!'try-error' %in% class(soc_df)){
      social_list[[i]] <- soc_df
    } else {
      social_list[[i]] <- tibble(github = NA, twitter = NA, linkedin = NA)
    }
  }
  social_df <- bind_rows(social_list)
  return(social_df)
}



