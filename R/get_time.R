#' @importFrom rvest html_nodes
#' @importFrom rvest html_attr
#' @importFrom stats na.omit

# extract publication or last updated dates from page
get_time <- function(page, url){
  if('xml_document' %in% class(page)){
    # try last commit date tag if it's a github page
    pub_time <- try(
      c(page %>% 
        html_nodes('div[class="d-flex flex-auto flex-justify-end ml-3 flex-items-baseline"]') %>%
        html_nodes('a') %>%
        html_nodes('relative-time') %>%
        html_attr('datetime'), 
        page %>% 
          html_nodes('time') %>%
          html_attr('datetime')
      ),
      silent = TRUE
    )
    pub_time <- as.vector(na.omit(ifelse('try-error' %in% class(pub_time), NA, pub_time)))
    # look for meta tags if it's not github
    if(length(pub_time) == 0){
      # check first if there are any times in the page header
      time_tags <- c(
        'meta[property="article:published_time"]', 
        'meta[property="og:updated_time"]',
        'meta[property="article:published"]', 
        'meta[property="article:created"]', 
        'meta[itemprop="datePublished"]',
        'meta[name="citation_online_date"]'
      )
      pub_time  <- as.vector(na.omit(unlist(lapply(time_tags, get_tags, page = page))))
    }
    # if no header times, then check for other stuff
    if(length(pub_time) == 0){
      node_list <- c(
        "h2[class='date-header']",
        "span[class='date-container minor-meta meta-color']",
        "span[class='postdate']",
        "time", 
        "p[class='dateline']",
        "div[class='date']",
        "i[class='fa fa-calendar-o']", 
        "span[class='post-meta']", 
        "p",
        "h4"
      )
      pub_time  <-  as.vector(na.omit(unlist(lapply(node_list, get_time_text, page = page))))
    }
    # remove anything with too many characters
    if(length(pub_time) > 0) pub_time <- na.omit(pub_time[nchar(iconv(pub_time, to = 'UTF-8')) < 10^6])
    if(length(pub_time) > 0){
      pub_time <- unique(pub_time)
      pub_time <- unlist(strsplit(pub_time, '\n'))
      date_patterns <- c("d m y", "d B Y", "m/d/y", "Y/m/d", 'd b Y HM', 
                         'b d', 'Y-m-dH:M:S', "ymdTz", "ymdT", "Y-m-d")
      pub_time <- suppressWarnings(try(parse_date_time(pub_time, orders = date_patterns), silent = TRUE))
      if("try-error" %in% class(pub_time)) pub_time <- NA
      pub_time <- na.omit(pub_time)
      if(length(pub_time) > 1) pub_time  <- pub_time[1]
    } else {
      pub_time <- NA
    }
  } else {
    pub_time <- NA
  }
  pub_time <- ifelse(length(pub_time) == 0, as.character(NA), as.character(pub_time))
  return(pub_time)
}

get_tags  <- function(tag, page){
  tag_chr <- try(
    page %>% 
      html_nodes(tag) %>% 
      html_attr('content'), 
    silent = TRUE
  )
  tag_chr <- ifelse('try-error' %in% class(tag_chr) | is.na(tag_chr), NA, tag_chr)
  return(tag_chr)
}

get_time_text <- function(tag, page){
  tag_chr <- try(
    page %>% 
      html_nodes(tag) %>% 
      html_text(), 
    silent = TRUE
  )
  tag_chr <- ifelse('try-error' %in% class(tag_chr) | is.na(tag_chr), NA, tag_chr)
  return(tag_chr)
}
  