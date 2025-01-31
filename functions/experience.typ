#import "utils.typ": *

// Função create-positions(): cria vínculos (subárea Atuação, usado em create-experience())
// Argumento:
//  - dados_vagas: o banco de dados filtrado para vagas
#let create-positions(dados_vagas) = {
    
    // depdende de informações na entrada é dictionary (1) ou array (>1)
    if type(dados_vagas) == array {
        
        // criando banco de dados em ordem
        let subset = dados_vagas.sorted(key: (item) => (item.ANO-INICIO, item.MES-INICIO, item.ANO-FIM, item.MES-FIM))

        // criando toda entrada
        for position in subset.rev() {
            
            // criando variáveis
            let tempo_content
            // criando tempo
            if position.MES-FIM == "" {
                if position.ANO-FIM == "" {
                    tempo_content = [#position.MES-INICIO/#position.ANO-INICIO - atual]
                }
            } else {
                tempo_content = [#position.MES-INICIO/#position.ANO-INICIO - #position.MES-FIM/#position.ANO-FIM]
            }

            let vinculo = position.TIPO-DE-VINCULO
            let vinculo_parts = vinculo.split("_")
            vinculo = vinculo_parts.map(capitalize).join(" ")
            
            let enquadramento = position.OUTRO-ENQUADRAMENTO-FUNCIONAL-INFORMADO
            let horas = position.CARGA-HORARIA-SEMANAL
            let informacao = position.OUTRAS-INFORMACOES

            // corrigindo o código html de &quot; para "
            informacao = replace-quotes(informacao)

            // criando content depende das informações dados
            let descricao_content
            if enquadramento != "" and horas != "" and informacao != "" {
                // caso tudo é dado
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros informações: #informacao]
                ]
            } else if enquadramento != "" and horas != "" and informacao == "" {
                // caso sem informações
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas
                ]
            } else if enquadramento != "" and horas == "" and informacao == "" {
                // caso sem informações e horas
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento
                ]
            } else if enquadramento != "" and horas == "" and informacao != "" {
                // caso sem horas
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros informações: #informacao]
                ]
            }

            // publicando content
            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    // caso somente uma entrada
    } else if type(dados_vagas) == dictionary {
        // criando variáveis
        let tempo_content = []
        
        // criando tempo
        if dados_vagas.MES-FIM == "" {
            if dados_vagas.ANO-FIM == "" {
                tempo_content = [#dados_vagas.MES-INICIO/#dados_vagas.ANO-INICIO - atual]
            }
        } else {
            tempo_content = [#dados_vagas.MES-INICIO/#dados_vagas.ANO-INICIO - #dados_vagas.MES-FIM/#dados_vagas.ANO-FIM]
        }

        // criando outras variáveis
        let vinculo = dados_vagas.TIPO-DE-VINCULO
        let vinculo_parts = vinculo.split("_")
        vinculo = vinculo_parts.map(capitalize).join(" ")
            

        let enquadramento = dados_vagas.OUTRO-ENQUADRAMENTO-FUNCIONAL-INFORMADO
        let horas = dados_vagas.CARGA-HORARIA-SEMANAL
        let informacao = dados_vagas.OUTRAS-INFORMACOES

        informacao = replace-quotes(informacao)

        // criando content
        let descricao_content = []
        if enquadramento != "" and horas != "" and informacao != "" {
            // case all three are given
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros informações: #informacao]
            ]
        } else if enquadramento != "" and horas != "" and informacao == "" {
            // caso sem informações
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas
            ]
        } else if enquadramento != "" and horas == "" and informacao == "" {
            // caso sem informações e horas
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento
            ]
        } else if enquadramento != "" and horas == "" and informacao != "" {
            // caso sem horas
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros informações: #informacao]
            ]
        }

        // publicando content
        create-cols([*#tempo_content*], [#descricao_content], "wide")
    }
}

