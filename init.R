library(DT)
library(data.table)
library(openssl)

source('../misc/funciones.R')
source('../misc/defs.R')

semestre <- 2

dtOutput <- DT::dataTableOutput
renderDT <- DT::renderDataTable

## Extraemos valores de las variables cualitativas
getLevels <- function(x, col)
{
    levels(factor(x[[col]]))
}


## No tengo en cuenta los másteres fuera de la ETSIDI
grupos <- c(grupos, masters)
names(grupos) <- NULL

## Horarios con aulas
horariosPath <- '../horarios/csv/'
files <- dir(horariosPath, pattern = '.csv')
horarios <- rbindlist(lapply(paste0(horariosPath, files),
                             fread,
                             na.string = "", 
                             encoding = 'UTF-8'),
                      fill = TRUE)
## Los másteres no tienen grupo: le asigno el código de la titulacion
horarios[is.na(Grupo), Grupo := Titulacion]
## No incluyo la hora de inicio: una actividad queda determinada por
## su nombre, tipo, grupo y dia (y aporta la información de aula)
dth <- horarios[Semestre == semestre &
                Grupo %in% grupos,
                .(
                    Asignatura,
                    Tipo,
                    Grupo,
                    Dia = factor(Dia, dias),
                    Aula
                )]
setkey(dth, Asignatura, Tipo, Grupo, Dia)
## Me quedo con los registros únicos (elimino las duplicidades por diferentes horas de inicio)
dth <- unique(dth)

## Leemos registros disponibles
pathPub <- '../docencia/pub/'
files <- list.files(pathPub, pattern = 'docencia_')
ldt <- lapply(paste0(pathPub, files), fread,
              encoding="UTF-8",
              na.strings = c("", "NA"))
dt0 <- rbindlist(ldt, use.names = TRUE)
## Los másteres no tienen grupo: le asigno el código de la titulacion
dt0[is.na(Grupo), Grupo := Titulacion]
## Pero sólo tengo en cuenta las titulaciones de la ETSIDI
dt0 <- dt0[Grupo %in% grupos]
## Profesor en formato titlecase
dt0[, Profesor := titlecase(Profesor)]
## Días ordenados correctamente
dt0[, Dia := factor(Dia, dias)]
## Codigo de asignatura como integer
dt0[, CodAsignatura := as.integer(CodAsignatura)]
## Guía de la asignatura enlazada
dt0[, Guia := paste0('<a href="',
                              GAurl(CodAsignatura,
                                    Titulacion,
                                    semestre),
                              '" target=_blank>',
                     CodAsignatura, '</a>')]
## Nuevamente supongo que una actividad queda definida de forma unívoca por su dia, grupo, tipo y nombre
setkey(dt0, Asignatura, Tipo, Grupo, Dia)

## Join entre las dos tablas.
dt <- merge(dt0, dth)

asignaturas <- getLevels(dt, "Asignatura")
