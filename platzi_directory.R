library(tidyverse)
library(rvest)
library(curl)
library(magrittr)

home <- 'https://platzi.com/cursos'
platform <- 'Platzi'

page_read <- read_html(home)

alcance_section <- page_read %>% 
  html_nodes('.Career') %>% 
  length(.)
seq_section <- seq(1, alcance_section)
list_directory <- map(seq_section, function(node){
  
  courses_name <- page_read %>% 
    html_nodes('.Career') %>% 
    extract(node) %>% 
    html_nodes('.CareerCourse-name') %>% 
    html_text()
  
  courses_ref <- page_read %>% 
    html_nodes('.Career') %>% 
    extract(node) %>% 
    html_nodes('.CareerCourse') %>% 
    html_attr('href') %>% 
    paste0(home, .)
  
  courses_section <- page_read %>% 
    html_nodes('.Career') %>% 
    extract(node) %>%
    html_nodes('.Career-headerSecundary') %>% 
    html_text(trim = TRUE) %>%
    gsub('([[:upper:]])', ' \\1', .) %>%
    gsub('([[:digit:]])', ' \\1', .) %>%
    trimws(., which = 'both') %>%
    gsub("\\s+"," ", .)
  
  courses_carreer <- page_read %>% 
    html_nodes('.Career') %>% 
    extract(node) %>%
    html_nodes('.Career-headerSecundary') %>% 
    html_nodes('h3') %>% 
    html_text(trim = TRUE)
  
  df_courses <- data.frame(courses_name = courses_name,
                           courses_ref = courses_ref)
  
  df_courses$section <- courses_section
  df_courses$carreer <- courses_carreer
  
  df_courses <- df_courses %>% 
    group_by(section) %>% 
    mutate(number_courses = n())
    
  return(df_courses)
})

df_directory <- bind_rows(list_directory)
df_directory$plan <- 'Basic'

courses_ref_expert <- page_read %>% 
  html_nodes('.CareerCourseItem-link') %>% 
  html_attr('href') %>% 
  paste0(home, .)

courses_name_expert <- page_read %>% 
  html_nodes('.CareerCourseItem') %>% 
  html_text()

df_courses_expert <- data.frame(courses_name = courses_name_expert,
                                courses_ref = courses_ref_expert)

df_courses_expert$section <- 'Otros'
df_courses_expert$carreer <- 'Otros'
df_courses_expert$plan <- 'Expert'
df_courses_expert$number_courses <- 1


df_directory <- bind_rows(list(df_directory, df_courses_expert))
df_directory$language <- 'Español'

df_directory$platform <- platform
df_directory$courses_ref <- gsub('cursos/cursos', 'cursos', df_directory$courses_ref)

write_csv(df_directory, 'data/directory_references_platzi.csv')
