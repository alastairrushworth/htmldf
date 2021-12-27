

  
test_1 <- function(n){
  test_list   <- vector('list', length = n)
  for(i in 1:length(test_list)){
    if(i %% 100 == 0) message(i)
    test_list[[i]] <- list(paste(rep(paste(letters, collapse = 'yayayayay'), 1000), collapse = 'rrbb'))
  }
  return(test_list)
}
ss <- test_1(10000)

url = 'https://github.com/alastairushworth/inspectdf'
dd <- httr::GET(url)
