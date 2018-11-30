library(tidyverse)
library(rvest)
library(curl)
library(magrittr)


home <- 'https://platzi.com/cursos'
platform <- 'Platzi'

page_read <- read_html(home)

df_directory <- read_csv('data/directory_references_platzi.csv')
ref <- df_directory$courses_ref
names <- df_directory$courses_name
languages <- df_directory$language

list_df_info <- map(seq_along(ref), function(cont){
  
  if(cont %% 50 == 0) print(cont)

  url_ref <- ref[cont]
  try({
    page_read <- read_html(url_ref)
    
    course_part_of <- page_read %>% 
      html_nodes('.LandingBelongingCareer-career') %>% 
      html_text()
    
    if(identical(course_part_of, character(0))){
      course_part_of <- NA
    }
    
    course_ranking <- page_read %>% 
      html_nodes('.BannerTop-ranking') %>% 
      html_text() %>% 
      str_extract(., "\\-*\\d+\\.*\\d*") %>% 
      as.numeric(.)
    
    if(identical(course_ranking, character(0))){
      course_ranking <- NA
    }
    
    course_resume <- page_read %>% 
      html_nodes('.BannerTop-margin') %>% 
      html_text(trim = TRUE) 
    
    if(identical(course_resume, character(0))){
      course_resume <- NA
    }
    
    
    alcance_instructor <- page_read %>% 
      html_nodes('.Teacher-name') %>% 
      length(.)
    
    seq_teachers <- seq(1, alcance_instructor)
    
    list_instructors <- map(seq_teachers, function(node){
      
      course_instructor_name <- page_read %>% 
        html_nodes('.Teacher') %>% 
        extract(node) %>% 
        html_nodes('.Teacher-name') %>% 
        html_text()
      
      course_instructor_link <- page_read %>% 
        html_nodes('.Teacher') %>% 
        extract(node) %>% 
        html_nodes('.Teacher-link') %>% 
        html_text(trim = TRUE)
      
      if(identical(course_instructor_link, character(0))){
        course_instructor_link <- rep(NA, length(course_instructor_name))
      }
      
      course_instructor_label <- page_read %>% 
        html_nodes('.Teacher') %>% 
        extract(node) %>% 
        html_nodes('.Teacher-label') %>% 
        html_text(trim = TRUE)
      
      if(identical(course_instructor_label, character(0))){
        course_instructor_label <- rep(NA, length(course_instructor_name))
      }
      
      df_course <- data.frame(instructor = course_instructor_name,
                              instructor_social_link = course_instructor_link,
                              instructor_label = course_instructor_label)
      
      return(df_course)
    })
    
    df_course <- bind_rows(list_instructors)
    
    df_course$summary <- course_resume
    df_course$discussion <- course_ranking
    df_course$part_of <- paste(course_part_of, collapse = ',')
    df_course$url <- url_ref
    
    df_course$name <- names[cont]
    df_course$language <- languages[cont]
    
    return(df_course)
  })
  message(url_ref)
  df <- data_frame(bad_url = url_ref)
  return(df)
})


df_courses_info_platzi <- bind_rows(list_df_info) %>% select(-bad_url)
df_courses_info_platzi$platform <- platform

write_csv(df_courses_info_platzi, 'data/courses_info_platzi.csv')
