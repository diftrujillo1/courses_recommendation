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

df_test_coursera <- read_csv('data/test_coursera.csv')
df_test_platzi <- read_csv('data/test_platzi.csv')

df_carr_cour_platzi <- read_csv('data/carreers_courses_platzi.csv')
df_inst_cour_platzi <- read_csv('data/instructors_courses_platzi.csv')

df_spec_cour_coursera <- read_csv('data/sepecializations_courses_coursera.csv')
df_inst_cour_coursera <- read_csv('data/instructors_courses_coursera.csv')
df_crea_cour_coursera <- read_csv('data/creators_courses_coursera.csv')

df_coursera_specialization <- df_spec_cour_coursera %>% 
  select(-c(courses_names, courses_refs)) %>% 
  arrange(desc(number_courses))

df_coursera_instructors <- df_inst_cour_coursera %>% 
  select(-c(courses_names, courses_ref)) %>% 
  arrange(desc(number_courses))

df_coursera_creators <- df_crea_cour_coursera %>% 
  select(-c(courses_names, courses_ref)) %>% 
  arrange(desc(number_courses))

df_carreers_platzi <- df_carr_cour_platzi %>% 
  select(-c(courses_name, courses_ref)) %>% 
  arrange(desc(number_courses))
  
df_instructors_name_platzi <- df_inst_cour_platzi %>% 
  select(-c(courses_names, courses_ref)) %>% 
  arrange(desc(number_courses))

df_platzi_info <- read_csv('data/directory_references_platzi.csv')