// Função create-teaching: cria cursos de ensino (subárea Atuação, usado em create-experience())
// Argumento:
//  - dados_ensino: o banco de dados filtrado para vagas
#let create-teaching(dados_ensino) = {
    [== Atividades (Ensino)<ensino_atuacao>]

    if type(dados_ensino) == dictionary {
    // case only one entry
        // criando variáveis
        let disciplinas_text = str
        let tempo_content = []

        // criando tempo_content
        if dados_ensino.FLAG-PERIODO == "ATUAL" {
            tempo_content = [#dados_ensino.MES-INICIO/#dados_ensino.ANO-INICIO - atual]
        } else {
            tempo_content = [#dados_ensino.MES-INICIO/#dados_ensino.ANO-INICIO - #dados_ensino.MES-FIM/#dados_ensino.ANO-FIM]
        }

        // criando nível
            let nivel = str(dados_ensino.TIPO-ENSINO.slice(0, 1) + lower(dados_ensino.TIPO-ENSINO.slice(1)))

            // corrigir nível
            if nivel == "Graduacao" {
                nivel = "Graduação"
            } else if nivel == "Pos-graduacao" {
                nivel = "Pós-Graduação"
            }

            if "DISCIPLINA" in dados_ensino.keys() {
                let disciplinas = dados_ensino.at("DISCIPLINA")
                
                let ministradas = ()

                for area in disciplinas { 
                    ministradas.push(area._text)
                }

                disciplinas_text = ministradas.join("; ")

                disciplinas_text = "Disciplinas ministradas: " + disciplinas_text
            }
                
            let descricao_content = [#nivel, #dados_ensino.NOME-CURSO #linebreak()#text(rgb("B2B2B2"), size: 0.85em, disciplinas_text)]

            // publicando content
            create-cols([*#tempo_content*], [#descricao_content], "wide")
            
    // case more than one entry
    } else if type(dados_ensino) == array {
        for curso in dados_ensino.rev() {
            // criando variáveis
            let disciplinas_text = str
            let tempo_content = []

            // criando tempo_content
            if curso.FLAG-PERIODO == "ATUAL" {
                tempo_content = [#curso.MES-INICIO/#curso.ANO-INICIO - atual]
            } else {
                tempo_content = [#curso.MES-INICIO/#curso.ANO-INICIO - #curso.MES-FIM/#curso.ANO-FIM]
            }
            
            // criando nível
            let nivel = str(curso.TIPO-ENSINO.slice(0, 1) + lower(curso.TIPO-ENSINO.slice(1)))

            // corrigir nível
            if nivel == "Graduacao" {
                nivel = "Graduação"
            } else if nivel == "Pos-graduacao" {
                nivel = "Pós-Graduação"
            }

            if "DISCIPLINA" in curso.keys() {
                let disciplinas = curso.at("DISCIPLINA")
                
                let ministradas = ()

                for area in disciplinas { 
                    ministradas.push(area._text)
                }

                disciplinas_text = ministradas.join("; ")

                disciplinas_text = "Disciplinas ministradas: " + disciplinas_text
            }
                
            let descricao_content = [#nivel, #curso.NOME-CURSO #linebreak()#text(rgb("B2B2B2"), size: 0.85em, disciplinas_text)]

            // publicando content
            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    }
}

// Função create-comissions: cria commissões (subárea Atuação, usado em create-experience())
// Argumento:
//  - dados_comissoes: o banco de dados filtrado para vagas
#let create-commissions(dados_comissoes) = {
    // criando variáveis
    let tempo_content = []
    let descricao_content = []
    
    // caso: somente uma entrada
    if type(dados_comissoes) == dictionary {
        if "ATIVIDADES-DE-CONSELHO-COMISSAO-E-CONSULTORIA"in dados_comissoes.keys() {
            [== Atividades (Comissões) <comissoes_atuacao>]
            
            // criando variaveis
            let tempo_content = []
            if dados_comissoes.FLAG-PERIODO == "ATUAL" {
                tempo_content = [#dados_comissoes.MES-INICIO/#dados_comissoes.ANO-INICIO - atual]
            } else {
                tempo_content = [#dados_comissoes.MES-INICIO/#posdados_comissoescao.ANO-INICIO - #dados_comissoes.MES-FIM/#dados_comissoes.ANO-FIM]
            }
            
            descricao_content = [
                #dados_comissoes.ESPECIFICACAO, #emph(dados_comissoes.NOME-ORGAO)
            ]
            
            // publicando content
            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    // caso: mais de uma entrada
    } else if type(dados_comissoes) == array {
        [== Atividades (Comissões) <comissoes_atuacao>]
        
        for posicao in dados_comissoes.rev() {
            if posicao.FLAG-PERIODO == "ATUAL" {
                tempo_content = [#posicao.MES-INICIO/#posicao.ANO-INICIO - atual]
            } else {
                tempo_content = [#posicao.MES-INICIO/#posicao.ANO-INICIO - #posicao.MES-FIM/#posicao.ANO-FIM]
            }
            
            descricao_content = [
                #posicao.ESPECIFICACAO, #emph(posicao.NOME-ORGAO)
            ]
            
            // publicando content
            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    }
}

// Função create-experience(): cria atuação profissional es subáreas
// Argumento:
// - detalhes: o banco de dados de Lattes (TOML File)
#let create-experience(detalhes) = {

    // criando banco de dados
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    let atuacao_filtered = atuacao.filter(
        entry => entry.SEQUENCIA-IMPORTANCIA != ""
    )

    // TODO: necessário de ordenar
    // tem dois tipos (array e dictionary)
    // processo para ordenar correto
    let helper_array = ()
    for entrada in atuacao_filtered {
        
        if type(entrada.VINCULOS) == array {
            entrada.VINCULOS = entrada.VINCULOS.sorted(
                key: (item) => (item.ANO-FIM, item.ANO-INICIO, item.MES-FIM, item.MES-INICIO)
            )

            for position in entrada.VINCULOS {
                // criando ordem para ordenar depois
                if "ORDER1" in entrada.keys() {
                    // caso ano é mais novo na entrada do que a última entrada salva
                    if int(position.ANO-FIM) > int(entrada.ORDER1) {
                        entrada.insert("ORDER1", position.ANO-FIM)
                        entrada.insert("ORDER2", position.ANO-INICIO)
                        entrada.insert("ORDER3", position.MES-FIM)
                        entrada.insert("ORDER4", entrada.VINCULOS.at(0).MES-INICIO)    
                    // caso: ano mesmo, mas mês mais atual
                    } else if int(position.ANO-FIM) == int(entrada.ORDER1) {
                        if int(position.MES-FIM) > int(entrada.ORDER3) {
                            entrada.insert("ORDER1", position.ANO-FIM)
                            entrada.insert("ORDER2", position.ANO-INICIO)
                            entrada.insert("ORDER3", position.MES-FIM)
                            entrada.insert("ORDER4", entrada.VINCULOS.at(0).MES-INICIO)   
                        // caso: ano e mês fim mesmo, checar ano inicio
                        } else if int(position.MES-FIM) == int(entrada.ORDER3) {
                            if int(position.ANO-INICIO) > int(entrada.ORDER2) {
                                entrada.insert("ORDER1", position.ANO-FIM)
                                entrada.insert("ORDER2", position.ANO-INICIO)
                                entrada.insert("ORDER3", position.MES-FIM)
                                entrada.insert("ORDER4", entrada.VINCULOS.at(0).MES-INICIO)
                            // caso, ano/mes fim mesmo e ano inicio mesmo, checar mes inicio
                            } else if int(position.ANO-INICIO) == int(entrada.ORDER2) {
                                if int(position.MES-INICIO) > int(entrada.ORDER4) {
                                    entrada.insert("ORDER1", position.ANO-FIM)
                                    entrada.insert("ORDER2", position.ANO-INICIO)
                                    entrada.insert("ORDER3", position.MES-FIM)
                                    entrada.insert("ORDER4", entrada.VINCULOS.at(0).MES-INICIO)
                                }
                            }
                        }
                    }
                } else {
                    entrada.insert("ORDER1", position.ANO-FIM)
                    entrada.insert("ORDER2", position.ANO-INICIO)
                    entrada.insert("ORDER3", position.MES-FIM)
                    entrada.insert("ORDER4", entrada.VINCULOS.at(0).MES-INICIO)
                }
            }

            helper_array.push(entrada)
        } else if type(entrada.VINCULOS) == dictionary {
            entrada.insert("ORDER1", entrada.VINCULOS.ANO-FIM)
            entrada.insert("ORDER2", entrada.VINCULOS.ANO-INICIO)
            entrada.insert("ORDER3", entrada.VINCULOS.MES-FIM)
            entrada.insert("ORDER4", entrada.VINCULOS.MES-INICIO)
            
            helper_array.push(entrada)
        }   
    }

    helper_array = helper_array.sorted(
        key: (item) => (item.ORDER1, item.ORDER2, item.ORDER3, item.ORDER4, item.NOME-INSTITUICAO)
    )

    atuacao = helper_array

    if atuacao.len() > 0 {
        [= Atuação profissional <atuacao>]
        // loop para cada entrada
        for entrada in atuacao.rev() {
            
            // criando vínculos
            // ao mínimo tem um vínculo
            let vinculos = ()
            if entrada.SEQUENCIA-IMPORTANCIA != "" {
                [== #entrada.NOME-INSTITUICAO]

                vinculos = entrada.VINCULOS
                if vinculos.len() > 0 {
                    create-positions(vinculos)
                }
                linebreak()
            }

            // criando comissoes
            let comissoes_atuacao = ()
            
            if "ATIVIDADES-DE-CONSELHO-COMISSAO-E-CONSULTORIA" in entrada.keys() {
                if "CONSELHO-COMISSAO-E-CONSULTORIA" in entrada.ATIVIDADES-DE-CONSELHO-COMISSAO-E-CONSULTORIA.keys() {
                   comissoes_atuacao = entrada.ATIVIDADES-DE-CONSELHO-COMISSAO-E-CONSULTORIA.at("CONSELHO-COMISSAO-E-CONSULTORIA")

                   comissoes_atuacao = comissoes_atuacao.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-INICIO, item.MES-FIM))
                }
            } 
                                   
            if comissoes_atuacao.len() > 0 {
                create-commissions(comissoes_atuacao)
                linebreak()
            }
            
            // criando ensino
            let ensino = ()

            if "ATIVIDADES-DE-ENSINO" in entrada.keys() {
                // [ENTRADA #entrada]
                if "ENSINO" in entrada.ATIVIDADES-DE-ENSINO.keys() {
                   ensino = entrada.ATIVIDADES-DE-ENSINO.at("ENSINO")
                }
            } 

            ensino = ensino.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-INICIO, item.MES-FIM))
            
            
            if ensino.len() > 0 {
                create-teaching(ensino) 
                linebreak()
            } 
        }
    }

    line(length: 100%)
}