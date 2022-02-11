#' @importFrom dplyr bind_rows
#' @importFrom dplyr filter
#' @importFrom dplyr distinct
#' @importFrom dplyr arrange
#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom stringr str_extract
#' @importFrom tools file_ext
#' @importFrom xml2 url_absolute
#' @importFrom xml2 xml_url
#' @importFrom xml2 read_html

get_social_links <- function(html_content){
  # get a tags
  links    <- html_content %>% html_nodes("a") %>% html_attr('href') %>% unique()
  
  # TWITTER HANDLES FROM EMBEDDED LINKS
  tw_links <- twitter_handles_from_urls(links)
  # TWITTER HANDLES FROM TAGS
  tw_attrs <- c(
    'meta[name="twitter:site"]', 
    'meta[name="twitter:creator"]', 
    'meta[property="twitter:site"]', 
    'meta[property="twitter:creator"]')
  tw_tags  <- unlist(sapply(tw_attrs, function(v) html_content %>% html_nodes(v) %>% html_attr('content') %>% tolower()))
  tw_tags  <- gsub('https://twitter.com/', '', tw_tags)
  # COMBINE ALL HANDLES
  tw_hndl  <- c(tw_tags, tw_links) %>% gsub('@@', '@', .) %>% unique() %>% sort() 
  # COMINE TWITTER PROFILES INTO A DF
  twitter_df       <- 
    tibble(site = 'twitter', 
           handle = tw_hndl, 
           profile = paste0('https://twitter.com/', gsub('@', '', tw_hndl))
    ) %>%
    filter(nchar(handle) > 0)
  
  social_df <- function(links, instructions){
    if(!instructions$case_sense) links <- tolower(links)
    matches <- 
      links %>% 
      grep(instructions$pattern, ., perl = TRUE, value = TRUE) %>%
      gsub('\\?(.*)', '', .)
    if(!is.null(instructions$gexclude)) if(length(matches) > 0) matches <- matches[!grepl(instructions$gexclude, matches)]
    if(!is.null(instructions$max_segments)){
      if(length(matches) > 0){
        x <- strsplit(matches, '/')
        x <- lapply(x, function(v) v[1:(ifelse(length(v) > (instructions$max_segments + 2), instructions$max_segments + 2, length(v)))]) 
        x <- lapply(x, paste0, collapse = "/")
        matches <- unlist(x)
      }
    }
    if(!is.null(instructions$gexclude)) if(length(matches) > 0) matches <- matches[!grepl(instructions$gexclude, matches)]
    handles <- 
      matches %>%
      gsub(instructions$slug, ifelse(instructions$at_profile, '@', ''), .) %>%
      gsub('\\/$', '', .) 
    if(!is.null(instructions$gsub2)){
      handles <- gsub(instructions$gsub2, '', handles)
    }
    if(!is.null(instructions$slug_add)){
      if(instructions$slug_add == 'auto'){
        slug_bits <- xml2::url_parse(matches)
        profiles  <- paste0(slug_bits$scheme, '://', slug_bits$server, '/', handles)
      } else if(is.character(instructions$slug_add)){
        profiles <- paste0(instructions$slug_add, gsub('@', '', handles))
      }
    } else {
      profiles <- handles
    }
      
    out_df   <- tibble(
      site = instructions$site, 
      handle = handles, 
      profile = profiles
    ) %>%
      distinct(handle, .keep_all = TRUE) %>%
      arrange(site, handle)
    return(out_df)
  }
  
  non_twitter_social <- bind_rows(lapply(social_patterns, social_df, links = links))

  social <- 
    bind_rows(twitter_df, non_twitter_social) %>%
    filter(handle != '@')
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
  
  # get list of twitter urls from all document links
  twitter_links <- urlx %>% 
    gsub(',', '', .) %>%
    grep('(?<!developer\\.)twitter\\.com/', .,  value = TRUE, perl = TRUE) %>%
    gsub('\\?(.*)', '', .) # remove query components
  
  # extract handles from URLs
  handles <- twitter_links %>% 
    grep('twitter.com/(?!share$)(?!status/)(?!search$)(?!hashtag/)(?!intent/)', 
         ., value = TRUE, perl = TRUE) %>%
    str_extract(., '(?<=twitter\\.com/).*') %>%
    gsub('/status/(.*)|/statuses/(.*)|/with_replies(.*)|/followers/(.*)|/following/(.*)', '', .) %>% # remove status
    strsplit(., split = '/') %>%
    lapply(., function(x) x[1]) %>%
    unlist(.) %>%
    tolower(.) %>%
    unique(.)   %>%
    paste0('@', .)
  
  # remove anything with fewer than 4 characters
  if(length(handles) > 0) handles <- handles[nchar(handles) >= 5]
  
  # return vector of handles
  return(handles)
}



