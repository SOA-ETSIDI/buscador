library(shiny)
library(shinyjs)

source('init.R')


logoUPM <- "http://www.upm.es/sfs/Rectorado/Gabinete%20del%20Rector/Logos/UPM/EscPolitecnica/EscUpmPolit_p.gif"
logoETSIDI <- "http://www.upm.es/sfs/Rectorado/Gabinete%20del%20Rector/Logos/EUIT_Industrial/ETSI%20DISEN%C2%A6%C3%A2O%20INDUSTRIAL%20pqn%C2%A6%C3%A2.png"


## Cabecera con logos
header <- fluidRow(
    column(4, align = 'center', img(src = logoUPM)),
    column(4, align = 'center',
           h2("Horarios y aulas"),
           h4(paste0("Curso ", cursoActual, " (",
                     c('Septiembre - Enero',
                       'Febrero - Junio')[semestreActual],
                     ")")),
           h5("Subdirección de Ordenación Académica")),
    column(4, align = 'center', img(src = logoETSIDI))
)

selector <-
    div(id = 'selector',
        fluidRow(
            column(12,
                   wellPanel(
                       p('En esta página puedes buscar información sobre los grupos, las aulas, los horarios y profesores de la ETSIDI.',
                         'Usa una o varias listas de selección para filtrar el contenido de la tabla que se muestra a continuación.',
                         'Puedes recorrer las listas de selección o escribir varias letras para delimitar la búsqueda.',
                         'En cada selector se pueden elegir varias opciones simultáneamente.',
                         'Emplea la tecla "Retroceso" o "Suprimir" para eliminar las opciones seleccionadas.'
                         )))),
        fluidRow(
            column(4,
                   wellPanel(
                       fluidRow(
                           column(12,
                                  selectInput('grupo', label = 'Grupo:',
                                              choices = grupos,
                                              multiple = TRUE))),
                       fluidRow(
                           column(12,
                                  selectInput('aula', label = 'Aula:',
                                              choices = aulas,
                                              multiple = TRUE)))
                   )),
            column(4,
                   wellPanel(
                       fluidRow(
                           column(12,
                                  selectInput('asignatura', label = 'Asignatura:',
                                              choices = asignaturas,
                                              multiple = TRUE))),
                       fluidRow(
                           column(12,
                                  selectInput('tipo', label = 'Tipo:',
                                              choices = tipos,
                                              multiple = TRUE)))
                   )),
            column(4,
                   wellPanel(
                       selectInput('dia', label = 'Dia:',
                                   choices = dias,
                                   multiple = TRUE))
                   )
        )
        )


result <- wellPanel(
    fluidRow(
        column(12,
               dtOutput("tabla")
               )
    ),
    fluidRow(
        column(12,
               p('Los códigos que aparecen en la columna "Guía" son enlaces a las guías de la asignaturas.',
                 'Puedes guardar el contenido que muestra la tabla pulsando el botón "Excel".')
               )
    ),
    fluidRow(
        column(12, downloadButton2('dExcel', 'Excel', 'file-excel-o'))
    )
    )

## UI completa
shinyUI(
    fluidPage(
        useShinyjs(),
        includeCSS("styles.css"),
        header,
        selector,
        result
    )
)

