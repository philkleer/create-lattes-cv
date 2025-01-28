// import of libraries
#import "lib.typ": *
#import "@preview/datify:0.1.3": *

// create full CV
// Argumentos:
// - database: o arquivo de TOML com os dados de Lattes (string)
// - kind: o tipo de currículo Lattes (string)
// - me: o nome para destacar nas citações (string)
// - data: a data de currículo
// - last_page: resumo de produção no final (boolean)
#show: lattes-cv.with(
  database: "data/lattes.toml",
  kind: "completo",
  me: "KLEER",
  date: datetime.today()
  last_page: true
)   