social_patterns <- list(

  'bitbucket' = list(
    pattern    = 'https?://(www.)?bitbucket.org/', 
    slug       = 'https?://(www.)?bitbucket.org/',
    slug_add   = 'https://bitbucket.org/',
    site       = 'bitbucket',
    at_profile = TRUE,
    case_sense = FALSE
  ), 

  'devto' = list(
    pattern    = 'https?://(www.)?dev.to/', 
    slug       = 'https?://(www.)?dev.to/',
    slug_add   = 'https://dev.to/',
    site       = 'devto',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'discord' = list(
    pattern    = 'https?://(www.)?discord.gg/|https?://(www.)?discordapp.com/invite/',
    slug       = 'https?://(www.)?discord.gg/',
    slug_add   = 'https://discord.gg/',
    site       = 'discord',
    at_profile = TRUE,
    case_sense = TRUE
  ),

  'facebook' = list(
    pattern    = 'https?://(www.)?facebook.com/(?!sharer)', 
    slug       = 'https?://(www.)?facebook.com/',
    slug_add   = 'https://facebook.com/',
    site       = 'facebook',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'gitlab' = list(
    pattern    = 'https?://(www.)?gitlab.com/', 
    slug       = 'https?://(www.)?gitlab.com/',
    slug_add   = 'https://gitlab.com/',
    site       = 'gitlab',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'github' = list(
    pattern    = 'https?://(www.)?github.com/(?!security(\\/|$))(?!events(\\/|$))(?!about(\\/|$))(?!pricing(\\/|$))(?!contact(\\/|$))(?!site(\\/|$))', 
    slug       = 'https?://(www.)?github.com/',
    slug_add   = 'https://github.com/',
    gsub2      =  "\\/.*",
    site       = 'github',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'instagram' = list(
    pattern    = 'https?://(www.)?instagram.com/(?!sharer)', 
    slug       = 'https?://(www.)?instagram.com/',
    slug_add   = 'https://instagram.com/',
    site       = 'instagram',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'kakao' = list(
    pattern    = 'https?://(www.)?open.kakao.com/o/',
    slug       = 'https?://(www.)?open.kakao.com/o/',
    slug_add   = 'https://open.kakao.com/o/',
    site       = 'kakao',
    at_profile = TRUE,
    case_sense = FALSE
  ),
  
  'keybase' = list(
    pattern    = 'https?://(www.)?keybase.io/', 
    slug       = 'https?://(www.)?keybase.io/',
    slug_add   = 'https://keybase.io/',
    site       = 'keybase',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'linkedin' = list(
    pattern    = 'https?://(www.)?linkedin.com/(?!sharearticle)', 
    slug       = 'https?://(www.)?linkedin.com/',
    slug_add   = 'https://linkedin.com/',
    site       = 'linkedin',
    at_profile = TRUE,
    case_sense = FALSE
  ), 
  
  'mastodon' = list(
    pattern    = 'https?://(www.)?mastodon\\.(\\w+)\\/',
    slug       = 'https?://(www.)?mastodon\\.(\\w+)\\/',
    slug_add   = 'auto',
    site       = 'mastodon',
    at_profile = FALSE,
    case_sense = FALSE
  ),

  'medium1' = list(
    pattern    = 'https?://(www.)?medium.com/(?!/m/signin(\\/|))(?!events(\\/|))(?!membership(\\/|))(?!about(\\/|))(?!topics(\\/|))(?!contact(\\/|))(?!site(\\/|))',
    slug       = 'https?://(www.)?medium.com/',
    slug_add   = 'https://medium.com/',
    site       = 'medium',
    gsub2      = '\\./*|\\?.*',
    at_profile = FALSE,
    case_sense = TRUE, 
    gexclude   = '^https://medium.com/m?$',
    max_segments = 2
  ),
  
  'medium2' = list(
    pattern    = 'https://(www.)?(\\w+).medium.com/',
    slug       = 'https://(www.)?(\\w+).medium.com/',
    slug_add   = NULL,
    site       = 'medium',
    at_profile = FALSE,
    case_sense = TRUE, 
    gexclude   = 'https://(policy|help|about).medium.com/',
    max_segments = 1
  ),

  'orcid' = list(
    pattern    = 'https?://(www.)?orcid.org/(\\d+-?)+\\d+|https://orcid.org/(\\d+-?)+\\d+', 
    slug       = 'https?://(www.)?orcid.org/',
    slug_add   = 'https://orcid.org/',
    site       = 'orcid',
    at_profile = FALSE,
    case_sense = FALSE
  ),
  
  'patreon' = list(
    pattern    = 'https?://(www.)?patreon.com/', 
    slug       = 'https?://(www.)?patreon.com/',
    slug_add   = 'https://patreon.com/',
    site       = 'patreon',
    at_profile = TRUE,
    case_sense = FALSE
  ),

  'reddit-community' = list(
    pattern    = 'https?://(www.)?reddit.com/r/',
    slug       = 'https?://(www.)?reddit.com/r/',
    slug_add   = 'https://reddit.com/r/',
    site       = 'reddit-community',
    gsub2      = "\\/comments/.*",
    at_profile = FALSE,
    case_sense = TRUE
  ),

  'reddit-user' = list(
    pattern    = 'https?://(www.)?reddit.com/u(ser)?/',
    slug       = 'https?://(www.)?reddit.com/u(ser)?/',
    slug_add   = 'https://reddit.com/user/',
    site       = 'reddit-user',
    gsub2      = "\\/comments/.*",
    at_profile = FALSE,
    case_sense = TRUE
  ),
  
  'researchgate' = list(
    pattern    = 'https?://(www.)?researchgate.net/profile/', 
    slug       = 'https?://(www.)?researchgate.net/profile/',
    slug_add   = 'https://researchgate.net/profile/',
    site       = 'researchgate',
    at_profile = TRUE,
    case_sense = TRUE
  ),
  
  'stackoverflow' = list(
    pattern    = 'https?://(www.)?stackoverflow.com/users/', 
    slug       = 'https?://(www.)?stackoverflow.com/users/',
    slug_add   = 'https://stackoverflow.com/users/',
    site       = 'stackoverflow',
    at_profile = TRUE,
    case_sense = FALSE
  ),
  
  'telegram' = list(
    pattern    = 'https?://(www.)?t.me/',
    slug       = 'https?://(www.)?t.me/',
    slug_add   = 'https://t.me/',
    site       = 'telegram',
    at_profile = TRUE,
    case_sense = FALSE
  ),

  # 'vimeo' = list(
  #   pattern    = 'https?://(www.)?vimeo.com/', 
  #   slug       = 'https?://(www.)?vimeo.com/',
  #   slug_add   = 'https://vimeo.com/',
  #   site       = 'vimeo',
  #   at_profile = TRUE,
  #   case_sense = FALSE
  # ),
  # 
  'youtube' = list(
    pattern    = 'https?://(www.)?youtube.com/channel/', 
    slug       = 'https?://(www.)?youtube.com/channel/',
    slug_add   = 'https://youtube.com/channel/',
    site       = 'youtube',
    at_profile = FALSE,
    case_sense = TRUE
  )
)




