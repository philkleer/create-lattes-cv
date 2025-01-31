#import "utils.typ": *

// Função create-reviewer(): Cria áreas de revisor (periódico, assessora, fomento)
// Argumento:
//  - detalhes: o banco de dados de Lattes (TOML File)
#let create-reviewer(detalhes) = {

    // criando banco de dados
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL
    // TODO: 3 casos até agora
    let periodico = ()
    let assessora = ()
    let fomento = ()

    for vinculo in atuacao {
        // obs.: tem muitas entradas, mas aqueles relevantes aqui somente são dictionaries
        if type(vinculo) == dictionary {
            let subset = vinculo.VINCULOS

            if type(subset) == dictionary {
                if "OUTRO-VINCULO-INFORMADO" in subset.keys() {
                    if subset.OUTRO-VINCULO-INFORMADO == "Revisor de periódico" {
                        periodico.push(vinculo)
                    } else if subset.OUTRO-VINCULO-INFORMADO == "Membro de comitê assessor" { 
                        assessora.push(vinculo)
                    // caso fomento
                    } else if subset.OUTRO-VINCULO-INFORMADO == "Revisor de projeto de fomento" { 
                        fomento.push(vinculo)
                    }
                }
            // caso: tem mais de uma entrada para uma instituição
            } else if type(subset) == array { 
                for entrada in subset {
                    if "OUTRO-VINCULO-INFORMADO" in entrada.keys() {
                        if entrada.OUTRO-VINCULO-INFORMADO == "Revisor de periódico" {
                            // criando dictionary para push depois
                            let dict = (:)
                            
                            // criando instituticao
                            dict.insert("NOME-INSTITUICAO", vinculo.NOME-INSTITUICAO) 

                            dict.insert("VINCULOS", (:))

                            // criando ano fim e ano inicio
                            dict.at("VINCULOS").insert("ANO-INICIO", entrada.ANO-INICIO)

                            dict.at("VINCULOS").insert("ANO-FIM", entrada.ANO-FIM)

                            // criando mes fim e ano inicio
                            dict.at("VINCULOS").insert("MES-INICIO", entrada.MES-INICIO)

                            dict.at("VINCULOS").insert("MES-FIM", entrada.MES-FIM)

                            // criando outras informações
                            dict.at("VINCULOS").insert("OUTRAS-INFORMACOES", entrada.OUTRAS-INFORMACOES)

                            periodico.push(vinculo)
                        } else if entrada.OUTRO-VINCULO-INFORMADO == "Membro de comitê assessor" { 
                            // criando dictionary para push depois
                            let dict = (:)
                            
                            // criando instituticao
                            dict.insert("NOME-INSTITUICAO", vinculo.NOME-INSTITUICAO) 

                            dict.insert("VINCULOS", (:))

                            // criando ano fim e ano inicio
                            dict.at("VINCULOS").insert("ANO-INICIO", entrada.ANO-INICIO)

                            dict.at("VINCULOS").insert("ANO-FIM", entrada.ANO-FIM)

                            // criando mes fim e ano inicio
                            dict.at("VINCULOS").insert("MES-INICIO", entrada.MES-INICIO)

                            dict.at("VINCULOS").insert("MES-FIM", entrada.MES-FIM)

                            // criando outras informações
                            dict.at("VINCULOS").insert("OUTRAS-INFORMACOES", entrada.OUTRAS-INFORMACOES)

                            assessora.push(vinculo)
                        // caso fomento
                        } else if entrada.OUTRO-VINCULO-INFORMADO == "Revisor de projeto de fomento" {
                            // criando dictionary para push depois
                            let dict = (:)
                            
                            // criando instituticao
                            dict.insert("NOME-INSTITUICAO", vinculo.NOME-INSTITUICAO) 

                            dict.insert("VINCULOS", (:))

                            // criando ano fim e ano inicio
                            dict.at("VINCULOS").insert("ANO-INICIO", entrada.ANO-INICIO)

                            dict.at("VINCULOS").insert("ANO-FIM", entrada.ANO-FIM)

                            // criando mes fim e ano inicio
                            dict.at("VINCULOS").insert("MES-INICIO", entrada.MES-INICIO)

                            dict.at("VINCULOS").insert("MES-FIM", entrada.MES-FIM)

                            // criando outras informações
                            dict.at("VINCULOS").insert("OUTRAS-INFORMACOES", entrada.OUTRAS-INFORMACOES)

                            fomento.push(dict)
                        }
                    }
                }
            }
        }
    }

    // ordenando entradas
    periodico = periodico.sorted(key: (item) => (item.VINCULOS.ANO-FIM, item.VINCULOS.ANO-INICIO, item.VINCULOS.MES-FIM, item.VINCULOS.MES-INICIO))

    assessora = assessora.sorted(key: (item) => (item.VINCULOS.ANO-FIM, item.VINCULOS.ANO-INICIO, item.VINCULOS.MES-FIM, item.VINCULOS.MES-INICIO))

    fomento = fomento.sorted(key: (item) => (item.VINCULOS.ANO-FIM, item.VINCULOS.ANO-INICIO, item.VINCULOS.MES-FIM, item.VINCULOS.MES-INICIO))

    // Caso revisor de periódicos
    if periodico.len() > 0 {
        // criando cabeçalho
        [= Revisor de periódico <periodicos>]

        // criando variáveis
        let tempo_content = []

        // loop para cada entrada
        for entrada in periodico.rev() {
            // Caso: somente uma entrada
            if type(entrada) == dictionary {
                // loop para mais informações do vínculo
                for vinculo in entrada {
                    
                    // criando tempo
                    if entrada.VINCULOS.ANO-FIM == "" {
                        tempo_content = [#entrada.VINCULOS.ANO-INICIO - atual]
                    } else if entrada.VINCULOS.ANO-FIM == entrada.VINCULOS.ANO-INICIO {
                        tempo_content = [#entrada.VINCULOS.ANO-FIM]
                    } else {
                        tempo_content = [#entrada.VINCULOS.ANO-INICIO - #entrada.VINCULOS.ANO-FIM]
                    }
                }
            

                // extrair mais informações se tiver
                let informacao = []
                if entrada.VINCULOS.OUTRAS-INFORMACOES != "" {
                    let texto = entrada.VINCULOS.OUTRAS-INFORMACOES
                    texto = replace-quotes(texto)

                    informacao = [#linebreak() #text(rgb("B2B2B2"), size: 0.85em, "Outras informações: " + texto)]
                }

                // criando conteúdo
                let descricao_content = [#entrada.NOME-INSTITUICAO #linebreak() #informacao]
                
                // publicando content
                create-cols([*#tempo_content*], descricao_content, "small")
            }
        }

        // create distância e linha
        linebreak()

        line(length: 100%)
    } 

    // caso membro de comitê de assessora
    if assessora.len() > 0 {
        // criando cabeçalho
        [= Membro de comitê de assessora <assessora>]

        // criando variáveis
        let tempo_content = []

        // loop para cada entrada
        for entrada in assessora.rev() {
            // Caso: somente uma entrada
            if type(entrada) == dictionary {
                // loop para mais informações do vínculo
                for vinculo in entrada {
                    
                    // criando tempo
                    if entrada.VINCULOS.ANO-FIM == "" {
                        tempo_content = [#entrada.VINCULOS.ANO-INICIO - atual]
                    } else if entrada.VINCULOS.ANO-FIM == entrada.VINCULOS.ANO-INICIO {
                        tempo_content = [#entrada.VINCULOS.ANO-FIM]
                    } else {
                        tempo_content = [#entrada.VINCULOS.ANO-INICIO - #entrada.VINCULOS.ANO-FIM]
                    }
                }
                

                // extrair mais informações se tiver
                let informacao = []
                if entrada.VINCULOS.OUTRAS-INFORMACOES != "" {
                    let texto = entrada.VINCULOS.OUTRAS-INFORMACOES
                    texto = replace-quotes(texto)

                    informacao = [#linebreak() #text(rgb("B2B2B2"), size: 0.85em, "Outras informações: " + texto)]
                }

                // criando content
                let descricao_content = [#entrada.NOME-INSTITUICAO #informacao]
                
                // publicando content
                create-cols([*#tempo_content*], descricao_content, "small")
            }
        }

        // create distância e linha
        linebreak()

        line(length: 100%)
    } 

    // caso revisor de projeto de agência de fomento
    if fomento.len() > 0 {
        // criando cabeçalho
        [= Revisor de projeto de agência de fomento <fomento>]

        // criando variáveis
        let tempo_content = []

        // loop para cada entrada
        for entrada in fomento.rev() {
            // Caso: somente uma entrada
            if type(entrada) == dictionary {

                // loop para mais informações do vínculo
                for vinculo in entrada {
                    
                    // criando tempo
                    if entrada.VINCULOS.ANO-FIM == "" {
                        tempo_content = [#entrada.VINCULOS.ANO-INICIO - atual]
                    } else if entrada.VINCULOS.ANO-FIM == entrada.VINCULOS.ANO-INICIO {
                        tempo_content = [#entrada.VINCULOS.ANO-FIM]
                    } else {
                        tempo_content = [#entrada.VINCULOS.ANO-INICIO - #entrada.VINCULOS.ANO-FIM]
                    }
                }
                

                // extrair mais informações se tiver
                let informacao = []
                if entrada.VINCULOS.OUTRAS-INFORMACOES != "" {
                    let texto = entrada.VINCULOS.OUTRAS-INFORMACOES
                    texto = replace-quotes(texto)

                    informacao = [#linebreak() #text(rgb("B2B2B2"), size: 0.85em, "Outras informações: " + texto)]
                }

                // criando content
                let descricao_content = [#entrada.NOME-INSTITUICAO #informacao]
                
                // publicando content
                create-cols([*#tempo_content*], descricao_content, "small")
            }
        }

        // create distância e linha
        linebreak()

        line(length: 100%)
    } 
}