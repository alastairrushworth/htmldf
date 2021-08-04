.onLoad <- function(libname = find.package("inspectdf"), pkgname = "inspectdf"){
  
  # CRAN Note avoidance
  if(getRversion() >= "2.15.1")
    utils::globalVariables(c(".", "accessed",  "code_lang", "generator","images", "lang", "links",
                             "predict", "published", "rss", "server", "size",  "social", 
                             "title", "url2", "value", "handle", "site", "table_size", "tables"))
  invisible()
}