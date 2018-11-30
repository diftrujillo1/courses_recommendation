library(tidyverse)
library(rvest)
library(curl)

home <- 'https://www.coursera.org'
platform <- 'Coursera'
directory <- 'https://www.coursera.org/directory'

page_directory <- read_html(directory)

items <- page_directory %>% 
  html_nodes('.c-resource-button , .c-selected') %>% 
  html_text(trim = TRUE) 

ref <- page_directory %>% 
    html_nodes('.c-resource-button , .c-selected') %>% 
    html_attr('href')

ref <- paste0(home, ref)
ref[1] <- 'https://www.coursera.org/directory/degrees'

list_directory <- map(ref, function(ref_test){

  ref_test_page <- read_html(ref_test)
  
  alcance <- NULL
  try({
    alcance <- ref_test_page %>% 
      html_nodes('.number') %>% 
      html_text(trim = TRUE) %>% 
      as.numeric(.) 
    if(identical(alcance, numeric(0))){
      alcance <- 1
    }
    else{
      alcance <- alcance %>% max(.)
    }
  })
  
  pages <- seq(1:alcance)
  ref_test_alcance <- paste0(ref_test, '?page=', pages)
  
  list_df_specializations_ref <- map(ref_test_alcance, function(url){
    
    page_read <- read_html(url)
    
    ref_directory_item <- page_read %>%
      html_nodes('.c-directory-link') %>% 
      html_attr('href') %>% 
      paste0(home, .)
    
    name_directory_item <- page_read %>%
      html_nodes('.c-directory-link') %>% 
      html_text(trim = TRUE)
  
    df_directory <- data.frame(url_references_directory = ref_directory_item,
                               name_references_directory = name_directory_item)
  
    df_directory$url_directory <- url
    df_directory$name_directory <- items[which(ref_test == ref)]
    return(df_directory)
  })
  
  df_directory_item <- bind_rows(list_df_specializations_ref)
  gc()
  return(df_directory_item)
})

df_directory <- bind_rows(list_directory)

df_directory$platform <- platform
write_csv(df_directory, 'data/directory_references_coursera.csv')





