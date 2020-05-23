#' @importFrom dplyr bind_rows
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_social_links <- function(html_content){
  # get a tags
  links    <- html_content %>% html_nodes("a") %>% html_attr('href') %>% tolower() %>% unique()
  
  #
  # TWITTER HANDLES AND PAGES
  tw_attr_urlx  <- twitter_handles_from_urls(links) 
  tw_attr_meta1 <- html_content %>% html_nodes('meta[name="twitter:site"]') %>% html_attr('content') %>% tolower()
  tw_attr_meta2 <- html_content %>% html_nodes('meta[name="twitter:creator"]') %>% html_attr('content') %>% tolower()
  twitter_handle <- gsub('@@', '@', c(tw_attr_urlx, tw_attr_meta1, tw_attr_meta2)) %>% unique() %>% sort()
  # add scheme and site root for full profile url
  twitter_profile  <- paste0('https://twitter.com/', gsub('@', '', twitter_handle))
  twitter_df       <- tibble(site = 'twitter', handle = twitter_handle, profile = twitter_profile)
  
  #
  # LINKEDIN HANDLES AND PAGES
  li_attr_urlx  <- linkedin_handles_from_urls(links) 
  linkedin_profile  <- paste0('https://linkedin.com/in/', gsub('@', '', li_attr_urlx))
  linkedin_df <- tibble(site = 'linkedin', handle = li_attr_urlx, profile = linkedin_profile)
  
  #
  # GITHUB HANDLES AND PAGES
  gh_attr_urlx  <- github_handles_from_urls(links) 
  github_profile  <- paste0('https://github.com/', gsub('@', '', gh_attr_urlx))
  github_df <- tibble(site = 'github', handle = gh_attr_urlx, profile = github_profile)
  
  # COMBINE THE PROFILES AND RETURN AS SINGLE DF
  social   <- bind_rows(twitter_df, linkedin_df, github_df)
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

# function to get twitter handles from twitter urls
twitter_handles_from_urls <- function(urlx){
  handles <- urlx %>% 
    gsub(',', '', .) %>%
    grep('(?<!developer\\.)twitter\\.com/', .,  value = TRUE, perl = TRUE) %>%
    gsub('\\?(.*)', '', .) %>% # remove query components
    gsub('/status/(.*)|/statuses/(.*)|/with_replies(.*)|/followers/(.*)|/following/(.*)', '', .) %>% # remove status
    grep('twitter.com/(?!share$)(?!status/)(?!search$)(?!hashtag/)(?!intent/)', 
         ., value = TRUE, perl = TRUE) %>%
    gsub('http://', 'https://', .) %>% # use secure http
    gsub('www\\.twitter\\.com', 'twitter.com', .) %>% # remove the 'www.'
    gsub('https://twitter.com/|#!/', '@', .) %>% # remove handles that appear as 18 digit numbers
    tolower() %>% unique() 
  return(handles)
}

# function to get twitter handles from twitter urls
linkedin_handles_from_urls <- function(urlx){
  handles <- urlx %>% 
    grep('linkedin.com/', ., value = TRUE) %>% 
    grep('linkedin.com/(?!sharearticle)', ., value = TRUE, perl = TRUE) %>% # remove article shares
    gsub('https://www.linkedin.com/in/', '@', .) %>% # replace the main site w/ @
    gsub('\\/$', '', .) %>% # drop trailing backslash
    tolower() %>% unique() %>% sort()
  return(handles)
}

# function to get twitter handles from twitter urls
github_handles_from_urls <- function(urlx){
  handles <- urlx %>% 
    grep('https://github.com/(?!security$)(?!events$)(?!about$)(?!pricing$)(?!contact$)(?!.*/)([a-z0-9]+)', 
         ., value = TRUE, perl = TRUE) %>%
    gsub('https://github.com/', '@', .) %>%
    gsub('\\/$', '', .) %>% # drop trailing backslash
    tolower() %>% unique() %>% sort()
  return(handles)
}


# pp <- httr::GET('https://colinfay.me/') %>%
#   read_html() %>%
#   html_nodes('a') %>%
#   html_attr('href') %>%
#   grep('github', ., value = TRUE) %>%
#   unique() %>% tolower()
# pp
# pp %>% github_handles_from_urls()



