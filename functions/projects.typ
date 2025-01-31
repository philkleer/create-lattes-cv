#import "utils.typ": *

// Função create-projects(): Cria lista de projetos de pesquisa e ensino (só "completo")
// Argumento:
//  - detalhes: o banco de dados de Lattes (TOML File)
#let create-projects(detalhes) = {
    // criando bancos básicos
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    let projetos_ensino = array
    let projetos_pesquisa = array
    let projetos_desenvolvimento = array
    let projetos_extensao = array
    let projetos_outros = array

    // criando banco de dados para pesquisa e para ensino
    for entry in atuacao {
        // filtrar outras atividades
        if "ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO" in entry.keys() {

            let projetos = entry.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO.at("PARTICIPACAO-EM-PROJETO")
            
            // ordem os projetos
            let projetos = projetos.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-FIM, item.MES-INICIO))

            // criando array para pesquisa
            projetos_pesquisa = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "PESQUISA"
            )

            // criando array para ensino
            projetos_ensino = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "ENSINO"
            )

            // TODO: não tenho certeza sobre o key
            // criando array para desenvolvimento
            projetos_desenvolvimento = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "DESENVOLVIMENTO_TECNOLOGICA"
            )

            // TODO: não tenho certeza sobre o key
            // criando array para extensão
            projetos_extensao = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "EXTENSAO"
            )

            // TODO: não tenho certeza sobre o key
            // criando array para outros tipos de projetos
            projetos_outros = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "OUTROS_PROJETOS"
            )
        }
    }

    if projetos_pesquisa.len() > 0 or projetos_ensino.len() > 0 or projetos_desenvolvimento.len() > 0 or projetos_extensao.len() > 0 or projetos_outros.len() > 0 {
        [= Projetos <projetos_atuacao>]

        // criando área de pesquisa
        if projetos_pesquisa.len() > 0 {
            [== Projetos de pesquisa]

            for project in projetos_pesquisa.rev() {
                // criando variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criando membros de projeto
                if "EQUIPE-DO-PROJETO" in subset.keys() {
                    // create array of persons involved
                    let integrantes = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                    // loop pelas entradas de integrantes para extrair nomes e formatar nomes
                    for integrante in integrantes {
                        if type(integrante) == dictionary {
                            if integrante.FLAG-RESPONSAVEL == "SIM" {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0) + " (responsável)"
                                membros.push(nome)  
                            } else {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                membros.push(nome.at(0))   
                            }
                        } else if type(integrante) == array {
                            if integrante.at(0) == "NOME-PARA-CITACAO" {
                                let nome = integrante.at(1).split(";")
                                nome = nome.at(0) + ". (responsável)"
                                membros.push(nome)  
                            }
                        }
                    }
                }

                // enumerar producoes no projeto
                let producoes = 0

                if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                    producoes = subset.PRODUCOES-CT-DO-PROJETO.PRODUCAO-CT-DO-PROJETO.len()
                }

                // criando outras informações
                let informacao = subset.DESCRICAO-DO-PROJETO
                informacao = replace-quotes(informacao)
                
                // criando content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)
                ]

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            linebreak()
        }

        // criando área de desenvolvimento tecnologica
        if projetos_desenvolvimento.len() > 0 {
            [== Projetos de desenvolvimento tecnologica]

            for project in projetos_desenvolvimento.rev() {
                // criando variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criando membros de projeto
                if "EQUIPE-DO-PROJETO" in subset.keys() {
                    // create array of persons involved
                    let integrantes = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                    // loop pelas entradas de integrantes para extrair nomes e formatar nomes
                    for integrante in integrantes {
                        if type(integrante) == dictionary {
                            if integrante.FLAG-RESPONSAVEL == "SIM" {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0) + " (responsável)"
                                membros.push(nome)  
                            } else {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0)
                                membros.push(nome)   
                            }
                        } else if type(integrante) == array {
                            if integrante.at(0) == "NOME-PARA-CITACAO" {
                                let nome = integrante.at(1).split(";")
                                nome = nome + ". (responsável)"
                                membros.push(nome)  
                            }
                        }
                    }
                }

                // enumerar producoes no projeto
                let producoes = 0

                if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                    producoes = subset.PRODUCOES-CT-DO-PROJETO.PRODUCAO-CT-DO-PROJETO.len()
                }

                // criando outras informações
                let informacao = subset.DESCRICAO-DO-PROJETO
                informacao = replace-quotes(informacao)
                
                // criando content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)
                ]

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            linebreak()
        }

        // criando área de extensão
        if projetos_extensao.len() > 0 {
            [== Projetos de extensão]

            for project in projetos_extensao.rev() {
                // criando variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criando membros de projeto
                if "EQUIPE-DO-PROJETO" in subset.keys() {
                    // create array of persons involved
                    let integrantes = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                    // loop pelas entradas de integrantes para extrair nomes e formatar nomes
                    for integrante in integrantes {
                        if type(integrante) == dictionary {
                            if integrante.FLAG-RESPONSAVEL == "SIM" {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0) + " (responsável)"
                                membros.push(nome)  
                            } else {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0)
                                membros.push(nome)   
                            }
                        } else if type(integrante) == array {
                            if integrante.at(0) == "NOME-PARA-CITACAO" {
                                let nome = integrante.at(1).split(";")
                                nome = nome + ". (responsável)"
                                membros.push(nome)  
                            }
                        }
                    }
                }

                // enumerar producoes no projeto
                let producoes = 0

                if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                    producoes = subset.PRODUCOES-CT-DO-PROJETO.PRODUCAO-CT-DO-PROJETO.len()
                }

                // criando outras informações
                let informacao = subset.DESCRICAO-DO-PROJETO
                informacao = replace-quotes(informacao)
                
                // criando content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)
                ]

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            linebreak()
        }
        
        // área projetos de ensino
        if projetos_ensino.len() > 0 {
            [== Projetos de ensino]

            for project in projetos_ensino.rev() {
                // criando variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criando membros de projeto
                if "EQUIPE-DO-PROJETO" in subset.keys() {
                    // create array of persons involved
                    let integrantes = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                    // loop pelas entradas de integrantes para extrair nomes e formatar nomes
                    for integrante in integrantes {
                        if type(integrante) == dictionary {
                            if integrante.FLAG-RESPONSAVEL == "SIM" {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0) + " (responsável)"
                                membros.push(nome)  
                            } else {
                                let nome = integrante.NOME-PARA-CITACAO.split(";")
                                nome = nome.at(0)
                                membros.push(nome)   
                            }
                        } else if type(integrante) == array {
                            if integrante.at(0) == "NOME-PARA-CITACAO" {
                                let nome = integrante.at(1).split(";")
                                nome = nome.at(0) + " (responsável)"
                                membros.push(nome)  
                            }
                        }
                    }
                }

                // enumerar producoes no projeto
                let producoes = 0

                if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                    producoes = subset.PRODUCOES-CT-DO-PROJETO.PRODUCAO-CT-DO-PROJETO.len()
                }

                // criando outras informações
                let informacao = subset.DESCRICAO-DO-PROJETO
                informacao = replace-quotes(informacao)
                
                // criando content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)
                ]

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            
            linebreak()
        }

        // criando área de extensão
        if projetos_outros.len() > 0 {
            [== Outros tipos de projetos]

            for project in projetos_outros.rev() {
                // criando variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criando membros de projeto
                if "EQUIPE-DO-PROJETO" in subset.keys() {
                    // create array of persons involved
                    let integrantes = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                    // loop pelas entradas de integrantes para extrair nomes e formatar nomes
                    for integrante in integrantes {
                        if type(integrante) == dictionary {
                            if integrante.FLAG-RESPONSAVEL == "SIM" {
                                let name_parts = integrante.NOME-PARA-CITACAO.split(", ")
                                let name = upper(name_parts.at(0)) + ", " + upper(name_parts.at(1).first()) + ". (responsável)"
                                membros.push(name)  
                            } else {
                                let name_parts = integrante.NOME-PARA-CITACAO.split(", ")
                                let name = upper(name_parts.at(0)) + ", " + upper(name_parts.at(1).first()) + "."
                                membros.push(name)   
                            }
                        } else if type(integrante) == array {
                            if integrante.at(0) == "NOME-PARA-CITACAO" {
                                let name_parts = integrante.at(1).split(", ")
                                let name = upper(name_parts.at(0)) + ", " + upper(name_parts.at(1).first()) + ". (responsável)"
                                membros.push(name)  
                            }
                        }
                    }
                }

                // enumerar producoes no projeto
                let producoes = 0

                if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                    producoes = subset.PRODUCOES-CT-DO-PROJETO.PRODUCAO-CT-DO-PROJETO.len()
                }

                // criando outras informações
                let informacao = subset.DESCRICAO-DO-PROJETO
                informacao = replace-quotes(informacao)
                
                // criando content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)
                ]

                // publicando content
                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            linebreak()
        }

        line(length: 100%)
    }
}