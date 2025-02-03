// import of libraries
#import "src/lib.typ": *
#import "@preview/datify:0.1.3": *

// criando banco de dados
#let dados = toml("data/jarbson.toml")

// função: criar Lattes CV
// Argumentos:
// - dados: o objeto de dados (criado acima)
// - kind: o tipo de currículo Lattes (string)
// - me: o nome para destacar nas citações (string)
// - last-page: resumo de produção no final (boolean)
#show: lattes-cv.with(
  dados,
  kind: "completo",
  me: "KLEER",
  last-page: true
)   