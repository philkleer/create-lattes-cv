#import "utils.typ": *

// Função create-projects-ino(): Cria projetos de CT (dentro de inovação, usado em create-innovations())
// Argumentos:
//  - dados_pesquisa: o banco de dados com projetos de pesquisa
//  - dados_ensino: o banco de dados com projetos de ensino
#let create-projects-ino(dados_pesquisa, dados_tecnico, dados_extensao, dados_ensino) = {           
    // para pesquisa
    // somente se tiver uma entrada ao mínimo
    if dados_pesquisa.len() > 0 {
        [=== Projeto de pesquisa]

        let i = dados_pesquisa.len() + 1

        for projeto in dados_pesquisa {
            // criando um banco de dados para projeto
            let subset = projeto.at("PROJETO-DE-PESQUISA")

            // declara variáveis (dependente da situacao)
            let ano = ""
            let situacao = ""
            let tipo = ""
            let membros = ()
            let subvencoes = ()
            let cta = 0
            
            // variáveis declaradas direitamente
            let titulo = subset.NOME-DO-PROJETO
            let informacao = subset.DESCRICAO-DO-PROJETO

            // corrigindo quotes em código HTML
            informacao = replace-quotes(informacao)

            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#subset.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#subset.ANO-INICIO - #subset.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
                
            // criando membros
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criando array para pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                // loop para cada entrada em integrantes
                for pessoa in pessoas {
                    // se tem somente uma pessoa
                    if type(pessoa) == dictionary {
                        // se é responsável ou não
                        if pessoa.FLAG-RESPONSAVEL == "SIM" {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome)  
                        } else {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            membros.push(nome.at(0))   
                        }
                    // tem mais de uma pessoa
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-PARA-CITACAO" {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome)  
                        }
                    }
                }
            }

            // criando financiadores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criando array de financiadores
                let pessoas = subset.FINANCIADORES-DO-PROJETO.at("FINANCIADOR-DO-PROJETO")

                // loop para cada entrada de financiadores
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        subvencoes.push(pessoa.NOME-INSTITUICAO)
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-INSTITUICAO" {
                            subvencoes.push(pessoa.at(1))
                        }
                    }
                }
            }

            // calcular soma de cta
            for publicacao in subset.PRODUCOES-CT-DO-PROJETO {
                // caso tem mais de uma publicacao
                if type(publicacao.at(1)) == array {
                    cta = publicacao.at(1).len()
                // caso tem somente uma publicaco
                } else if type(publicacao.at(1)) == dictionary {
                    cta = 1
                }
            }

            // criando conteúdo
            // criando strings para cada informação
            let membros_string = []
            if membros.len() > 0 {
                membros_string = [#text(rgb("B2B2B2"), size: 0.85em, "Integrante(s): "+ membros.join("; "))#linebreak()]
            } else {
                membros_string = []
            }
                
            // conteúdo de financiadores
            let subvencoes_string = []
            if subvencoes.len() > 0 {
                subvencoes_string = [#text(rgb("B2B2B2"), size: 0.85em, "Financiador(es): " + subvencoes.join("; "))#linebreak()]
            } else {
                subvencoes_string = []
            }
            
            // conteúdo soma de publicações CTA
            let cta_string = []
            if cta > 0 {
                cta_string = [#text(rgb("B2B2B2"), size: 0.85em, "Número de produções C, T & A: " + cta)]
            } else {
                cta_string = []
            }

            let mais_informacoes = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)#linebreak()]
            
            let descricao_content = [#titulo #linebreak() #mais_informacoes #membros_string #subvencoes_string #cta_string]

            // publicando content
            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }

    // para projetos de desenvolvimento tecnico
    if dados_tecnico.len() > 0 {
        [=== Projeto de desenvolvimento tecnológico]

        let i = dados_tecnico.len() + 1

        for projeto in dados_tecnico {
            // criando um banco de dados para projeto
            let subset = projeto.at("PROJETO-DE-PESQUISA")

            // declara variáveis (dependente da situacao)
            let ano = ""
            let situacao = ""
            let tipo = ""
            let membros = ()
            let subvencoes = ()
            let cta = 0
            
            // variáveis declaradas direitamente
            let titulo = subset.NOME-DO-PROJETO
            let informacao = subset.DESCRICAO-DO-PROJETO

            // corrigindo quotes em código HTML
            informacao = replace-quotes(informacao)

            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#subset.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#subset.ANO-INICIO - #subset.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
                
            // criando membros
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criando array para pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                // loop para cada entrada em integrantes
                for pessoa in pessoas {
                    // se tem somente uma pessoa
                    if type(pessoa) == dictionary {
                        // se é responsável ou não
                        if pessoa.FLAG-RESPONSAVEL == "SIM" {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome)  
                        } else {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            membros.push(nome.at(0))   
                        }
                    // tem mais de uma pessoa
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-PARA-CITACAO" {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + ". (responsável)"
                            membros.push(nome)  
                        }
                    }
                }
            }

            // criando financiadores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criando array de financiadores
                let pessoas = subset.FINANCIADORES-DO-PROJETO.at("FINANCIADOR-DO-PROJETO")

                // loop para cada entrada de financiadores
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        subvencoes.push(pessoa.NOME-INSTITUICAO)
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-INSTITUICAO" {
                            subvencoes.push(pessoa.at(1))
                        }
                    }
                }
            }

            // calcular soma de cta
            for publicacao in subset.PRODUCOES-CT-DO-PROJETO {
                // caso tem mais de uma publicacao
                if type(publicacao.at(1)) == array {
                    cta = publicacao.at(1).len()
                // caso tem somente uma publicaco
                } else if type(publicacao.at(1)) == dictionary {
                    cta = 1
                }
            }

            // criando conteúdo
            // criando strings para cada informação
            let membros_string = []
            if membros.len() > 0 {
                membros_string = [#text(rgb("B2B2B2"), size: 0.85em, "Integrante(s): "+ membros.join("; "))#linebreak()]
            } else {
                membros_string = []
            }
                
            // conteúdo de financiadores
            let subvencoes_string = []
            if subvencoes.len() > 0 {
                subvencoes_string = [#text(rgb("B2B2B2"), size: 0.85em, "Financiador(es): " + subvencoes.join("; "))#linebreak()]
            } else {
                subvencoes_string = []
            }
            
            // conteúdo soma de publicações CTA
            let cta_string = []
            if cta > 0 {
                cta_string = [#text(rgb("B2B2B2"), size: 0.85em, "Número de produções C, T & A: " + cta)]
            } else {
                cta_string = []
            }

            let mais_informacoes = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)#linebreak()]
            
            let descricao_content = [#titulo #linebreak() #mais_informacoes #membros_string #subvencoes_string #cta_string]

            // publicando content
            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }

    // para extensao
    if dados_extensao.len() > 0 {
        [=== Projeto de extensao]

        let i = dados_extensao.len() + 1

        for projeto in dados_extensao {
            // criando um banco de dados para projeto
            let subset = projeto.at("PROJETO-DE-PESQUISA")

            // declara variáveis (dependente da situacao)
            let ano = ""
            let situacao = ""
            let tipo = ""
            let membros = ()
            let subvencoes = ()
            let cta = 0
            
            // variáveis declaradas direitamente
            let titulo = subset.NOME-DO-PROJETO
            let informacao = subset.DESCRICAO-DO-PROJETO

            // corrigindo quotes em código HTML
            informacao = replace-quotes(informacao)

            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#subset.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#subset.ANO-INICIO - #subset.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
                
            // criando membros
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criando array para pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                // loop para cada entrada em integrantes
                for pessoa in pessoas {
                    // se tem somente uma pessoa
                    if type(pessoa) == dictionary {
                        // se é responsável ou não
                        if pessoa.FLAG-RESPONSAVEL == "SIM" {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome)  
                        } else {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            membros.push(nome.at(0))   
                        }
                    // tem mais de uma pessoa
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-PARA-CITACAO" {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome)  
                        }
                    }
                }
            }

            // criando financiadores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criando array de financiadores
                let pessoas = subset.FINANCIADORES-DO-PROJETO.at("FINANCIADOR-DO-PROJETO")

                // loop para cada entrada de financiadores
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        subvencoes.push(pessoa.NOME-INSTITUICAO)
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-INSTITUICAO" {
                            subvencoes.push(pessoa.at(1))
                        }
                    }
                }
            }

            // calcular soma de cta
            if "PRODUCOES-CT-DO-PROJETO" in subset.keys() {
                for publicacao in subset.PRODUCOES-CT-DO-PROJETO {
                    // caso tem mais de uma publicacao
                    if type(publicacao.at(1)) == array {
                        cta = publicacao.at(1).len()
                    // caso tem somente uma publicaco
                    } else if type(publicacao.at(1)) == dictionary {
                        cta = 1
                    }
                }
            }
            

            // criando conteúdo
            // criando strings para cada informação
            let membros_string = []
            if membros.len() > 0 {
                membros_string = [#text(rgb("B2B2B2"), size: 0.85em, "Integrante(s): "+ membros.join("; "))#linebreak()]
            } else {
                membros_string = []
            }
                
            // conteúdo de financiadores
            let subvencoes_string = []
            if subvencoes.len() > 0 {
                subvencoes_string = [#text(rgb("B2B2B2"), size: 0.85em, "Financiador(es): " + subvencoes.join("; "))#linebreak()]
            } else {
                subvencoes_string = []
            }
            
            // conteúdo soma de publicações CTA
            let cta_string = []
            if cta > 0 {
                cta_string = [#text(rgb("B2B2B2"), size: 0.85em, "Número de produções C, T & A: " + cta)]
            } else {
                cta_string = []
            }

            let mais_informacoes = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + informacao)#linebreak()]
            
            let descricao_content = [#titulo #linebreak() #mais_informacoes #membros_string #subvencoes_string #cta_string]

            // publicando content
            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }

    // para ensino
    if dados_ensino.len() > 0 {

        [=== Projeto de ensino]

        let i = dados_ensino.len() + 1

        for projeto in dados_ensino.rev() {
            // criando banco de dados para projeto
            let subset = projeto.at("PROJETO-DE-PESQUISA")
            
            // criando variáveis
            let ano = ""
            let situacao = ""
            let tipo = ""
            let membros = ()
            let subvencoes = ()
            let cta = 0
            let titulo = subset.NOME-DO-PROJETO
            let informacao = subset.DESCRICAO-DO-PROJETO

            // corrigindo quotes em código HTML
            informacao = replace-quotes(informacao)


            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#subset.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#subset.ANO-INICIO - #subset.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
            
            // criando membros do projeto
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criando array de pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                // loop por entradas de pessoas
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        if pessoa.FLAG-RESPONSAVEL == "SIM" {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome) 
                        } else {
                            let nome = pessoa.NOME-PARA-CITACAO.split(";")
                            membros.push(nome.at(0)) 
                        }
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-PARA-CITACAO" {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(";")
                            nome = nome.at(0) + " (responsável)"
                            membros.push(nome) 
                        }
                    }
                }
            }

            // criando financidores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criando array de financiadores
                let pessoas = subset.FINANCIADORES-DO-PROJETO.at("FINANCIADOR-DO-PROJETO")

                // loop pelas entradas de financiadores
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        subvencoes.push(pessoa.NOME-INSTITUICAO)
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-INSTITUICAO" {
                            subvencoes.push(pessoa.at(1))
                        }
                    }
                }
            }

            // calcular publicacoes de cta           
            for publicacao in subset.PRODUCOES-CT-DO-PROJETO {
                if type(publicacao.at(1)) == array {
                    cta = publicacao.at(1).len()
                } else if type(publicacao.at(1)) == dictionary {
                    cta = 1
                }
            }

            // criando content                
            let descricao = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: "+ informacao)#linebreak()]

            // criando string para membros
            let membros_string = []
            if membros.len() > 0 {
                membros_string = [#text(rgb("B2B2B2"), size: 0.85em, "Integrante(s): "+ membros.join("; "))#linebreak()]
            } else {
                membros_string = []
            }
                
            // criando string para subvencoes
            let subvencoes_string = []
            if subvencoes.len() > 0 {
                subvencoes_string = [#text(rgb("B2B2B2"), size: 0.85em, "Financiador(es): " + subvencoes.join("; "))#linebreak()]
            } else {
                subvencoes_string = []
            }
            
            // criando string para cta
            let cta_string = []
            if cta > 0 {
                cta_string = [#text(rgb("B2B2B2"), size: 0.85em, "Número de produções C, T & A: "+ str(cta))]
            } else {
                cta_string = []
            }

            // criando content
            let descricao_content = [#titulo #linebreak() #descricao #membros_string #subvencoes_string #cta_string]

            // publicando content
            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }
}

// Função create-innovations(): Cria Inovações 
// Argumento:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-innovations(detalhes) = {
    // criando banco de dados geral
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    // criando variáveis
    let projetos = ()
    let proj_pesquisa = ()
    let proj_tecnico = ()
    let proj_extensao = ()
    let proj_ensino = ()
    let eventos = () 
    let congressos = () 
    let marker = true

    // criando a soma de
    // criando um loop para cada atuação para recolher todos os projetos
    for entrada in atuacao {
        // set to empty
        projetos = ()
        proj_pesquisa = ()
        proj_tecnico = ()
        proj_extensao = ()
        proj_ensino = ()
        
        // criando o banco de dados
        if "ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO" in entrada.keys() {
            projetos = entrada.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO.at("PARTICIPACAO-EM-PROJETO")
        }
        
        if projetos.len() > 0 { 
            // ordenar por ano
            let projetos_sorted = projetos.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-FIM, item.MES-INICIO))


            // filtrar pesquisa
            proj_pesquisa = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "PESQUISA" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar desenvolvimento técnico
            proj_tecnico = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "DESENVOLVIMENTO_TECNICO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar extensão
            proj_extensao = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "EXTENSAO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar ensino
            proj_ensino = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "ENSINO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )
        }

        // criando cabeçalho
        if proj_pesquisa.len() > 0 or proj_ensino.len() > 0 {
            [= Inovação <inovacao>]
            marker = false
        }

        // Projetos primeiro
        // TODO: there need to be the rest of it
        if proj_pesquisa.len() > 0 or proj_tecnico.len() > 0 or proj_extensao.len() > 0 or proj_ensino.len() > 0 {
            [= Inovação]
            [== Projetos <projetos_inovacao>]

            create-projects-ino(proj_pesquisa, proj_tecnico, proj_extensao, proj_ensino)  

            linebreak()

            line(length: 100%)  
        }   
    }
}