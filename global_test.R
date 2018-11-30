library(shiny)
library(tidyverse)
library(readr)
library(scales)
library(lazyeval)
library(DT)
library(shinyjs)
library(stringr)
library(RSQLite)
library(shinydashboard)

### LOAD DATA

df_platzi <- read_csv('data/courses_info_platzi.csv')

courses_names_platzi <- df_platzi$name %>% unique(.)
courses_names_platzi <- courses_names_platzi[!is.na(courses_names_platzi)]

instructors_names_platzi <- df_platzi$instructor %>% unique(.)
instructors_names_platzi <- instructors_names_platzi[!is.na(instructors_names_platzi)]

df_instructors_name_platzi <- data.frame(instructor_name = instructors_names_platzi,
                                         stringsAsFactors = FALSE) %>% 
  left_join(., 
            df_platzi %>% select(instructor_name = instructor, instructor_social_link, instructor_label), 
            on='instructor_name') %>% 
  group_by(instructor_name) %>% 
  summarise(number_courses = n(), social_link = min(instructor_social_link), 
            label = min(instructor_label)) %>% 
  arrange(desc(number_courses))

df_platzi_info <- read_csv('data/directory_references_platzi.csv')

df_carreers_platzi <- df_platzi_info %>% 
  group_by(carreer) %>% 
  summarise(number_courses = min(number_courses)) %>% 
  arrange(desc(number_courses))

df_course_name_platzi <- df_platzi %>% 
  select(name, course_part_of_carreer = part_of) %>% 
  filter(!duplicated(name))

df_course_name_platzi$number_part_of <- 
  unlist(map(df_course_name_platzi$course_part_of_carreer, function(carreer){
    return(length(str_split(carreer, ',') %>% unlist()))
  }))

df_course_name_platzi = df_course_name_platzi %>%
  arrange(desc(number_part_of)) %>% 
  select(-number_part_of)

df_coursera <- read_csv('data/info_coursera.csv')
df_coursera$user_rating <- substr(df_coursera$`User Ratings`, 0, 3) %>% as.numeric()

coursera_creators <- map(df_coursera$`Course Creators`, function(creator){
  return(str_split(creator, ', ') %>% unlist())
}) %>% unlist() %>% unique()# %>% trimws(which = 'both')
coursera_creators <- coursera_creators[!is.na(coursera_creators)]

df_coursera_creators <- map(coursera_creators, function(creator){
  df <- df_coursera %>% filter(grepl(creator, `Course Creators`))
  return(data_frame(course_creator = creator, number_courses = dim(df)[1]))
}) %>% bind_rows() %>% arrange(desc(number_courses)) %>% filter(number_courses > 0)


df_coursera_specialization <- df_coursera %>% 
  group_by(specialization_name) %>% 
  summarise(number_courses = n(), 
            courses_difficulty = paste0(Level, collapse = ' - '),
            specialization_staff = mean(specialization_staff)) %>% 
  filter(!is.na(specialization_name)) %>% 
  arrange(desc(number_courses), desc(specialization_staff))

df_coursera_specialization$courses_difficulty <- 
  map(df_coursera_specialization$courses_difficulty, function(diff){
    splitted <- str_split(diff, ' - ') %>% unlist()
    splitted <- splitted[!is.na(splitted) & splitted != 'NA']
    splitted <- splitted[!duplicated(splitted)]
    if(identical(splitted, character(0))) splitted <- 'No tiene información'
    return(paste0(splitted, collapse = ' - '))
  }) %>% unlist()


coursera_instructors <- map(df_coursera$`Course Instructors`, function(creator){
  return(str_split(creator, ' - ') %>% unlist())
}) %>% unlist() %>% unique()# %>% trimws(which = 'both')
coursera_instructors <- coursera_instructors[!is.na(coursera_instructors)]

df_coursera_instructors <- map(coursera_instructors, function(instructor){
  df <- df_coursera %>% filter(grepl(instructor, `Course Instructors`))
  return(data_frame(course_instructor = instructor, number_courses = dim(df)[1]))
}) %>% bind_rows() %>% arrange(desc(number_courses)) %>% filter(number_courses > 0) %>% 
  separate(course_instructor, into=c('name_instructor', 'label', 
                                     'company/profession'), sep = ', ')








