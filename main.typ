// import of libraries
#import "lib.typ": *
#import "@preview/datify:0.1.3": *

// create full CV
// Argumentos:
// -  kind: "completo", "ampliado" ou "resumido"
// - me: string para destacar nas citações
// - last_page: resumo de totais de produção (true ou false)
// - database: link para o arquivo de toml.
// - datetime: a data atual
#show: lattes-cv.with(
  kind: "resumido",
  me: "KLEER",
  last_page: true,
  database: "data/lattes.toml",
  date: datetime(year: 2022, month: 04, day: 07)
)   
