library(tidyverse)
library(stringr)

df_specializations <- read_csv('data/info_coursera.csv') %>% 
  select(-bad_url)

function_number_courses <- function(number){
  df <- df_specializations %>% 
    mutate(num_course = gsub(' Courses| courses', '', specialization_courses) %>% as.numeric(.)) %>% 
    filter(num_course == number)
  
  return(df)
}

function_instructors_courses <- function(staff_number){
  df <- df_specializations %>% 
    filter(specialization_staff == staff_number)
  
  return(df)
}

function_language_courses <- function(language){
  df <- df_specializations %>% 
    filter(grepl(language %>% tolower(.), Language %>% tolower(.)))
  
  return(df)
}

function_course_creators <- function(creators){
  df <- df_specializations %>% 
    filter(grepl(creators %>% tolower(.), `Course Creators` %>% tolower(.)))
  
  return(df)
}

# function_number_courses(4) %>% head(4)
# function_instructors_courses(4) %>% head(4)
# function_language_courses('english') %>% head(3)
# function_course_creators('goldsmiths') %>% head(3)



