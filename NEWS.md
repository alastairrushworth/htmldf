### v0.5.0 // 
+ Improvement to table parsing inherited from recent changes in `rvest::html_table()`
+ `retry_times` argument to allow retrying of URLs after failure
+ Ellipsis added  `html_df()` to allow passing of extra arguments to `GET` request
+ `chrome_args` argument added for passing command line arguments to Chromium
+ Increased default timeout parameter to 30s

### v0.4.0 // 17-08-2021
+ Allow simple use of headless chrome via `chrome_bin` argument
+ HTTP status column added
