#
## Sidebar content

shinyServer(function(input, output, session) {
  
  ############### COURSERA ####################
  output$table_coursera <- DT::renderDataTable({
    if(input$rb_coursera == 'specialization'){
      h <- DT::datatable(df_coursera_specialization, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    if(input$rb_coursera == 'instructor'){
      h <- DT::datatable(df_coursera_instructors, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    if(input$rb_coursera == 'creator'){
      h <- DT::datatable(df_coursera_creators, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    
    h}, server=TRUE)
  
  row_selected_coursera <- reactive({
    row_coursera <- input$table_coursera_rows_selected
  })
  
  table_filter_coursera <- reactive({
    row_coursera <- row_selected_coursera()
    df <- data_frame()
    if(input$rb_coursera == 'specialization' & length(row_coursera)){
      specialization_coursera <- df_coursera_specialization[row_coursera,]$specialization_name
      specialization_coursera <- df_spec_cour_coursera %>% 
          filter(specialization_name == specialization_coursera)
      courses_names <- str_split(specialization_coursera$courses_names, ' -- ') %>% unlist
      courses_refs <- str_split(specialization_coursera$courses_refs, ' -- ') %>% unlist
      df <- data_frame(course_name = courses_names,
                       course_ref = courses_refs) %>% 
        left_join(., df_test_coursera %>% 
                      select(course_name, course_ref = course_reference, user_rating),
                  on=c('course_name', 'course_ref')) %>% 
        unique %>% filter(!is.na(course_name))
    }
    
    if(input$rb_coursera == 'instructor' & length(row_coursera)){
      instructor_coursera <- df_coursera_instructors[row_coursera,]$instructor_name
      instructor_coursera <- df_inst_cour_coursera %>% 
        filter(instructor_name == instructor_coursera)
      courses_names <- str_split(instructor_coursera$courses_names, ' -- ') %>% unlist
      courses_refs <- str_split(instructor_coursera$courses_ref, ' -- ') %>% unlist
      df <- data_frame(course_name = courses_names,
                       course_ref = courses_refs) %>% 
        left_join(., df_test_coursera %>% 
                    select(course_name, course_ref = course_reference, user_rating),
                  on=c('course_name', 'course_ref')) %>% 
        unique %>% filter(!is.na(course_name))
    }
    
    if(input$rb_coursera == 'creator' & length(row_coursera)){
      creator_coursera <- df_coursera_creators[row_coursera,]$creator_name
      creator_coursera <- df_crea_cour_coursera %>% 
        filter(creator_name == creator_coursera)
      courses_names <- str_split(creator_coursera$courses_names, ' -- ') %>% unlist
      courses_refs <- str_split(creator_coursera$courses_ref, ' -- ') %>% unlist
      df <- data_frame(course_name = courses_names,
                       course_ref = courses_refs) %>% 
        left_join(., df_test_coursera %>% 
                    select(course_name, course_ref = course_reference, user_rating),
                  on=c('course_name', 'course_ref')) %>% 
        unique %>% filter(!is.na(course_name))
    }
    return(df)
  })
  
  output$selected_coursera = renderUI({
    s = row_selected_coursera()
    h <- NULL
    if (length(s)) {
      # h <- paste('Fila escogida: ', s)
      df <- table_filter_coursera()
      h <- DT::datatable(df, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    viz <- renderDataTable(h)
    list(viz)
  })
  
  ############### PLATZI ####################

  output$table_platzi <- DT::renderDataTable({
    if(input$rb_platzi == 'carreer'){
      h <- DT::datatable(df_carreers_platzi, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    if(input$rb_platzi == 'instructor'){
      h <- DT::datatable(df_instructors_name_platzi, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    h}, server=TRUE)
  
  row_selected_platzi <- reactive({
    row_platzi <- input$table_platzi_rows_selected
  })
  
  table_filter_platzi <- reactive({
    row_platzi <- row_selected_platzi()
    df <- data_frame()
    if(input$rb_platzi == 'carreer' & length(row_platzi)){
      carreer_platzi <- df_carreers_platzi[row_platzi,]$carreer_name
      carreer_platzi <- df_carr_cour_platzi %>% 
        filter(carreer_name == carreer_platzi)
      courses_names <- str_split(carreer_platzi$courses_name, ' -- ') %>% unlist
      courses_refs <- str_split(carreer_platzi$courses_ref, ' -- ') %>% unlist
      df <- data_frame(course_name = courses_names,
                       course_ref = courses_refs) %>% 
        unique %>% filter(!is.na(course_name))
    }
    
    if(input$rb_platzi == 'instructor' & length(row_platzi)){
      instructor_platzi <- df_instructors_name_platzi[row_platzi,]$instructor
      instructor_platzi <- df_inst_cour_platzi %>% 
        filter(instructor == instructor_platzi)
      courses_names <- str_split(instructor_platzi$courses_names, ' -- ') %>% unlist
      courses_refs <- str_split(instructor_platzi$courses_ref, ' -- ') %>% unlist
      df <- data_frame(course_name = courses_names,
                       course_ref = courses_refs) %>% 
        unique %>% filter(!is.na(course_name))
    }
    return(df)
  })
  
  
  
  output$selected_platzi = renderUI({
    s = row_selected_platzi()
    h <- NULL
    if (length(s)) {
      # h <- paste('Fila escogida: ', s)
      df <- table_filter_platzi()
      h <- DT::datatable(df, options = list(
        language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
        pageLength = 10, scrollX=TRUE, scrollCollapse=TRUE, scrolly=TRUE
      ), selection = 'single')
    }
    viz <- renderDataTable(h)
    list(viz)
  })

})

#   output$table_canada <- renderUI({
#     h <- DT::datatable(df_canada, options = list(
#       language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
#       pageLength = 15 
#     ))
#     viz <- renderDataTable(h)
#     list(viz)
#   })
