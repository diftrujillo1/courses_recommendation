library(tidyverse)
library(rvest)
library(curl)
espec <- 'https://www.coursera.org/directory/specializations?page='

alcance <- read_html(paste0(espec, '1')) %>% 
  html_nodes('.number') %>% 
  html_text(trim = TRUE) %>% 
  as.numeric(.) %>% 
  max(.)

pages <- seq(1:alcance)

urls <- paste0(espec, pages)

list_df_specializations_ref <- map(urls, function(url){
  
  p <- read_html(url)
  
  specialization <- p %>% 
    html_nodes('.c-directory-link') %>% 
    html_text(trim = TRUE)
  
  ref <- p %>% html_nodes('.c-directory-link') %>% html_attr('href')
  ref <- paste0('https://www.coursera.org', ref)
  
  creators <- str_extract(specialization, '\\((.*)?\\)$') %>% 
    gsub('\\(|\\)', '', .) %>% trimws(which = 'both')
  
  names <- specialization %>% 
    gsub('\\((.*)?\\)$', '', .) %>% trimws(which = 'both')
  
  df_specialization_ref <- data_frame(specialization_ref = ref,
                                      specialization_name = names,
                                      specialization_creators = creators)
  
  return(df_specialization_ref)
})

df_specialization_ref <- bind_rows(list_df_specializations_ref)
ref <- df_specialization_ref$specialization_ref
creators <- df_specialization_ref$specialization_creators
names <- df_specialization_ref$specialization_name

write_csv(df_specialization_ref, 'data/specializations_references.csv')

list_df_specializations <- map(ref, function(url_ref){
  
  cont <- which(ref == url_ref)
  try({
    
    if(cont %% 50 == 0) print(cont)
    
    page_specialization <- read_html(curl(url_ref, handle = curl::new_handle("useragent" = "Mozilla/5.0")))
    courses <- page_specialization %>% 
      html_nodes('#about .horizontal-box:nth-child(1) .headline-1-text') %>% 
      html_text(trim = TRUE)
    
    courses_number <- gsub('Courses|courses', '', courses) %>% 
      trimws(which = 'both') %>% as.numeric
    
    difficulty <- page_specialization %>% 
      html_nodes('#courses .align-items-absolute-center') %>% 
      html_text(trim = TRUE)
    
    pages_courses <- page_specialization %>% 
      html_nodes('#courses a') %>% 
      html_attr('href')
    courses_ref <- paste0('https://www.coursera.org', pages_courses)
    
    # 
    list_df_by_courses <- map(courses_ref, function(course_ref){
      page_course <- read_html(curl(course_ref, handle = curl::new_handle("useragent" = "Mozilla/5.0")))
      course_instructor <- page_course %>% 
        html_nodes('.instructor-name .body-1-text') %>% 
        html_text(trim = TRUE) %>% paste(collapse = ' - ')
      
      course_creator <- page_course %>% 
        html_nodes('.creator-names span+ span') %>% 
        html_text(trim = TRUE) %>% paste(collapse = ' - ')
      
      course_table_info <- page_course %>% 
        html_nodes('.bt3-table-striped td') %>% 
        html_text(trim = TRUE)
      course_table_labels <- course_table_info[seq(1,length(course_table_info), 2)] 
      course_table_description <- course_table_info[seq(2,length(course_table_info), 2)] 
      
      course_table <- data_frame(a = course_table_description) %>% 
        t(.) %>% as.data.frame
      names(course_table) <- course_table_labels
      
      course_table <- bind_cols(course_table,
                                data_frame(`Course Reference` = course_ref,
                                           `Course Instructors` = course_instructor,
                                           `Course Creators`= course_creator))
      
      return(course_table)
    })
    
    df_by_courses <- bind_rows(list_df_by_courses)
    
    
    # course_rating <- page_course %>% 
    #   html_nodes('.rc-RatingsHeader') %>% 
    #   html_text(trim = TRUE)
    
    # content_row <- page_specialization %>% 
    #   html_nodes('.basic-info-row') %>% 
    #   html_text(trim = TRUE)
    # 
    # content_courses <- page_specialization %>% 
    #   html_nodes('#courses .bgcolor-white') %>% 
    #   html_text(trim = TRUE)
    # 
    # courses_join <- str_extract(content_courses, 'COURSE .')
    # manually_join <- map(courses_join, function(course){
    #   cont <- which(courses_join == course)
    #   content <- content_courses[cont]
    #   df <- data_frame(type = c('Commitment', 'Subtitles'), content = content)
    #   df$course <- course
    #   return(df)
    # }) %>% bind_rows
    # 
    # subtitles <- str_extract(content_row, 'Subtitles(.*)?$|subtitles(.*)?$')
    # subtitles <- subtitles[!is.na(subtitles)] %>% 
    #   gsub('Subtitles|subtitles', 'Subtitles ', .) 
    # df_subtitles <- data_frame(text = subtitles)
    # df_subtitles$type <- 'Subtitles'
    # 
    # 
    # dedication <- str_extract(content_row, 'Dedicación(.*)?$|dedicación(.*)?$|dedicacion(.*)?$|Dedicacion(.*)?$|dedication(.*)?$|Dedication(.*)?$|Commitment(.*)?$|commitment(.*)?$')
    # dedication <- dedication[!is.na(dedication)] %>% 
    #   gsub('Commitment|commitment', 'Commitment ', .)
    # df_dedication <- data_frame(text = dedication)
    # df_dedication$type <- 'Commitment'
    
    course_names <- page_specialization %>% 
      html_nodes('.headline-5-text') %>% 
      html_text(trim = TRUE)
    
    staff <- page_specialization %>% 
      html_nodes('#creators .horizontal-box') %>% 
      html_text() %>% length
    
    # if(identical(dedication, character(0))){
    #   dedication = rep('', courses_number)
    # }
    
    # df_by_specialization <- data_frame(course_names = course_names,
    #                                    #dedication = dedication,
    #                                    subtitles = subtitles)
    # 
    # df_by_specialization$dedication <- dedication
    df_by_specialization <- data_frame(course_names = course_names)
    df_by_courses$course_names <- course_names
    df_by_courses$specialization_difficulty <- difficulty
    df_by_courses$specialization_staff <- staff
    df_by_courses$specialization_courses <- courses
    
    df_by_courses$specialization_creators <- creators[cont]
    df_by_courses$specialization_name <- names[cont]
    df_by_courses$specialization_ref <- url_ref
    
    return(df_by_courses)
  })
  
  message(url_ref)
  df <- data_frame(bad_url = url_ref)
  write_csv(df, 'data/bad_urls.csv', append = TRUE)
  
  gc()

  return(df)
})

df_specialization_courses <- bind_rows(list_df_specializations)
  
write_csv(df_specialization_courses, 'data/courses_specialization_coursera.csv')
  
  
  
  