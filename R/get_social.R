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
  #
  # twitter handles and profile pages
  twitter_handle  <- links %>% 
    gsub(',', '', .) %>%
    grep('(?<!developer\\.)twitter\\.com/', .,  value = TRUE, perl = TRUE) %>%
    gsub('\\?(.*)', '', .) %>% # remove query components
    gsub('/status/(.*)|/statuses/(.*)', '', .) %>% # remove status
    grep('twitter.com/(?!share$)(?!status/)(?!search$)(?!hashtag/)(?!intent/)', 
         ., value = TRUE, perl = TRUE) %>%
    gsub('http://', 'https://', .) %>% # use secure http
    gsub('www\\.twitter\\.com', 'twitter.com', .) %>% # remove the 'www.'
    gsub('https://twitter.com/|#!/', '@', .) %>%# drop scheme and domain, leaving handle
    unique(.) %>%
    sort(.) 
  twitter_profile  <- paste0('https://twitter.com/', gsub('@', '', twitter_handle))
  twitter_df <- tibble(site = 'twitter', handle = twitter_handle, profile = twitter_profile)
  
  #
  # github links handles and profile pages
  github_profile  <- links %>% 
    grep('https://github.com/(?!security$)(?!events$)(?!about$)(?!pricing$)(?!contact$)(?!.*/)([a-z0-9]+)', 
         ., value = TRUE, perl = TRUE)
  github_handle   <- gsub('https://github.com/', '@', github_profile)
  github_df <- tibble(site = 'github', handle = github_handle, profile = github_profile)
  # combine and return a dataframe
  social   <- bind_rows(twitter_df, github_df)
  
  # # linkedin links
  # linkedin <- links %>% grep('linkedin.com/', ., value = TRUE)
  # linkedin_df <- tibble(site = 'linkedin', handle = linkedin)

  # social   <- lapply(social, function(v){if(length(v) == 0) v <- NA; v})
  return(social)
}

get_social <- function(page){
  soc_df <- try(get_social_links(page), silent = TRUE)
  if(!'try-error' %in% class(soc_df)){
    social_df <- soc_df
  } else {
    social_df <- tibble(site = character(), handle = character())
  }
  return(social_df)
}


