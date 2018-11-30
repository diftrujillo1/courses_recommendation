library(tidyverse)
library(rvest)
library(curl)

df_instructors_ref <- read_csv('data/directory_references_coursera.csv') %>% 
  filter(name_directory == 'Instructors')

ref <- df_instructors_ref$url_references_directory
names <- df_instructors_ref$name_references_directory

list_df_info <- map(seq_along(ref)[1:100], function(cont){
  
  if(cont %% 50 == 0) print(cont)
  message(cont)
  url_page <- ref[cont]
  
  page_read <- read_html(url_page)
  
  instructor_label <- page_read %>% 
    html_node('.Col_i9j08c-o_O-smCol7_1j1y18e-o_O-mdCol6_1rbv01c p') %>% 
    html_text(trim = TRUE)
  
  instructor_company <- page_read %>% 
    html_node('.Col_i9j08c-o_O-smCol7_1j1y18e-o_O-mdCol6_1rbv01c a') %>% 
    html_text(trim = TRUE)
    
  instructor_link <- page_read %>% 
    html_nodes('.m-l-1s') %>% 
    html_attr('href') %>% 
    paste(., collapse = ', ')
  
  instructor_bio <- page_read %>% 
    html_node('.Col_i9j08c-o_O-smCol12_s10s1s-o_O-mdCol12_vi0cxf p') %>% 
    html_text(trim = TRUE)
    
  instructor_courses <- page_read %>% 
    html_nodes('.H4_1k76nzj-o_O-weightNormal_s9jwp5-o_O-fontBody_56f0wi div') %>% 
    html_text(trim = TRUE) %>% 
    unique(.)
  
  instructor_number_courses <- length(instructor_courses)
  
  instructor_courses <- instructor_courses %>% 
    paste(., collapse = ', ')
  
  df_instructor <- data.frame(instructor_label = instructor_label,
                              instructor_company = instructor_company,
                              instructor_courses = instructor_courses,
                              instructor_number_courses = instructor_number_courses,
                              instructor_bio = instructor_bio,
                              instructor_link = instructor_link)
  
  df_instructor$instructor_name <- names[cont]
    
  return(df_instructor)
  
})
 