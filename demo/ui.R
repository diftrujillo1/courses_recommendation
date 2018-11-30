
styles <- "
@import url('https://fonts.googleapis.com/css?family=Raleway');
body {
font-family: 'Raleway', sans-serif;
}
h1,h2{
color: #545657;
}
h5{
color: #BFC1C2;
font-weight: 400;
}
p{
color: #95989A;
}
hr{
border-top: 2px solid #eee;
}
#plot-container {
position: relative;
}
.shiny-output-error { visibility: hidden; }
.loading-spinner {
position: absolute;
left: 50%;
top: 50%;
z-index: -1;
margin-top: -33px;  /* half of the spinner's height */
margin-left: -33px; /* half of the spinner's width */
}
#plot.recalculating {
z-index: -2;
}
#loading-content {
position: absolute;
background: #FFFFFF;
opacity: 0.9;
z-index: 100;
left: 0;
right: 0;
height: 100%;
text-align: center;
color: #CCC;
}
"

# Define the overall UI
shinyUI(
  fluidPage(
    useShinyjs(),
    #includeCSS("styles.css"),
    inlineCSS(styles),
    # Generate a row with a sidebar
    #fluidRow(id="container",
    dashboardPage(
      dashboardHeader(title = "Cursos online"),
      dashboardSidebar(
        sidebarMenu(
          id = "tabs",
          menuItem("Descripción", tabName = "online_courses", icon = icon("folder-open", lib = "glyphicon")),
          menuItem("Coursera", tabName = "coursera", icon = icon("shopping-cart", lib = "glyphicon")),
          menuItem("Platzi", tabName = "platzi", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Canadá", tabName = "canada", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Chile", tabName = "chile", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Colombia", tabName = "colombia", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Paraguay", tabName = "paraguay", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Uruguay", tabName = "uruguay", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Estados Unidos", tabName = "usa", icon = icon("shopping-cart", lib = "glyphicon")),
          # menuItem("Venezuela", tabName = "venezuela", icon = icon("shopping-cart", lib = "glyphicon")),
          menuItem("Otros", tabName = "otros", icon = icon("shopping-cart", lib = "glyphicon"))
        )
      ),
      dashboardBody(
        tabItems(
          tabItem(tabName = "online_courses",
                  h2('Demo Recomendador de cursos'),
                  br(),
                  h4('Este demo fue creado para poder realizar una corta recomendación de cursos en algunos sitios
                     web que ofrecen cursos por membresía. Para agilizar el proceso, se seleccionaron solamente
                     dos plataformas educativas en línea: Platzi y Coursera. Ambas plataformas con gran
                     variedad de cursos y de temas por explorar. Lo interesante es que cada una ofrece
                     información diferente que puede ser analizada por el usuario para tomar una mejor decisión.
                     La técnica utilizada en este caso se llama web scraping y básicamente consiste en 
                     extraer información de páginas web, ya sean imágenes, híper vínculos y hasta texto.
                     Por términos prácticos, no toda la información que provee la página web se extrajo, pero 
                     sí lo que se consideró más importante'),
                  br(),
                  h4('La idea es que el usuario pueda observar el potencial de esta técnica y pueda ser guiado
                     en el tratamiento de la información para poder construír efectivamente lo que desea. 
                     Seleccione en cada pestaña de la izquiera para poder explorar un poco más.')
          ),
          tabItem(tabName = "coursera",
                  h2("Análisis por: "),
                  br(),
                  h4('La siguiente recomendación solo tomó especializaciones que tuvieran ciertas 
                     palabras claves como data, development, software, services, data and cloud'),
                  radioButtons("rb_coursera", "Búsqueda por:",
                               choiceNames = list(
                                 "Especialización", "Instructor", "Creadores"
                               ),
                               choiceValues = list(
                                 "specialization", "instructor", "creator"
                               )),
                  
                  fluidRow(
                    h4('Para completar los diferentes filtros propuestos, haga clic en
                       cualquier fila de la tabla mostrada para poder ver los cursos asociados a la fila.'),
                    box(width = 12, DT::dataTableOutput("table_coursera"))
                  ),
                  fluidRow(
                    h4('Estos son los cursos encontrados'),
                    box(width = 12, uiOutput("selected_coursera"))
                  )
          ),
          tabItem(tabName = "platzi",
                  h4("Análisis por: "),
                  radioButtons("rb_platzi", "Búsqueda por:",
                               choiceNames = list(
                                 "Carrera", "Instructor"
                               ),
                               choiceValues = list(
                                 "carreer", "instructor"
                  )),
                  fluidRow(
                    h4('Para completar los diferentes filtros propuestos, haga clic en
                       cualquier fila de la tabla mostrada para poder ver los cursos asociados a la fila.'),
                    box(width = 12, DT::dataTableOutput("table_platzi"))
                  ),
                  fluidRow(
                    h4('Estos son los cursos encontrados'),
                    box(width = 12, uiOutput("selected_platzi"))
                  )
          ),
          tabItem(tabName = "otros",
                  h4("En construcción: ")
          )
        )
      )
    )
  )
)
