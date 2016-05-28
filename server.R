library(shiny)
library(shinyjs)
library(openxlsx)

source('init.R')


shinyServer(function(input, output, session)
{

    filtered <- reactive(
    {
        dtf <- dt

        if (is.null(input$grupo) &
            is.null(input$aula) &
            is.null(input$asignatura) &
            is.null(input$tipo) &
            is.null(input$dia))
        {
            ## Si no hay filtros aplicados devuelvo una tabla vacía
            dtf[0]
        } else
        {
            ## Aplico filtros de manera sucesiva:
            ## Grupo -> Aula -> Asignatura -> Tipo -> Dia
            grupo <- input$grupo
            if (!is.null(grupo))
                dtf <- dt[Grupo %in% grupo]
            aula <- input$aula
            if (!is.null(aula))
                dtf <- dtf[Aula %in% aula]
            ## Actualizo selectores teniendo en cuenta los filtros            
            updateSelectInput(session,
                              "tipo",
                              selected = input$tipo,
                              choices = getLevels(dtf, "Tipo"))
            updateSelectInput(session,
                              "asignatura",
                              selected = input$asignatura,
                              choices = getLevels(dtf, "Asignatura"))
            ## Sigo con filtrado
            asignatura <- input$asignatura
            if (!is.null(asignatura))
                dtf <- dtf[Asignatura %in% asignatura]
            tipo <- input$tipo
            if (!is.null(tipo))
                dtf <- dtf[Tipo %in% tipo]
            dia <- input$dia
            if (!is.null(dia)) 
                dtf <- dtf[Dia %in% dia]
            setkey(dtf, Dia)
            dtf
        }
    })

    output$tabla <- renderDT(
        filtered()[,.(Dia, HoraInicio, HoraFinal,
                      Aula, Grupo, Tipo, 
                      Guia, Asignatura,
                      Profesor, CodDpto,
                      Inicio, Final)],
        rownames = FALSE,
        escape = FALSE,
        options = list(
            autoWidth = TRUE,
            dom = 'tp',
            language = list(url = '//cdn.datatables.net/plug-ins/1.10.7/i18n/Spanish.json'))
    )
    
    output$dExcel <- downloadHandler(
        filename = function()
        {
            tt <- Sys.time()
            nombre <- format(tt, "tabla_%Y%m%d_%H%M%S")
            paste0(nombre, '.xls')
        },
        content = function(file)
        {
            vals <- filtered()[,.(
                                CodAsignatura, Asignatura,
                                Aula, Tipo,
                                Titulacion, Grupo,
                                Profesor, CodDpto,
                                Dia, HoraInicio, HoraFinal,
                                Inicio, Final)
                               ]
            hs <- createStyle(textDecoration = "bold")
            xls <- write.xlsx(vals, file,
                              creator = "ETSIDI",
                              sheetName = "Horarios",
                              headerStyle = hs)
            setColWidths(xls, sheet = 1,
                         cols = seq_len(ncol(vals)),
                         widths = "auto")
            saveWorkbook(xls, file, overwrite = TRUE)
        }
    )
})
