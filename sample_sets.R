library(tidyverse)
library(rvest)
library(curl)


df_specializations_coursera <- read_csv('data/info_coursera.csv')

df_specializations_coursera <- df_specializations_coursera %>% 
  filter(grepl('data', tolower(specialization_name)))

s <- strsplit(df_specializations_coursera$`Course Instructors`, split = " - ")
df_instructors_tidy <- data.frame(`Course Instructors` = rep(df_specializations_coursera$`Course Instructors`, sapply(s, length)), 
                                   instructors = unlist(s),
                                   specialization_ref = rep(df_specializations_coursera$specialization_ref, sapply(s, length)),
                                  stringsAsFactors = FALSE) %>% 
  filter(!is.na(instructors)) 
df_instructors_tidy$instructors_names <- lapply(str_split(df_instructors_tidy$instructors, ', '), `[[`, 1) %>% unlist()

instructors <- df_instructors_tidy$instructors
instructors_names <- df_instructors_tidy$instructors_names

df_instructors <- read_csv('data/directory_references_coursera.csv') %>% 
  filter(name_directory == 'Instructors') %>% rename(., instructor_name = name_references_directory)

df_sample <- bind_rows(map(instructors_names, function(instructor){
  
  cont <- which(instructors_names == instructor)

  try({
    df <- df_instructors %>% 
      filter(grepl(instructor, instructor_name))
    
    df$instructor <- df_instructors_tidy[cont,]$instructors_names
    df$specialization_ref <- df_instructors_tidy[cont,]$specialization_ref
    df$instructors <- df_instructors_tidy[cont,]$instructors
    
    return(df)
  })
  df <- data.frame(a = 'o')
  
  return(df)
})) %>% select(-c(a)) %>% filter(!is.na(instructor_name))



