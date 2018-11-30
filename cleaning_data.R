###run global first (shiny)


######################## COURSERA #############################
###getting courses names that was missing
spec_keywords <- c('development', 'software', 'services', 'data', 'cloud')
df_spec_cour_coursera <- map(spec_keywords, function(keyword){
  df <- df_coursera_specialization %>% 
    filter(grepl(keyword, specialization_name %>% tolower))
  return(df)
}) %>% bind_rows %>%
  select(specialization_name) %>% 
  left_join(., df_coursera, on='specialization_name') %>% 
  select(`Course Reference`, specialization_ref, user_rating) %>% 
  filter(!duplicated(.))
url_spec <- df_spec_cour_coursera$specialization_ref %>% unique
course_names <- map(url_spec, function(url){
  page_specialization <- read_html(curl(url, handle = curl::new_handle("useragent" = "Mozilla/5.0")))
  course_names <- page_specialization %>%
    html_nodes('.headline-5-text') %>%
    html_text(trim = TRUE)
}) %>% unlist
df_spec_cour_coursera$course_name <- course_names

df_coursera <- read_csv('data/info_coursera.csv')
df_test_coursera <- df_spec_cour_coursera %>% 
  left_join(., df_coursera,
            on = c('Course Reference', 'specialization_ref', 'user_rating')) %>% 
  rename(course_reference = `Course Reference`)
write_csv(df_test_coursera, 'data/test_coursera.csv')

###cleaning the table for instructors - courses table
df_test_coursera <- read_csv('data/test_coursera.csv') %>% 
  select(-c(bad_url, `Basic Info`))

df_spec_cour_coursera <- df_test_coursera %>% #select(-specialization_ref) %>% 
  group_by(specialization_name) %>% 
  summarise(number_courses = n(),
            courses_names = paste(course_name, collapse = ' -- '),
            courses_refs = paste(course_reference, collapse = ' -- '),
            avg_rating = round(mean(user_rating, na.rm = TRUE), 2))
write_csv(df_spec_cour_coursera, 'data/sepecializations_courses_coursera.csv')


###cleaning the table for instructors - courses table
df_inst_spec_coursera <- df_test_coursera %>% 
  filter(!is.na(`Course Instructors`))

instructors_names <- str_split(df_inst_spec_coursera$`Course Instructors`, ' - ') %>% unlist %>% unique
df_inst_cour_coursera <- map(instructors_names, function(instructor){
  df <- df_inst_spec_coursera %>% 
    filter(grepl(instructor, `Course Instructors`))
  df_instructor <- data_frame(instructor_name = instructor,
                              number_courses = dim(df)[1],
                              avg_rating = round(mean(df$user_rating, na.rm = TRUE), 2),
                              courses_names = paste(df$course_name, collapse = ' -- '),
                              courses_ref = paste(df$course_reference, collapse = ' -- '))
  return(df_instructor)
}) %>% bind_rows %>% 
  separate(instructor_name, into=c('instructor_name', 'label', 'company/profession'), sep = ', ')
write_csv(df_inst_cour_coursera, 'data/instructors_courses_coursera.csv')


###cleaning the table for creators - courses table
df_crea_spec_coursera <- df_test_coursera %>% 
  filter(!is.na(`Course Creators`))

creators_names <- str_split(df_crea_spec_coursera$`Course Creators`, ', ') %>% unlist %>% unique
df_crea_cour_coursera <- map(creators_names, function(creator){
  df <- df_inst_spec_coursera %>% 
    filter(grepl(creator, `Course Creators`))
  df_instructor <- data_frame(creator_name = creator,
                              number_courses = dim(df)[1],
                              avg_rating = round(mean(df$user_rating, na.rm = TRUE), 2),
                              courses_names = paste(df$course_name, collapse = ' -- '),
                              courses_ref = paste(df$course_reference, collapse = ' -- '))
  return(df_instructor)
}) %>% bind_rows
write_csv(df_crea_cour_coursera, 'data/creators_courses_coursera.csv')

######################## PLATZI #############################
df_platzi <- read_csv('data/courses_info_platzi.csv')

###cleaning the table for carreer - courses table
carreer_platzi <- str_split(df_platzi$part_of, ',') %>% unlist %>% unique
carreer_platzi <- carreer_platzi[!is.na(carreer_platzi)]
df_carr_cour_platzi <- map(carreer_platzi, function(carreer){
  df <- df_platzi %>% 
    filter(grepl(carreer, part_of)) %>% 
    filter(!duplicated(name))
  df_carreer <- data_frame(carreer_name = carreer,
                           courses_name = paste(df$name, collapse = ' -- '),
                           courses_ref = paste(df$url, collapse = ' -- '),
                           number_courses = dim(df)[1])
  return(df_carreer)
}) %>% bind_rows
write_csv(df_carr_cour_platzi, 'data/carreers_courses_platzi.csv')

###cleaning the table for instructors - courses table
df_inst_cour_platzi <- df_platzi %>% 
  filter(!is.na(instructor)) %>% 
  unique %>% 
  group_by(instructor, instructor_social_link, instructor_label) %>% 
  summarise(number_courses = n(),
            courses_names = paste(name, collapse = ' -- '),
            courses_ref = paste(url, collapse = ' -- '))
write_csv(df_inst_cour_platzi, 'data/instructors_courses_platzi.csv')

