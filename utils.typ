// Neste arquivo você encontra funções para criar os vários inputs
// Cada função possui uma descrição preliminar
// As variáveis no nível local estão em português
// Variáveis globais (as que são passadas adiante) estão em inglês
// Funcções também estão em inglês

// imports
#import "@preview/datify:0.1.3": *

// Função _create-cols: define estilo e tabela
// Argumentos:
// - left: o conteúdo a ser colocado na primeira coluna (Tipo: Qualquer)
// - right: o conteúdo a ser colocado na segunda coluna (Tipo: Qualquer)
// - type: escolha a separação das colunas (tipos: "small", "wide", "enum", "lastpage")
// - ..args: argumentos nomeados adicionais para personalização

#let _create-cols(left, right, type, ..args) = {
  
  // Defina o estilo do bloco sem espaçamento abaixo
  set block(below: 0pt)
  let col_width = (0.85fr, 5fr)
  if type == "small" {
    col_width = (0.87fr, 5fr)
  } else if type == "wide" {
    col_width = (1.1fr, 4fr)
  } else if type == "enum" {
    col_width = (0.4fr, 5fr)
  } else if type == "lastpage" {
    col_width = (5fr, 0.4fr)
  }

  // Crie uma tabela com larguras de coluna especificadas e sem bordas
  table(
    columns: col_width, // Defina as larguras das colunas
    stroke: none, // Sem bordas
    
    // Espalhe quaisquer argumentos nomeados
    ..args.named(),
    
    // Insira o conteúdo da esquerda e da direita na tabela
    left,
    right,
  )
}

// Função create-cols: Colocando o input na tabela
// Argumentos:
// - left-side: o conteúdo a ser alinhado à esquerda (Tipo: Qualquer)
// - right-side: o conteúdo a ser formatado como um parágrafo com alinhamento justificado (Tipo: Qualquer)
// - type: string que define o tipo: "small", "wide", "enum" ou "lastpage"
#let create-cols(left-side, right-side, type) = {
  
  // Chame o _cv-cols com os parâmetros left-side alinhado à esquerda e right-side justificado
  if type == "lastpage" {
    _create-cols(
        align(right, left-side),
        par(right-side, justify:false),
        type
    )
  } else {
    _create-cols(
        // Alinhe o conteúdo da left-side à direita
        align(right, left-side),
        // Formate o conteúdo da right-side como um parágrafo com alinhamento justificado
        align(left, par(right-side, justify: true)),
        type
        )
  }
}

// Formatar os nomes de autores/membros etc.
// Formata os nomes no estilo de ABNT
// argumentos:
//  - autores: array de autores
//  - eu: indicaco de nome para destacar
#let format_authors(autores, eu) = {
    // criar array para pegar os nomes
    let formatted_authors = ()

    // criar formato de ABNT para cada autor
    for autor in autores {
        // caso so uma pessoa
        if type(autor) == dictionary {
            let parts = autor.NOME-PARA-CITACAO.split(", ")
            let nome = upper(parts.at(0)) + ", " + parts.at(1).first() + "."

            formatted_authors.push(nome)
        // caso de mais de uma pessoa
        } else if type(autor) == array {
            if autor.at(0) == "NOME-PARA-CITACAO" {
                let parts = autores.NOME-PARA-CITACAO.split(", ")
                let nome = upper(parts.at(0)) + ", " + parts.at(1).first() + "."
                formatted_authors.push(nome)
            }
        } 
    }
    
    // criar string para destacar o nome
    formatted_authors = formatted_authors.join("; ")
    
    // destacar o nome
    if not eu == none {
        if type(formatted_authors) != none and formatted_authors != none {
            let pesquisa = formatted_authors.match(eu)
            if pesquisa.start == 0 {
                formatted_authors = [*#formatted_authors.slice(pesquisa.start, pesquisa.end)*#formatted_authors.slice(pesquisa.end)]
            } else if pesquisa.start != none {
                formatted_authors = [#formatted_authors.slice(0, pesquisa.start)*#formatted_authors.slice(pesquisa.start, pesquisa.end)*#formatted_authors.slice(pesquisa.end)]
            }
        }
    }

    // retornar o novo formato com destacar o nome
    return [#formatted_authors]        
}


// TODO: NEW FUNCTIONS
// próxima funcção é de livros!
// Criar área de identificação
// Argumentos
// - detalhes: o banco de dados de Lattes (TOML)
#let create-identification(detalhes) = {

    let identificacao = detalhes.DADOS-GERAIS

    // criar variáveis
    let author = identificacao.NOME-COMPLETO
    
    // criar filiação
    let filiacao = content
    
    // criar content
    if identificacao.NOME-DO-PAI != "" {
        if identificacao.NOME-DA-MAE != "" {
            filiacao = [#identificacao.NOME-DA-MAE, #identificacao.NOME-DO-PAI]
        } else {
            filiacao = [#identificacao.NOME-DO-PAI]
        }
    } else if identificacao.NOME-DO-PAI == "" {
        if identificacao.NOME-DA-MAE != "" {
            filiacao = [#identificacao.NOME-DA-MAE]
        }
    }

    // criar nascimento
    let birth = identificacao.DATA-NASCIMENTO
    let date_birth = datetime(
        year: int(birth.slice(4, 8)), 
        month: int(birth.slice(2, 4)), 
        day: int(birth.slice(0, 2))
    )

    // criar endereço (depende de FLAG)
    let endereco = []
    if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_RESIDENCIAL" {
        endereco = [
            #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.LOGRADOURO,
            #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.BAIRRO - #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.CIDADE,
            #identificacao.ENDERECO.ENDERECO-RESIDENCIAL.CEP
        ]
    } else if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_PROFISSIONAL" {
        endereco = [
            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.NOME-INSTITUICAO-EMPRESA, #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.NOME-ORGAO, #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.NOME-UNIDADE

            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.LOGRADOURO,
            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.BAIRRO - #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.CIDADE,
            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.CEP

            #identificacao.ENDERECO.ENDERECO-PROFISSIONAL.HOME-PAGE
        ]
    }

    // create telefon and email
    let telefon = str
    let email = str
    if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_RESIDENCIAL" {
        telefon = "(" + identificacao.ENDERECO.ENDERECO-RESIDENCIAL.DDD + ") " + identificacao.ENDERECO.ENDERECO-RESIDENCIAL.TELEFONE
        email = identificacao.ENDERECO.ENDERECO-RESIDENCIAL.E-MAIL 
    } else if identificacao.ENDERECO.FLAG-DE-PREFERENCIA == "ENDERECO_PROFISSIONAL" {
        telefon = "(" + identificacao.ENDERECO.ENDERECO-PROFISSIONAL.DDD + ") " + identificacao.ENDERECO.ENDERECO-PROFISSIONAL.TELEFONE
        email = identificacao.ENDERECO.ENDERECO-PROFISSIONAL.E-MAIL
    }

    // create lattes and orcid
    let lattes_id = detalhes.NUMERO-IDENTIFICADOR
    let orcid_id = identificacao.ORCID-ID

    // criar content
    [= Identificação]

    // criar nome
    _create-cols([*Nome*], identificacao.NOME-COMPLETO, "small")
    
    // criar filiação
    if filiacao != content {
        _create-cols([*Filiação*], filiacao, "small")
    }
     
    // criar nascimento
    _create-cols([*Nascimento*], custom-date-format(date_birth, "DD de Month de YYYY", "pt"), "small")
    
    // criar ID Lattes and ID ORCID
    _create-cols([*Lattes ID*], link("http://lattes.cnpq.br/" + lattes_id)[#lattes_id], "small")
    
    if orcid_id != "" {
        _create-cols([*Orcid ID*], link("https://orcid.org/" + orcid_id.slice(18))[#orcid_id.slice(18)], "small")
    }
    
    // criar citações
    _create-cols([*Nome em citações*], detalhes.DADOS-GERAIS.NOME-EM-CITACOES-BIBLIOGRAFICAS, "small")
    
    // criar endereço, telefone e e-mail
    if endereco != [] {
        _create-cols([*Endereço*], endereco, "small")
    }
        
    if telefon != "" {
        _create-cols([*Telefone*], telefon, "small")
    }
    
    if email != "" {
        _create-cols([*E-Mail*], link("mailto:" + email)[#email], "small")
    }
    

    linebreak()

    line(length: 100%)
}

// Criar área de idiomas
// Argumentos
// - detalhes: o banco de dados de Lattes (TOML)
#let create-languages(detalhes) = {

    // criar banco de dados
    let languages = detalhes.DADOS-GERAIS.IDIOMAS.IDIOMA

    // criar ordem: compreensão > falar > escrita > leitura > nome da língua
    languages = languages.sorted(key: (item) => (item.PROFICIENCIA-DE-COMPREENSAO, item.PROFICIENCIA-DE-FALA, item.PROFICIENCIA-DE-ESCRITA, item.PROFICIENCIA-DE-LEITURA, item.DESCRICAO-DO-IDIOMA))

    // loop pelas entradas nas idiomas
    let i = 0
    let count = languages.len() - 1 

    if languages.len() > 0 {
        [= Idiomas <idiomas>]

        // create columns with year and description
        while i <= count {
            let lang_content = languages.at(i).DESCRICAO-DO-IDIOMA
            let compreensao = languages.at(i).PROFICIENCIA-DE-COMPREENSAO
            let falar = languages.at(i).PROFICIENCIA-DE-FALA
            let escrita = languages.at(i).PROFICIENCIA-DE-ESCRITA
            let leitura = languages.at(i).PROFICIENCIA-DE-LEITURA
            let descricao_content = [compreende #compreensao, fala #falar, escreve #escrita, le #leitura]

            // publicar conteúdo
            _create-cols([*#lang_content*], [#descricao_content], "small")

            i += 1
        }   
    }
    linebreak()

    line(length: 100%)
}

// Criar área de prêmios e títulos
// Argumentos
// - detalhes: o banco de dados de Lattes (TOML)
#let create-prices(detalhes) = {
    // criar banco de dados
    let premios = detalhes.DADOS-GERAIS.PREMIOS-TITULOS.PREMIO-TITULO

    let i = premios.len() - 1
    let count = premios.len() - 1 

    // Loop pelas entradas
    if premios.len() > 0 {
        [= Prêmios e títulos <premios>]
        while i >= 0 {
            let ano_content = premios.at(i).ANO-DA-PREMIACAO

            let descricao_content = [#premios.at(i).NOME-DO-PREMIO-OU-TITULO, #emph(premios.at(i).NOME-DA-ENTIDADE-PROMOTORA)]

            // publicar conteúdo
            create-cols([*#ano_content*], [#descricao_content], "enum")

            // diminuir número
            i -= 1
        }
    }    
    linebreak()

    line(length: 100%)
}

// Criar área de formação complementar
// Argumentos
// - detalhes: o banco de dados de Lattes (TOML)
// - tipo_lattes: tipo de currículo Lattes
#let create-education(detalhes, tipo_lattes) = {
    let formacao = detalhes.DADOS-GERAIS.FORMACAO-ACADEMICA-TITULACAO

    if formacao.len() > 0 {
        [= Formação academica/titulação <formacao>]

        // loop pelas keys em dictionary e imprimir todas vagas
        for key in formacao.keys().rev() {
            // criar banco de dados
            let subset = formacao.at(key)
            
            // initialize variables
            let titulo = str
            let orientador = str
            let coorientador = str
            let conhecimento = content
            let tempo_content = []
            let descricao_content = []

            let curso = subset.NOME-CURSO
            let universidade = subset.NOME-INSTITUICAO

            // corrigir tipo de formação (em key)
            if key == "GRADUACAO" {
                key = "Graduação"
            } else if key == "POS_GRADUACAO" { 
                key = "Pós-Graduação"
            }

            tempo_content = [#subset.ANO-DE-INICIO - #subset.ANO-DE-CONCLUSAO]
            
            // criar título
            if "TITULO-DO-TRABALHO-DE-CONCLUSAO-DE-CURSO" in subset.keys() {
                titulo = subset.TITULO-DO-TRABALHO-DE-CONCLUSAO-DE-CURSO 
            } else if "TITULO-DA-DISSERTACAO-TESE" in subset.keys() {
                titulo = subset.TITULO-DA-DISSERTACAO-TESE
            }

            // criar orientadres
            if "NOME-DO-CO-ORIENTADOR" in subset.keys() {
                if subset.NOME-DO-CO-ORIENTADOR !="" {
                    orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                    coorientador = subset.NOME-DO-CO-ORIENTADOR
                } else {
                    orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
                }
            } else if "NOME-DO-ORIENTADOR" in subset.keys() {
                orientador = subset.NOME-DO-ORIENTADOR
            } else {
                orientador = subset.NOME-COMPLETO-DO-ORIENTADOR
            }

            // criar áreas de conhecimento
            if "AREAS-DO-CONHECIMENTO" in subset.keys() {
                let areas = subset.at("AREAS-DO-CONHECIMENTO")

                let all_areas = ()

                let i = 0
                
                for key in areas.keys() {
                    let subset2 = areas.at(key)

                    // first check lowest unit, then go up
                    if subset2.NOME-DA-ESPECIALIDADE != "" {
                        all_areas.push(subset2.NOME-DA-ESPECIALIDADE)
                    } else if subset2.NOME-DA-SUB-AREA-DO-CONHECIMENTO != "" {
                        all_areas.push(subset2.NOME-DA-SUB-AREA-DO-CONHECIMENTO)
                    } else if subset2.NOME-DA-AREA-DO-CONHECIMENTO != "" {
                        all_areas.push(subset2.NOME-DA-AREA-DO-CONHECIMENTO)
                    } else if subset2.NOME-GRANDE-AREA-DO-CONHECIMENTO != "" {
                        all_areas.push(subset2.NOME-GRANDE-AREA-DO-CONHECIMENTO)
                    }
                }

                if all_areas.len() == 0 {} else {
                    conhecimento = [Áreas de conhecimento: #all_areas.join(", ")]
                }
            }

            // criar content
            let estudo = [#key.slice(0, 1)#lower(key.slice(1)) em #subset.NOME-CURSO, #emph(subset.NOME-INSTITUICAO)]
            // caso tem todas informações
            if orientador != str and coorientador != str {
                descricao_content = [
                    #estudo#linebreak()
                    Título: #titulo#linebreak()
                    Orientador(a): #orientador#linebreak()
                    Co-orientador(a): #coorientador#linebreak()
                ]
            // caso não tem co-orientador e áreas de conhecimento
            }  else if orientador != str and coorientador == str {
                descricao_content = [
                    #estudo#linebreak()
                    Título: #titulo#linebreak()
                    Orientador(a): #orientador#linebreak()
                ]
            // caso não tem orientador, co-orientador e áreas de conhecimento
            } else if orientador == str and coorientador == str {
                descricao_content = [
                    #estudo#linebreak()
                    Título: #titulo#linebreak()
                ]
            }
            // criar conteúdo depende do tipo de lattes
            if tipo_lattes == "completo" {
                if conhecimento != content {
                    descricao_content = [#descricao_content#linebreak()#text(rgb("B2B2B2"), size: 0.85em, conhecimento)]
                }
            } 

            // publicar conteúdo
            create-cols([*#tempo_content*], [#descricao_content], "small")
        }

        linebreak()

        line(length: 100%)
    } 
}

// Criar área de formação complementar
// Argumentos
// - detalhes: o banco de dados de Lattes (TOML)
#let create-advanced-training(detalhes) = {
    if "DADOS-COMPLEMENTARES" in detalhes {
        if "FORMACAO-COMPLEMENTAR" in detalhes.DADOS-COMPLEMENTARES{
        
            // criar banco de dados
            let complementar = detalhes.DADOS-COMPLEMENTARES.FORMACAO-COMPLEMENTAR

            if complementar.len() > 0 {
                [= Formação complementar <formacao_complementar>]

                for key in complementar.keys() {
                    let subset = complementar.at(key)

                    subset = subset.sorted(key: (item) => (item.ANO-DE-INICIO, item.ANO-DE-CONCLUSAO))
                    
                    for entrada in subset.rev() {
                        let tempo_content = []
                        if entrada.ANO-DE-INICIO == entrada.ANO-DE-CONCLUSAO {
                            tempo_content = [#entrada.ANO-DE-INICIO]
                        } else {
                            tempo_content = [#entrada.ANO-DE-INICIO - #entrada.ANO-DE-CONCLUSAO]
                        }

                        let descricao_content= [
                            #entrada.NOME-CURSO (Carga horária: #entrada.CARGA-HORARIA), #emph(entrada.NOME-INSTITUICAO)
                        ]

                        create-cols([*#tempo_content*], [#descricao_content], "small")
                    }
                }
            }
        }
    }    
    linebreak()

    line(length: 100%)
}

// criar vínculos (subárea Atuação)
// Argumentos
//  - dados_vagas: o banco de dados filtrado para vagas
#let create-positions(dados_vagas) = {
    
    // depdende de informações na entrada é dictionary (1) ou array (>1)
    if type(dados_vagas) == array {
        
        // criar banco de dados em ordem
        let subset = dados_vagas.sorted(key: (item) => (item.ANO-INICIO, item.MES-INICIO, item.ANO-FIM, item.MES-FIM))

        // criar toda entrada
        for position in subset.rev() {
            
            // criar variáveis
            let tempo_content
            // criar tempo
            if position.MES-FIM == "" {
                if position.ANO-FIM == "" {
                    tempo_content = [#position.MES-INICIO/#position.ANO-INICIO - atual]
                }
            } else {
                tempo_content = [#position.MES-INICIO/#position.ANO-INICIO - #position.MES-FIM/#position.ANO-FIM]
            }

            let vinculo = str(position.TIPO-DE-VINCULO.slice(0,1) + lower(position.TIPO-DE-VINCULO.slice(1)))
            let enquadramento = position.OUTRO-ENQUADRAMENTO-FUNCIONAL-INFORMADO
            let horas = position.CARGA-HORARIA-SEMANAL
            let informations = position.OUTRAS-INFORMACOES

            // criar content depende das informações dados
            let descricao_content
            if enquadramento != "" and horas != "" and informations != "" {
                // caso tudo é dado
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros Informações: #informations]
                ]
            } else if enquadramento != "" and horas != "" and informations == "" {
                // caso sem informações
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas
                ]
            } else if enquadramento != "" and horas == "" and informations == "" {
                // caso sem informações e horas
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento
                ]
            } else if enquadramento != "" and horas == "" and informations != "" {
                // caso sem horas
                descricao_content = [
                    Vínculo: #vinculo, Enquadramento funcional: #enquadramento #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros Informações: #informations]
                ]
            }

            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    // caso somente uma entrada
    } else if type(dados_vagas) == dictionary {
        // criar variáveis
        let tempo_content = []
        
        // criar tempo
        if dados_vagas.MES-FIM == "" {
            if dados_vagas.ANO-FIM == "" {
                tempo_content = [#dados_vagas.MES-INICIO/#dados_vagas.ANO-INICIO - atual]
            }
        } else {
            tempo_content = [#dados_vagas.MES-INICIO/#dados_vagas.ANO-INICIO - #dados_vagas.MES-FIM/#dados_vagas.ANO-FIM]
        }

        // criar outras variáveis
        let vinculo = [#dados_vagas.TIPO-DE-VINCULO.slice(0,1) #lower(dados_vagas.TIPO-DE-VINCULO.slice(1))]
        let enquadramento = dados_vagas.OUTRO-ENQUADRAMENTO-FUNCIONAL-INFORMADO
        let horas = dados_vagas.CARGA-HORARIA-SEMANAL
        let informations = dados_vagas.OUTRAS-INFORMACOES

        // criar content
        let descricao_content = []
        if enquadramento != "" and horas != "" and informations != "" {
            // case all three are given
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros Informações: #informations]
            ]
        } else if enquadramento != "" and horas != "" and informations == "" {
            // caso sem informações
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento, Carga horária: #horas
            ]
        } else if enquadramento != "" and horas == "" and informations == "" {
            // caso sem informações e horas
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento
            ]
        } else if enquadramento != "" and horas == "" and informations != "" {
            // caso sem horas
            descricao_content = [
                Vínculo: #vinculo, Enquadramento funcional: #enquadramento #linebreak() #text(rgb("B2B2B2"), size: 0.85em)[Outros Informações: #informations]
            ]
        }

        create-cols([*#tempo_content*], [#descricao_content], "wide")
    }
}

// criar cursos de ensino (subárea Atuação)
// Argumentos:
//  - dados_ensino: o banco de dados filtrado para vagas
#let create-teaching(dados_ensino) = {
    [== Atividades (Ensino) <ensino_atuacao>]

    if type(dados_ensino) == dictionary {
        
    } else if type(dados_ensino) == array {
        for curso in dados_ensino {
            // criar variáveis
            let disciplinas_text = str
            let tempo_content = []

            // criar tempo_content
            if curso.FLAG-PERIODO == "ATUAL" {
                tempo_content = [#curso.MES-INICIO/#curso.ANO-INICIO - atual]
            } else {
                tempo_content = [#curso.MES-INICIO/#curso.ANO-INICIO - #curso.MES-FIM/#curso.ANO-FIM]
            }
            
            // criar nível
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

            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    }
}

// criar commissões (subárea Atuação)
// Argumentos:
//  - dados_comissoes: o banco de dados filtrado para vagas
#let create-commissions(dados_comissoes) = {
    // criar variáveis
    let tempo_content = []
    let descricao_content = []
    
    // caso: somente uma entrada
    if type(dados_comissoes) == dictionary {
        if "ATIVIDADES-DE-CONSELHO-COMISSAO-E-CONSULTORIA"in dados_comissoes.keys() {
            [== Atividades (Comissões) <comissoes_atuacao>]
            
            // criar variaveis
            let tempo_content = []
            if dados_comissoes.FLAG-PERIODO == "ATUAL" {
                tempo_content = [#dados_comissoes.MES-INICIO/#dados_comissoes.ANO-INICIO - atual]
            } else {
                tempo_content = [#dados_comissoes.MES-INICIO/#posdados_comissoescao.ANO-INICIO - #dados_comissoes.MES-FIM/#dados_comissoes.ANO-FIM]
            }
            
            descricao_content = [
                #dados_comissoes.ESPECIFICACAO, #emph(dados_comissoes.NOME-ORGAO)
            ]
            
            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    // caso: mais de uma entrada
    } else if type(dados_comissoes) == array {
        [== Atividades (Comissões) <comissoes_atuacao>]
        
        for posicao in dados_comissoes {
            if posicao.FLAG-PERIODO == "ATUAL" {
                tempo_content = [#posicao.MES-INICIO/#posicao.ANO-INICIO - atual]
            } else {
                tempo_content = [#posicao.MES-INICIO/#posicao.ANO-INICIO - #posicao.MES-FIM/#posicao.ANO-FIM]
            }
            
            descricao_content = [
                #posicao.ESPECIFICACAO, #emph(posicao.NOME-ORGAO)
            ]
            
            create-cols([*#tempo_content*], [#descricao_content], "wide")
        }
    }
}

// criar atuação profissional 
// Argumentos
// - detalhes: o banco de dados de Lattes (TOML File)
#let create-atuacao(detalhes) = {

    // criar banco de dados
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    let atuacao_filtered = atuacao.filter(
        entry => entry.SEQUENCIA-IMPORTANCIA != ""
    )

    if atuacao.len() > 0 {
        [= Atuação profissional <atuacao>]
        // loop para cada entrada
        for entrada in atuacao {

            // criar vínculos
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

            // criar comissoes
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
            
            // Criar ensino
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

// Criar lista de projetos de pesquisa e ensino
// Argumentos:
//  - detalhes: o banco de dados de Lattes (TOML File)
#let create-projects(detalhes) = {
    // criar bancos básicos
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    let projetos_ensino = array
    let projetos_pesquisa = array

    // criar banco de dados para pesquisa e para ensino
    for entry in atuacao {
        // filtrar outras atividades
        if "ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO" in entry.keys() {

            let projetos = entry.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO.at("PARTICIPACAO-EM-PROJETO")
            
            // ordem os projetos
            let projetos = projetos.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-FIM, item.MES-INICIO))

            // criar array para pesquisa
            projetos_pesquisa = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "PESQUISA"
            )

            // criar array para ensino
            projetos_ensino = projetos.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "ENSINO"
            )
        }
    }

    if projetos_pesquisa.len() > 0 or projetos_ensino > 0 {
        [= Projetos <projetos_atuacao>]

        // criar área de pesquisa
        if projetos_pesquisa.len() > 0 {
            [== Projetos de pesquisa]

            for project in projetos_pesquisa.rev() {
                // criar variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criar membros de projeto
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

                // criar content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + subset.DESCRICAO-DO-PROJETO)
                ]

                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            linebreak()
        }

        if projetos_ensino.len() > 0 {
            [== Projetos de ensino]

            for project in projetos_ensino.rev() {
                // criar variáveis
                let membros = ()
                let tempo_content = ()
                
                let subset = project.at("PROJETO-DE-PESQUISA")
                
                if subset.SITUACAO == "CONCLUIDO" {
                    tempo_content = [#subset.ANO-INICIO - #subset.ANO-FIM]
                } else {
                    tempo_content = [#subset.ANO-INICIO - atual]
                }
                
                // criar membros de projeto
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

                // criar content
                let descricao_content = [
                    #subset.NOME-DO-PROJETO
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Integrantes: " + membros.join("; "))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Número de produções C,T & A: " + str(producoes))
                    #linebreak()
                    #text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + subset.DESCRICAO-DO-PROJETO)
                ]

                create-cols([*#tempo_content*], [#descricao_content], "small")
            }
            
            linebreak()
        }

        line(length: 100%)
    }
}

// Criando áreas de conhecimento
// Criar a lista de áreas de conhecimento
// Argumentos
//  - detalhes: o banco de dados de Lattes (TOML File)
#let create-revisor(detalhes) = {

    // criar banco de dados
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL
    // TODO: 3 cases so far
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
            }
        }
    }

    // Caso revisor de periódicos
    if periodico.len() > 0 {
        // criar cabeçalho
        [= Revisor de periódico <periodicos>]

        // criar variáveis
        let tempo_content = []

        // loop para cada entrada
        for entrada in periodico {
            // loop para mais informações do vínculo
            for vinculo in entrada {
                
                // criar tempo
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
                informacao = text(rgb("B2B2B2"), size: 0.85em, "Outras informações: " + entrada.VINCULOS.OUTRAS-INFORMACOES)
            }

            // criar conteúdo
            let descricao_content = [#entrada.NOME-INSTITUICAO #linebreak() #informacao]
            
            // publicar conteúdo
            create-cols([*#tempo_content*], descricao_content, "small")

        }

        // create distância e linha
        linebreak()

        line(length: 100%)
    } 

    // caso membro de comitê de assessora
    if assessora.len() > 0 {
        // criar cabeçalho
        [= Membro de comitê de assessora <assessora>]

        // criar variáveis
        let tempo_content = []

        // loop para cada entrada
        for entrada in assessora {
            // loop para mais informações do vínculo
            for vinculo in entrada {
                
                // criar tempo
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
                informacao = text(rgb("B2B2B2"), size: 0.85em, "Outras informações: " + entrada.VINCULOS.OUTRAS-INFORMACOES)
            }

            // criar conteúdo
            let descricao_content = [#entrada.NOME-INSTITUICAO #linebreak() #informacao]
            
            // publicar conteúdo
            create-cols([*#tempo_content*], descricao_content, "small")

        }

        // create distância e linha
        linebreak()

        line(length: 100%)
    } 

    // caso revisor de projeto de agência de fomento
    if fomento.len() > 0 {
        // criar cabeçalho
        [= Revisor de projeto de agência de fomento <fomento>]

        // criar variáveis
        let tempo_content = []

        // loop para cada entrada
        for entrada in fomento {
            // loop para mais informações do vínculo
            for vinculo in entrada {
                
                // criar tempo
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
                informacao = text(rgb("B2B2B2"), size: 0.85em, "Outras informações: " + entrada.VINCULOS.OUTRAS-INFORMACOES)
            }

            // criar conteúdo
            let descricao_content = [#entrada.NOME-INSTITUICAO #linebreak() #informacao]
            
            // publicar conteúdo
            create-cols([*#tempo_content*], descricao_content, "small")

        }

        // create distância e linha
        linebreak()

        line(length: 100%)
    } 
}

// Criando áreas de conhecimento
// Criar a lista de áreas de conhecimento
// Argumentos
//  - detalhes: o banco de dados de Lattes (TOML File)
#let create-areas-atuacao(detalhes) = {
    let areas_atuacao = detalhes.DADOS-GERAIS.AREAS-DE-ATUACAO.AREA-DE-ATUACAO

    // somente criar essa área se tiver ao mínimo uma entrada
    if areas_atuacao.len() > 0 {

        // criar cabeçalho
        [= Área de atuação <areas_atuacao>]

        // criar número para ordem
        let i = 1

        // loop pelo entrada, pode ter ordem de 4 áreas em uma entrada
        for entrada in areas_atuacao {
            // criar variáveis
            let descricao_content = []
            
            // Manipular GRANDE ÁREA (para Ciências Humanas tinha um _ e todas as letras maiúsculas)
            let grande_area = entrada.NOME-GRANDE-AREA-DO-CONHECIMENTO


            // manipular string de grande area
            let capitalize = (text) => [#text.slice(0, 1)#lower(text.slice(1))]
            let grande_area_parts = grande_area.split("_")
            grande_area = grande_area_parts.map(capitalize).join(" ")
            
            // criar descricao
            if entrada.NOME-DA-ESPECIALIDADE == "" {
                if entrada.NOME-DA-SUB-AREA-DO-CONHECIMENTO == "" {
                    if entrada.NOME-DA-AREA-DO-CONHECIMENTO == "" {
                        // caso somente grande area
                        descricao_content = [#i. Grande área: #grande_area]
                    } else {
                        descricao_content = [
                            Grande área: #grande_area / Área: #entrada.NOME-DA-AREA-DO-CONHECIMENTO
                        ]
                    }
                } else {
                    // caso grande area, area, e subarea
                    descricao_content = [
                        Grande área: #grande_area / Área: #entrada.NOME-DA-AREA-DO-CONHECIMENTO / Subárea: #entrada.NOME-DA-SUB-AREA-DO-CONHECIMENTO
                    ]
                }
            } else {
                // caso grande area, area, subarea, e especialidade
                descricao_content = [
                    Grande área: #grande_area / Área: #entrada.NOME-DA-AREA-DO-CONHECIMENTO / Subárea: #entrada.NOME-DA-SUB-AREA-DO-CONHECIMENTO / Especialidade: #entrada.NOME-DA-ESPECIALIDADE
                ]
            }

            // publicar content
            create-cols([*#i. *], [#descricao_content], "enum")
            
            // aumentar número para ordem
            i += 1
        } 
    }
    linebreak() 

    line(length: 100%)
}

// Criando a área de técnicos
// TODO: Até agora somente categoria "demais produções técnicos"
// Argumentos
//  - dados_tecnicos: subset do banco de dados com só técnios
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo Lattes
#let create-technicals(dados_tecnicos, eu, tipo_lattes) = {
    // TODO: com outras categorias mais separação entre áreas de produções técnios
    [== Produção técnica <producao_tecnica>]
    
    [=== Demais produções técnicas <producao_tecnica_demais>]

    // #all
    let i = dados_tecnicos.len() + 1

    // Then i loop into arrays
    for entrada in dados_tecnicos {
        // criar variáveis
        let autores = ()
        let palavras_chave = ()
        let conhecimento = ()
        let titulo = ""
        let ano = ""
        let tipo = ""
        let doi = ""
        let homepage = ""

        // using for constructing the link
        let url_link = []

        // formatar os autores
        let autores = format_authors(entrada.AUTORES, eu)     
        
        // criar entradas
        // TODO:  até agora somente esses dois casos
        // relatório
        if "DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA" in entrada.keys() {
            titulo = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.TITULO
            ano = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.ANO
            tipo = "Relatório de pesquisa"
            doi = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.DOI
            homepage = entrada.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.HOME-PAGE-DO-TRABALHO
        // materiais didáticos
        } else if "DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL" in entrada.keys() {
            titulo = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.TITULO
            ano = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.ANO
            tipo = "Desenvolvimento de material didático ou instrucional"
            doi = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.DOI
            homepage = entrada.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.HOME-PAGE-DO-TRABALHO
        }

        // criar lista de palavras-chave
        if "PALAVRAS-CHAVE" in entrada.keys() {
            for word in entrada.PALAVRAS-CHAVE.keys() {
                if entrada.PALAVRAS-CHAVE.at(word) != "" {
                    palavras_chave.push(entrada.PALAVRAS-CHAVE.at(word))    
                }
            }
        }

        // criar string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ")
        }

        // areas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in entrada.keys() {
            for evento in entrada.AREAS-DO-CONHECIMENTO.keys() {
                let subset2 = entrada.AREAS-DO-CONHECIMENTO.at(evento)
                
                for valor in subset2.keys() {
                    let area = subset2.at(valor)

                    // Define a function to capitalize the first letter of a substring
                    let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                    if area != "" {
                        let area_parts = area.split("_")

                        area = area_parts.map(capitalize).join(" ")

                        conhecimento.push(area)
                    }
                }                
            }
        }

        // criar string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join("; ")
        }
        
        // criar content para palavras-chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
            palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
        } else {
            palavras_content = []
        }
            
        // criar content para áreas de conhecimento 
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento) #linebreak()]
        } else {
            areas_content = []
        }

        // criar link, se tem DOI, somente usar doi e não homepage
        if doi != "" { 
            url_link = [#link("https://doi.org/" + doi)[#doi]]
        } else if homepage != "" {
            url_link = [#link(homepage)[#homepage]]
        }

        // criar o conteúdo
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#autores #titulo. #ano (#tipo). #url_link#linebreak()#palavras_content #areas_content]
        } else {
            descricao_content = [#autores #titulo. #ano (#tipo). #url_link]
        }
        
        // diminuir número (ordem)
        i -= 1

        // publicar o conteúdo
        create-cols([*#i*], [#descricao_content], "enum")
    }
}

// Criando publicacoes bibliograficos: apresentacoes
// criar lista de apresentações de trabalho e palestra
// argumentos
//  - dados_apresentacoes: subset do banco de dados com só apresentações
//  - me: nome para destacar nas entradas
#let create-presentations(dados_apresentacoes, eu) = {

    [=== Apresentação de trabalho e palestra <producao_apresentacoes>]

    // criar número para ordem
    let i = dados_apresentacoes.len() + 1
    // loop nas entradas de apresentacoes
    for entrada in dados_apresentacoes.rev() {
        let palavras_chave = ()
        let conhecimento = ()
        let resumo = ""

        let autores = format_authors(entrada.AUTORES, eu)     
        let titulo = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.TITULO
        let ano = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.ANO
        let tipo = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA

        // corrigir camppo de tipo
        if tipo == "CONFERENCIA" { 
            tipo = "Apresentação de Trabalho / Conferência ou Palestra"
        } else if tipo == "SEMINARIO" {
            tipo = "Apresentação de Trabalho / Seminário"
        } else {
        tipo = "Apresentação de Trabalho / " + tipo.slice(0, 1) + lower(tipo.slice(1))
        }
        
        // palavras-chave
        if "PALAVRAS-CHAVE" in entrada.keys() {
            for word in entrada.PALAVRAS-CHAVE.keys() {
                if entrada.PALAVRAS-CHAVE.at(word) != "" {
                    palavras_chave.push(entrada.PALAVRAS-CHAVE.at(word))    
                }
            }
        }

        // criar string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ")
        }

        // criar areas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in entrada.keys() {
            for evento in entrada.AREAS-DO-CONHECIMENTO.keys() {
                let subset2 = entrada.AREAS-DO-CONHECIMENTO.at(evento)
                
                for valor in subset2.keys() {
                    let area = subset2.at(valor)

                    // Define a function to capitalize the first letter of a substring
                    let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                    if area != "" {
                        let area_parts = area.split("_")

                        area = area_parts.map(capitalize).join(" ")

                        conhecimento.push(area)
                    }
                }                
            }
        }

        // criar string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join("; ")
        }
        
        // resumo
        if "INFORMACOES-ADICIONAIS" in entrada.keys() {
            resumo = [#text(rgb("B2B2B2"), size: 0.85em, "Resumo: "+ entrada.INFORMACOES-ADICIONAIS.DESCRICAO-INFORMACOES-ADICIONAIS)]
        } else {
            resumo = ""
        }
        
        // criar content para palavras_chave
        let palavras_content = []
            if palavras_chave.len() > 0 {
                palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
            } else {
                palavras_content = []
            }
            
        // criar content para areas 
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento) #linebreak()]
        } else {
            areas_content = []
        }

        // criar o conteúdo
        let descricao_content= [#autores #titulo. #ano (#tipo)#linebreak()#palavras_content #areas_content #resumo]
        
        // diminuir o númoer
        i -= 1

        // publicar o conteúdo
        create-cols([*#i*], [#descricao_content], "enum")
    }
}

// Criando publicacoes bibliograficos: capitulos
// criar lista de capitulos
// argumentos
//  - dados_capitulos: subset do banco de dados com só capitulos
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo lattes
#let create-chapters(dados_capitulos, eu, tipo_lattes) = {

    [=== Capitulos de livros publicados <publicacao_capitulos>]

    // criar número para ordem
    let i = dados_capitulos.len()

    for entrada in dados_capitulos.rev() {

        // initialize variables
        let palavras_chave = ()
        let conhecimento = ()
        let editores = ()
        let subset = entrada

        // authors:
        let autores = format_authors(subset.AUTORES, eu)        

        let titulo = subset.DADOS-BASICOS-DO-CAPITULO.TITULO-DO-CAPITULO-DO-LIVRO
        let titulo_livro = subset.DETALHAMENTO-DO-CAPITULO.TITULO-DO-LIVRO
        let edicao = subset.DETALHAMENTO-DO-CAPITULO.NUMERO-DA-EDICAO-REVISAO
        let local = subset.DETALHAMENTO-DO-CAPITULO.CIDADE-DA-EDITORA
        let editora = subset.DETALHAMENTO-DO-CAPITULO.NOME-DA-EDITORA
        let ano = subset.DADOS-BASICOS-DO-CAPITULO.ANO
        let doi = subset.DADOS-BASICOS-DO-CAPITULO.DOI
    
        let pagina = []
        if subset.DETALHAMENTO-DO-CAPITULO.PAGINA-FINAL == "" {
            pagina = subset.DETALHAMENTO-DO-CAPITULO.PAGINA-INICIAL
        } else {
            pagina = [#subset.DETALHAMENTO-DO-CAPITULO.PAGINA-INICIAL - #subset.DETALHAMENTO-DO-CAPITULO.PAGINA-FINAL]
        }

        // criar lista de palavras-chave
        if "PALAVRAS-CHAVE" in subset.keys() {
            for palavra in subset.PALAVRAS-CHAVE.keys() {
                if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                    palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                }
            }
        }

        // criar string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ")
        }

        // criar lista de areas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in subset.keys() {
            for entrada in subset.AREAS-DO-CONHECIMENTO.keys() {
                let subset2 = subset.AREAS-DO-CONHECIMENTO.at(entrada)
                
                for valor in subset2.keys() {
                    let area = subset2.at(valor)

                    // Define a function to capitalize the first letter of a substring
                    let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                    if area != "" {
                        let area_parts = area.split("_")

                        area = area_parts.map(capitalize).join(" ")

                        conhecimento.push(area)
                    }
                }                
            }
        }

        // criar string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join("; ")
        }

        //  criar editores
        let editores_string = subset.DETALHAMENTO-DO-CAPITULO.ORGANIZADORES
        if editores_string.find(";") != none {
            // caso mais de um editor (separação nos dados com ;)
            let partes = editores_string.split("; ")
            for parte in partes {
                let nome_split = parte.split(", ")
                let nome = upper(nome_split.at(0)) + ", " + nome_split.at(1).first() + "."
                editores.push(nome)
            }
        } else if editores_string != "" {
            // caso um editor
            let nome_split = editores_string.split(", ")
            let nome = upper(nome_split.at(0)) + ", " + nome_split.at(1).first()  + "."
            editores.push(nome)
        }
        editores = editores.join("; ")

        // criar o link, prefire DOI 
        let doi_link = []
        if doi.len() > 0 {
            doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
        }

        // criar edicao 
        if edicao != "" {
            edicao = [ed. #edicao: ]
        }
        
        // criar local & editora
        let local_editora_content = []
        if local != "" and editora != "" {
            local_editora_content = [#local: #editora,] 
        } else if local != "" and editora == "" {
            local_editora_content = [#local,]
        } else if local == "" and editora != "" {
            local_editora_content = [#editora,]
        } 

        // criar citação
        let citacao = [#autores #titulo. In: #editores (ed.). #emph(titulo_livro). #local_editora_content, #ano. p. #pagina. #doi_link #linebreak()]

        // criar content palavras-chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
            palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
        } else {
            palavras_content = []
        }

        // criar content para áreas de conhecimento
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento) #linebreak()]
        } else {
            areas_content = []
        }

        // criar conteúdo 
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#citacao #palavras_content #areas_content]
        } else {
            descricao_content = [#citacao]
        }
        // publicar conteúdo
        create-cols([*#i*], [#descricao_content], "enum")

        // diminuir número para ordem
        i -= 1
    }    
}

// criar a área de livros
// argumentos:
//  - dados_livros: subset do banco de dados com só livros
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo lattes
#let create-books(dados_livros, eu, tipo_lattes) = {
    
    [=== Livros publicados <publicacao_livros>]
    
    // criar número para ordem
    let i = dados_livros.len()

    for entrada in dados_livros.rev() {
        // criar subset 
        let subset = entrada
        // criar variáveis
        let palavras_chave= ()
        let conhecimento = ()

        // autores: 
        let autores = format_authors(subset.AUTORES, eu)
        
        let titulo = subset.DADOS-BASICOS-DO-LIVRO.TITULO-DO-LIVRO
        let ano = subset.DADOS-BASICOS-DO-LIVRO.ANO
        let doi = subset.DADOS-BASICOS-DO-LIVRO.DOI
        let editora = subset.DETALHAMENTO-DO-LIVRO.NOME-DA-EDITORA
        let local = subset.DETALHAMENTO-DO-LIVRO.CIDADE-DA-EDITORA
        
        let pagina = []
        if subset.DETALHAMENTO-DO-LIVRO.NUMERO-DE-PAGINAS != "" {
            pagina = [#subset.DETALHAMENTO-DO-LIVRO.NUMERO-DE-PAGINAS]
        }

        // Palavras-chave
        if "PALAVRAS-CHAVE" in subset.keys() {
            for palavra in subset.PALAVRAS-CHAVE.keys() {
                if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                    palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                }
            }
        }

        // criar string de palavras-chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ")
        }

        // areas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in subset.keys() {
            for entrada in subset.AREAS-DO-CONHECIMENTO.keys() {
                let subset2 = subset.AREAS-DO-CONHECIMENTO.at(entrada)
                
                for valor in subset2.keys() {
                    let area = subset2.at(valor)

                    // Define a function to capitalize the first letter of a substring
                    let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                    if area != "" {
                        let area_parts = area.split("_")

                        area = area_parts.map(capitalize).join(" ")

                        conhecimento.push(area)
                    }
                }                
            }
        }

        // criar string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join("; ")
        }

        // criar citação
        // criar link (prefire DOI)
        let doi_link = []
        if doi.len() > 0 {
            doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
        }
        
        // criar local & editora
        let local_editora_content = []
        if local != "" and editora != "" {
            local_editora_content = [#local: #editora,] 
        } else if local != "" and editora == "" {
            local_editora_content = [#local,]
        } else if local == "" and editora != "" {
            local_editora_content = [#editora,]
        } 

        // criar citacao
        let citacao = [#autores #titulo. #local_editora_content #ano, p. #pagina. #doi_link #linebreak()]

        // criar content palavras-chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
            palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
        } 

        // criar content para área
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento)]
        } 

        // criar descricao
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#citacao #palavras_content #areas_content]
        } else {
            descricao_content = [#citacao]
        }        
        
        // publicar entrada
        create-cols([*#i*], [#descricao_content], "enum")
        
        // diminuir número
        i -= 1
    }
}

// criar a área de artigos
// argumentos:
//  - dados_artigos: subset do banco de dados com só livros
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo Lattes
#let create-articles(dados_artigos, eu, tipo_lattes) = {

    // criar cabeçalho
    [=== Artigos completos publicados em periódicos <publicacao_artigos>]
    
    // criar número para ordem
    let i = dados_artigos.len()

    // criar entrada para cada artigo
    for entrada in dados_artigos.rev() {
        // initialize variables
        let palavras_chave = ()
        let conhecimento = ()
        let subset = entrada

        // authors:
        let autores = format_authors(subset.AUTORES, eu)        
        
        let titulo = subset.DADOS-BASICOS-DO-ARTIGO.TITULO-DO-ARTIGO
        let ano = subset.DADOS-BASICOS-DO-ARTIGO.ANO-DO-ARTIGO
        let doi = subset.DADOS-BASICOS-DO-ARTIGO.DOI
        let periodico = subset.DETALHAMENTO-DO-ARTIGO.TITULO-DO-PERIODICO-OU-REVISTA
        let volume = subset.DETALHAMENTO-DO-ARTIGO.VOLUME
        
        let pagina = []
        if subset.DETALHAMENTO-DO-ARTIGO.PAGINA-FINAL == "" {
            pagina = subset.DETALHAMENTO-DO-ARTIGO.PAGINA-INICIAL
        } else {
            pagina = [#subset.DETALHAMENTO-DO-ARTIGO.PAGINA-INICIAL - #subset.DETALHAMENTO-DO-ARTIGO.PAGINA-FINAL]
        }

        // palavras_chave
        if "PALAVRAS-CHAVE" in subset.keys() {
            for palavra in subset.PALAVRAS-CHAVE.keys() {
                if subset.PALAVRAS-CHAVE.at(palavra) != "" {
                    palavras_chave.push(subset.PALAVRAS-CHAVE.at(palavra))    
                }
            }
        }

        // criar string de palavras_chave
        if palavras_chave.len() > 0 {
            palavras_chave = palavras_chave.join("; ")
        }

        // areas de conhecimento
        if "AREAS-DO-CONHECIMENTO" in subset.keys() {
            for entrada in subset.AREAS-DO-CONHECIMENTO.keys() {
                let subset2 = subset.AREAS-DO-CONHECIMENTO.at(entrada)
                
                for valor in subset2.keys() {
                    let area = subset2.at(valor)

                    let capitalize = (text) => str(text.slice(0, 1) + lower(text.slice(1)))

                    if area != "" {
                        let area_parts = area.split("_")

                        area = area_parts.map(capitalize).join(" ")

                        conhecimento.push(area)
                    }
                }                
            }
        }

        // criar string de áreas de conhecimento
        if conhecimento.len() > 0 {
            conhecimento = conhecimento.join("; ")
        }

        // criar conteúdo
        // criar link: DOI
        let doi_link = []
        if doi.len() > 0 {
            doi_link = [#link("https://doi.org/"+ doi)[DOI: #doi]]
        }

        // criar content citação
        let citacao = [#autores #titulo. #emph(periodico). v. #volume. p. #pagina, #ano. #doi_link #linebreak()]
        
        // criar content palavras chave
        let palavras_content = []
        if palavras_chave.len() > 0 {
            palavras_content = [#text(rgb("B2B2B2"), size: 0.85em, "Palavras-chave: "+ palavras_chave) #linebreak()]
        } 
        
        // criar content para áreas de conhecimento
        let areas_content = [] 
        if conhecimento.len() > 0 {
            areas_content = [#text(rgb("B2B2B2"), size: 0.85em, "Áreas de conhecimento: "+ conhecimento)]
        } 

        // criar content para descrição 
        let descricao_content = []
        if tipo_lattes == "completo" {
            descricao_content = [#citacao #palavras_content #areas_content]
        } else {
            descricao_content = [#citacao]
        }
        
        // publicar content
        create-cols([*#i*], [#descricao_content], "enum")
        
        // diminuir número para ordem
        i -= 1
    }   
}

// Criando as publicações: Artigos publicados, livros publicados, capítulos publicados e demais técnicos
// Criar a area de Produção Bibliografica
// argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - me: nome para destacar nas entradas
//  - tipo_lattes: tipo de currículo Lattes
#let create-bibliography(detalhes, eu, tipo_lattes) = {
    // criar banco de dados

    //  artigos
    let artigos = detalhes.PRODUCAO-BIBLIOGRAFICA.ARTIGOS-PUBLICADOS.ARTIGO-PUBLICADO

    artigos = artigos.sorted(key: (item) => (item.DADOS-BASICOS-DO-ARTIGO.ANO-DO-ARTIGO, item.DADOS-BASICOS-DO-ARTIGO.TITULO-DO-ARTIGO))

    // livros
    let livros = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.LIVROS-PUBLICADOS-OU-ORGANIZADOS

    let livros = livros.LIVRO-PUBLICADO-OU-ORGANIZADO.sorted(key: (item) => (item.DADOS-BASICOS-DO-LIVRO.ANO, item.DADOS-BASICOS-DO-LIVRO.TITULO-DO-LIVRO))
    
    // capítulos
    let capitulos = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.CAPITULOS-DE-LIVROS-PUBLICADOS

    capitulos = capitulos.CAPITULO-DE-LIVRO-PUBLICADO.sorted(key: (item) => (item.DADOS-BASICOS-DO-CAPITULO.ANO, item.DADOS-BASICOS-DO-CAPITULO.TITULO-DO-CAPITULO-DO-LIVRO))

    // para apresentações de trabalho e palestra
    let apresentacoes = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.APRESENTACAO-DE-TRABALHO

    apresentacoes = apresentacoes.sorted(
        key: (item) => (item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.ANO, item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.TITULO)
    )

    // para demais técnicas
    let didatico = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL
    
    didatico = didatico.sorted(key: (item) => (item.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.ANO, item.DADOS-BASICOS-DO-MATERIAL-DIDATICO-OU-INSTRUCIONAL.TITULO))

    let relatorio = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.RELATORIO-DE-PESQUISA
    relatorio = relatorio.sorted(key: (item) => (item.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.ANO, item.DADOS-BASICOS-DO-RELATORIO-DE-PESQUISA.TITULO))
    
    let cursos_curtos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.CURSO-DE-CURTA-DURACAO-MINISTRADO

    let todos = relatorio.rev() + didatico.rev()

    // criar cabeçalho
    if artigos.len() > 0 or livros.len() > 0 or capitulos.len() > 0 or todos.len() > 0 {
        [= Produção <producao>]

        [== Produção bibliográfica <producao_bibliografica>]

    }

    // criar área de artigos
    if artigos.len() > 0 {
        create-articles(artigos, eu, tipo_lattes)
    }

    // criar área de livros
    if livros.len() > 0 {
        create-books(livros, eu, tipo_lattes)
    }

    // criar área de capítulos
    if capitulos.len() > 0 {
        create-chapters(capitulos, eu, tipo_lattes)
    }

    // criar área de apresentações
    if tipo_lattes == "completo" {
        if apresentacoes.len() > 0 {
            create-presentations(apresentacoes, eu)
        }
    }
    

    // criar área de técnicos
    if todos.len() > 0 {
        create-technicals(todos, eu, tipo_lattes)
    }

    linebreak()

    line(length: 100%)
}

// Criando projetos (dentro de inovação)
// Criar os projetos de ensino, e projetos de pesquisa
// Argumentos
//  - data-research: o banco de dados com projetos de pesquisa
//  - data-ensino: o banco de dados com projetos de ensino
#let create-projects-ct(data-research, data-teaching) = {           
    // para pesquisa
    // somente se tiver uma entrada ao mínimo
    if data-research.len() > 0 {
        [=== Projeto de pesquisa]

        let i = data-research.len() + 1

        for projeto in data-research {
            // criar um banco de dados para projeto
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


            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#project.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#project.ANO-INICIO - #project.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
                
            // criar membros
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criar array para pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                // loop para cada entrada em integrantes
                for pessoa in pessoas {
                    // se tem somente uma pessoa
                    if type(pessoa) == dictionary {
                        // se é responsável ou não
                        if pessoa.FLAG-RESPONSAVEL == "SIM" {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(", ")
                            let nome = upper(nome_partes.at(0)) + ", " + upper(nome_partes.at(1).first()) + ". (responsável)"
                            membros.push(nome)  
                        } else {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(", ")
                            let nome = upper(nome_partes.at(0)) + ", " + upper(nome_partes.at(1).first()) + "."
                            membros.push(nome)   
                        }
                    // tem mais de uma pessoa
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-PARA-CITACAO" {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(", ")
                            let nome = upper(nome_partes.at(0)) + ", " + upper(nome_partes.at(1).first()) + ". (responsável)"
                            membros.push(nome)  
                        }
                    }
                }
            }

            // criar financiadores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criar array de financiadores
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

            // criar conteúdo
            // criar strings para cada informação
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

            let mais_informacoes = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: " + information)#linebreak()]
            
            let descricao_content = [#titulo #linebreak() #mais_informacoes #membros_string #subvencoes_string #cta_string]

            // criar conteúdo final
            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }

    // para ensino
    if data-teaching.len() > 0 {

        [=== Projeto de ensino]

        let i = data-teaching.len() + 1

        for projeto in data-teaching.rev() {
            // criar banco de dados para projeto
            let subset = projeto.at("PROJETO-DE-PESQUISA")
            
            // criar variáveis
            let ano = ""
            let situacao = ""
            let tipo = ""
            let membros = ()
            let subvencoes = ()
            let cta = 0

            let informacao = subset.DESCRICAO-DO-PROJETO
            let titulo = subset.NOME-DO-PROJETO

            if subset.SITUACAO != "CONCLUIDO" {
                ano = [#projeto.ANO-INICIO - atual]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            } else {
                ano = [#projeto.ANO-INICIO - #projeto.ANO-FIM]
                situacao = subset.SITUACAO.slice(0,1) + lower(subset.SITUACAO.slice(1))
            }
            
            // criar membros do projeto
            if "EQUIPE-DO-PROJETO" in subset.keys() {
                // criar array de pessoas
                let pessoas = subset.EQUIPE-DO-PROJETO.at("INTEGRANTES-DO-PROJETO")

                // loop por entradas de pessoas
                for pessoa in pessoas {
                    if type(pessoa) == dictionary {
                        if pessoa.FLAG-RESPONSAVEL == "SIM" {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(", ")
                            let nome = upper(nome_partes.at(0)) + ", " + upper(nome_partes.at(1).first()) + ". (responsável)"
                            membros.push(nome) 
                        } else {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(", ")
                            let nome = upper(nome_partes.at(0)) + ", " + upper(nome_partes.at(1).first()) + "."
                            membros.push(nome) 
                        }
                    } else if type(pessoa) == array {
                        if pessoa.at(0) == "NOME-PARA-CITACAO" {
                            let nome_partes = pessoa.NOME-PARA-CITACAO.split(", ")
                            let nome = upper(nome_partes.at(0)) + ", " + upper(nome_partes.at(1).first()) + ". (responsável)"
                            membros.push(nome) 
                        }
                    }
                }
            }

            // criar financidores
            if "FINANCIADORES-DO-PROJETO" in subset.keys() {
                // criar array de financiadores
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

            // create content                
            let descricao = [#text(rgb("B2B2B2"), size: 0.85em, "Descrição: "+ informacao)#linebreak()]

            // criar string para membros
            let membros_string = []
            if membros.len() > 0 {
                membros_string = [#text(rgb("B2B2B2"), size: 0.85em, "Integrante(s): "+ membros.join("; "))#linebreak()]
            } else {
                membros_string = []
            }
                
            // criar string para subvencoes
            let subvencoes_string = []
            if subvencoes.len() > 0 {
                subvencoes_string = [#text(rgb("B2B2B2"), size: 0.85em, "Financiador(es): " + subvencoes.join("; "))#linebreak()]
            } else {
                subvencoes_string = []
            }
            
            // criar string para cta
            let cta_string = []
            if cta > 0 {
                cta_string = [#text(rgb("B2B2B2"), size: 0.85em, "Número de produções C, T & A: "+ str(cta))]
            } else {
                cta_string = []
            }

            // criar conteúdo
            let descricao_content = [#titulo #linebreak() #descricao #membros_string #subvencoes_string #cta_string]

            create-cols([*#ano*], [#descricao_content], "wide")
        }
    }
}
    // }
// }


// Criandao Educação e Popularização
// Essa função cria a parte de educação e popularização (parte da inovação)
// TODO: até agora somente apresentação de trabalho e palestra
// Argumentos
//  - dados_educacao_ct: subset para invoção - educação e popularização
#let create-education-ct(dados_educacao_ct) = {
    if dados_educacao_ct.len() > 0 {
        // criar cabeçalho 
        // TODO: até agora somente essa categoria, com mais categorias precisa mudar pra cima
        [== Educação e Popularização de C&T <ct>]

        [=== Apresentação de trabalho e palestra <ct_apresentacoes>]
            
        // criar números para oddem
        let i = dados_educacao_ct.len()

        for entrada in dados_educacao_ct.rev() {

            // criar sub-banco de dados para cada entrada
            let subset = entrada.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO
            
            // criar variáveis
            let evento = entrada.DETALHAMENTO-DA-APRESENTACAO-DE-TRABALHO.NOME-DO-EVENTO
            let ano = subset.ANO
            let titulo = subset.TITULO
            let natureza = str(subset.NATUREZA.slice(0, 1) + lower(subset.NATUREZA.slice(1)))

            // corrigir natureza
            if natureza == "Conferencia" {
                natureza = "Conferência ou Palestra"
            } else if natureza == "Seminario" {
                natureza = "Seminário"
            }
                                
            // criar conteúdo 
            let descricao_content = [#strong(evento), #ano (#natureza). #titulo]

            // criar conteúdo final
            create-cols([*#i.*], [#descricao_content], "enum")

            // diminuir número (para ordem)
            i -= 1
        }
        // }
    }
}

// Criandao Inovações 
// Criar o cabeçalho de Inovação e as partes de projetos e educação de CT
// Argumentos
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-innovations(detalhes) = {
    // criar banco de dados geral
    let atuacao = detalhes.DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL

    // criar variáveis
    let projetos = ()
    let proj_ensino = ()
    let proj_pesquisa = ()
    let eventos = () 
    let congressos = () 
    let marker = true

    // criar a soma de
    // criar um loop para cada atuação para recolher todos os projetos
    for entrada in atuacao {
        // set to empty
        projetos = ()
        proj_ensino = ()
        proj_pesquisa = ()
        
        // criar o banco de dados
        if "ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO" in entrada.keys() {
            projetos = entrada.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO.at("PARTICIPACAO-EM-PROJETO")
        }
        
        if projetos.len() > 0 { 
            // ordenar por ano
            let projetos_sorted = projetos.sorted(key: (item) => (item.ANO-INICIO, item.ANO-FIM, item.MES-FIM, item.MES-INICIO))

            // filtrar ensino
            proj_ensino = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "ENSINO" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )

            // filtrar pesquisa
            proj_pesquisa = projetos_sorted.filter(
                entry => entry.at("PROJETO-DE-PESQUISA").NATUREZA == "PESQUISA" and entry.at("PROJETO-DE-PESQUISA").FLAG-POTENCIAL-INOVACAO == "SIM"
            )
        }

        // criar cabeçalho
        if proj_pesquisa.len() > 0 or proj_ensino.len() > 0 {
            [= Inovação <inovacao>]
            marker = false
        }

        // Projetos primeiro
        // TODO; does not work
        if proj_pesquisa.len() > 0 or proj_ensino.len() > 0 {
            create-projects-ct(proj_pesquisa, proj_ensino)    
        }   
    }

    // Dados de congressos não são vinculados com a atuação
    // criar banco de dados
    // educacao e popularizacao de C&T
    eventos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA

    // criar banco de dados de apresentações
    congressos = eventos.APRESENTACAO-DE-TRABALHO

    // ordenar por ano 
    congressos = congressos.sorted(key: (item) => (item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.ANO, item.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.TITULO))

    // filtrar para eles com inovação
    congressos = congressos.filter(
        entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.FLAG-DIVULGACAO-CIENTIFICA == "SIM"
    )
    
    // somente criar se tiver uma entrada ao mínimo
    if congressos.len() > 0 {
        if congressos.len() > 0 and marker == true {
            [#marker]
            [= Inovação <inovacao>]
        }

        create-education-ct(congressos)
    }
    linebreak()

    line(length: 100%)
}

// Criando entradas para orientações
// Esta função cria a visão geral das supervisões.
// Argumentos
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-supervisions(detalhes) = {
    // criar bancos de dados
    let orientacao = detalhes.OUTRA-PRODUCAO

    // criar variáveis
    let descricao_content = []

    // criar seção só se tiver entradas em orientações
    // TODO: Não tenho certeza sobre o key "ORIENTACOES-EM-ANDAMENTO
    if "ORIENTACOES-CONCLUIDAS" in orientacao or "ORIENTACOES-EM-ANDAMENTO" in orientacao {
        // criar cabeçalho
        [= Orientações e Supervisões <orientacao>]
       
        // Orientations em andamento
        // TODO: Não tenho certeza sobre o key, provavelmente dê erro
        if "ORIENTACOES-EM-ANDAMENTO" in orientacao.keys() {
            // criar banco de dados
            let andamento = orientacao.ORIENTACOES-EM-ANDAMENTO

            // criar cabeçalho
            [== Orientações e supervisões em andamento <orientacao_andamento>]

            // para doutorado
            // TODO: não tenho certeza sobre o key, provavelmente dê erro
            if "OUTRAS-ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO" in andamento.keys() {

                // criar bancos de dados
                let doutorado = andamento.ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO
                
                // ordenar por ano (descendo)
                let doutorado_ordem = doutorado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO))

                // Criar Orientador
                // filtrar para funcção (aqui: orientador)
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )

                // criar conteúdo somente se tiver uma entrada
                if doutorado_filtro.len() > 0 {
                    // criar cabeçålho
                    [=== Tese de doutorado: orientador <orientacao_andamento_doutorado_orientador>]
                    
                    // criar número para ordenar
                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        // criar varíaveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criar entrada final
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }

                // Criar Co-orientador
                // filtrar para funcção (aqui: orientador)
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )

                // criar conteúdo somente se tiver uma entrada
                if doutorado_filtro.len() > 0 {
                    // criar cabeçålho
                    [=== Tese de doutorado: co-orientador <orientacao_andamento_doutorado_coorientador>]
                    
                    // criar número para ordenar
                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        // criar varíaveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criar entrada final
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }
            }
            
            // para mestrado
            if "ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO" in andamento.keys() {
                // criar banco de dados
                let mestrado = andamento.ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO
                
                // ordenar as entradas
                let mestrado_ordem = mestrado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO))

                // Criar Orientador
                // filtrar para "orientador"
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )
                
                // criar conteúdo somente se tiver uma entrada
                if mestrado_filtro.len() > 0 {
                    // criar cabeçalho
                    [=== Dissertações de mestrado: orientador <orientacao_andamento_mestrado_orientador>] 

                    // criar número para enumerar
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criar variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criar conteúdo final
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }

                // Criar Co-orientador
                // filtrar para "co-orientador"
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )
                
                // criar conteúdo somente se tiver uma entrada
                if mestrado_filtro.len() > 0 {
                    // criar cabeçalho
                    [=== Dissertações de mestrado: co-orientador <orientacao_andamento_mestrado_coorientador>] 

                    // criar número para enumerar
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criar variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criar conteúdo final
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }
            } 
            
            // para TCC (graduação, sem separação entre orientador ou co-orientador)
            // TODO: Não tenho certeza sobre o key
            if "OUTRAS-ORIENTACOES-EM-ANDAMENTO" in andamento.keys() {
                // criar banco de dados
                let outras = andamento.OUTRAS-ORIENTACOES-EM-ANDAMENTO

                // ordenar dados (descendo)
                let outras_ordem = outras.sorted(key: (item) => (item.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.ANO))

                // criar conteúdo se tiver ao mínimo uma entrada
                if outras_ordem.len() > 0 {
                    // criar cabeçalho
                    [=== Trabalhos de conclusão de curso de graduação <orientacao_andamento_graduacao>]

                    // criar número de entradas (para ordem)
                    let i = outras_ordem.len()
                    // criar conteúdo para cada entrada
                    for entrada in outras_ordem.rev() {
                        // criar variáveis
                        let orientando = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.ANO
                        let programa = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NOME-DA-INSTITUICAO

                        // A NATUREZA está em maiúsculas e com sublinhado
                        // Manipular NATUREZA
                        let tipo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-EM-ANDAMENTO.NATUREZA
                        
                        // Defina uma função para capitalizar a primeira letra de um substring
                        let capitalize = (text) => [#text.slice(0, 1)#lower(text.slice(1))]

                        // Divida a string em partes com base nos espaços
                        let tipo_parts = tipo.split("_")

                        // Capitalize cada parte e junte-as novamente com espaços
                        tipo = tipo_parts.map(capitalize).join(" ")
                        
                        // criar conteúdo junto
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // Criar conteúdo final
                        create-cols([*#i.*], [#descricao_content], "enum")

                        i -= 1
                    }
                }
            }            
        }

        // Orientations concluidas
        if "ORIENTACOES-CONCLUIDAS" in orientacao.keys() {
            // Criar cabeçalho
            [== Orientações e supervisões concluídas <orientacao_concluida>]
            
            // criar banco de dados
            let concluidos = orientacao.ORIENTACOES-CONCLUIDAS
            
            // TODO: não tenho certeza sobre o key
            // para doutorado
            if "OUTRAS-ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO" in concluidos.keys() {
                // criar banco de dados para tipo
                let doutorado = concluidos.ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO
                
                let doutorado_ordem = doutorado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO))

                // Caso doutorado: Orientador
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )
                
                if doutorado_filtro.len() > 0 {
                    // criar cabeçalho
                    [=== Tese de doutorado: orientador <orientacao_concluida_doutorado_orientador>]

                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criar conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // criar conteúdo final
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número para ordem
                        i -= 1
                    }
                }

                // Caso doutorado: Co-orientador
                let doutorado_filtro = doutorado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )
                
                if doutorado_filtro.len() > 0 {
                    // criar cabeçalho
                    [=== Tese de doutorado: co-orientador <orientacao_concluida_doutorado_coorientador>]

                    let i = doutorado_filtro.len()
                    for entrada in doutorado_filtro.rev() {
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // criar conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // criar conteúdo final
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número para ordem
                        i -= 1
                    }
                }
            }
            
            // para Mestrado
            if "ORIENTACOES-CONCLUIDAS-PARA-MESTRADO" in concluidos.keys() {
                // criar banco de dados
                let mestrado = concluidos.ORIENTACOES-CONCLUIDAS-PARA-MESTRADO
                
                let mestrado_ordem = mestrado.sorted(key: (item) => (item.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO))
                
                // Caso: Orientador
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR"
                )
                
                // criar conteúdo se tiver ao mínimo uma entrada
                if mestrado_filtro.len() > 0 {
                    // criar cabeçalho
                    [=== Dissertações de mestrado: orientador <orientacao_concluida_mestrado_orientador>] 

                    // criar número para ordem (descendo)
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criar variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // Criar conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // criar conteúdo final
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número (para ordem)
                        i -= 1
                    }
                }

                // Caso: Co-orientador
                let mestrado_filtro = mestrado_ordem.filter(
                    entry => entry.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR"
                )
                
                // criar conteúdo se tiver ao mínimo uma entrada
                if mestrado_filtro.len() > 0 {
                    // criar cabeçalho
                    [=== Dissertações de mestrado: co-orientador <orientacao_concluida_mestrado_coorientador>] 

                    // criar número para ordem (descendo)
                    let i = mestrado_filtro.len()
                
                    for entrada in mestrado_filtro.rev() {
                        // criar variáveis
                        let orientando = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.ANO
                        let tipo = entrada.DADOS-BASICOS-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NATUREZA
                        let programa = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.NOME-DA-INSTITUICAO

                        // Criar conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // criar conteúdo final
                        create-cols([*#i.*], [#descricao_content], "enum")

                        // diminuir número (para ordem)
                        i -= 1
                    }
                }
            } 

            // para TCC / Graduação (sem separação de Co-orientador/orientador)
            // TODO: Não tenho certeza sobre o keys
            if "OUTRAS-ORIENTACOES-CONCLUIDAS" in concluidos.keys() {
                // criar banco de dados
                let outras = concluidos.OUTRAS-ORIENTACOES-CONCLUIDAS

                let outras_ordem = outras.sorted(key: (item) => (item.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.ANO))

                // ao mínimo precisa uma entrada
                if outras_ordem.len() > 0 {
                    // criar cabeçalho
                    [=== Trabalhos de conclusão de curso de graduação <orientacao_concluida_graduacao>]

                    // criar número para ordem (descendo)
                    let i = outras_ordem.len()

                    // criar conteúdo para cada entrada
                    for entrada in outras_ordem.rev() {
                        // criar variáveis
                        let orientando = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NOME-DO-ORIENTADO
                        let titulo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.TITULO
                        let ano = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.ANO
                        let programa = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NOME-DO-CURSO
                        let universidade = entrada.DETALHAMENTO-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NOME-DA-INSTITUICAO

                        // A NATUREZA está em maiúsculas e com sublinhado
                        let tipo = entrada.DADOS-BASICOS-DE-OUTRAS-ORIENTACOES-CONCLUIDAS.NATUREZA
                        
                        // Defina uma função para capitalizar a primeira letra de um substring
                        let capitalize = (text) => [#text.slice(0, 1)#lower(text.slice(1))]

                        // Divida a string em partes com base nos espaços
                        let tipo_parts = tipo.split("_")

                        // Capitalize cada parte e junte-as novamente com espaços
                        tipo = tipo_parts.map(capitalize).join(" ")
                        
                        // Criar conteúdo
                        descricao_content = [#orientando. #text(weight: "semibold", titulo). #ano. #tipo (#programa) - #universidade]

                        // criar conteúdo final
                        create-cols([*#i.*], [#descricao_content], "enum")
                        
                        // diminuir número (para ordem)
                        i -= 1
                    }
                }
            }
        }
    }

    linebreak()
    
    line(length: 100%)
}

// Criando entradas de participação em eventos
// Esta função cria as entradas para a participação em eventos (não para o trabalho enviado nos eventos)
// Argumentos:
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
#let create-events(detalhes) = {
    if "PARTICIPACAO-EM-EVENTOS-CONGRESSOS" in detalhes.DADOS-COMPLEMENTARES.keys() {
        // criar banco de dados
        let eventos = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-EVENTOS-CONGRESSOS

        // criar variáveis
        let descricao_content = []

        [= Eventos <eventos>]

        if "PARTICIPACAO-EM-CONGRESSO" in eventos.keys() {
            [=== Participação em eventos <eventos_participacao>]
            let congressos = eventos.PARTICIPACAO-EM-CONGRESSO

            // Ordenar por ano e título
            let congressos_sorted = congressos.sorted(key: (item) => (item.DADOS-BASICOS-DA-PARTICIPACAO-EM-CONGRESSO.ANO, item.DADOS-BASICOS-DA-PARTICIPACAO-EM-CONGRESSO.TITULO))

            // Criar número para ordem decrescente (vantagem: você pode ler diretamente em quantos eventos a pessoa participou)
            let i = congressos_sorted.len()
            // loop pelas entradas
            for entrada in congressos_sorted.rev() {
                // criar entradas
                let evento = entrada.DETALHAMENTO-DA-PARTICIPACAO-EM-CONGRESSO.NOME-DO-EVENTO
                let subset = entrada.DADOS-BASICOS-DA-PARTICIPACAO-EM-CONGRESSO
                let tipo = subset.TIPO-PARTICIPACAO
                let ano = subset.ANO
                let natureza = subset.NATUREZA
                let titulo = subset.TITULO

                // criar texto
                descricao_content = [#tipo em #strong(evento), #ano (natureza). #titulo]

                // criar entrada final
                create-cols([*#i.*], [#descricao_content], "enum")

                // diminuir número (ordem descendo)
                i -= 1
            }
        }
    }    
}

// Criando entradas de bancas
// Esta função criará as entradas de participações em bancas de exame
// Argumentos
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - me: nome para destacar no currículo (string)
#let create-examinations(detalhes, me) = {
    // criar banco de dados
    let bancas = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO

    // criar banco de dados para cada tipo
    let bancas_graduacao = (:)
    let bancas_mestrado = (:)
    let bancas_doutorado = (:)

    // criar banco de dados para cada tipo depende da existência
    // para graduação
    // TODO: Não tenho certeza sobre o key
    if "PARTICIPACAO-EM-BANCA-DE-GRADUACAO" in bancas.keys() {
        bancas_graduacao = bancas.PARTICIPACAO-EM-BANCA-DE-GRADUACAO
    } else {
        bancas_graduacao = (:)
    }

    // para mestrado
    if "PARTICIPACAO-EM-BANCA-DE-MESTRADO" in bancas.keys() {
        bancas_mestrado = bancas.PARTICIPACAO-EM-BANCA-DE-MESTRADO
    } else {
        bancas_mestrado = (:)
    }

    // para doutorado
    // TODO: Não tenho certeza sobre o key
    if "PARTICIPACAO-EM-BANCA-DE-DOUTORADO" in bancas.keys() {
        bancas_doutorado = bancas.PARTICIPACAO-EM-BANCA-DE-DOUTORADO
    } else {
        bancas_doutorado = (:)
    }

    // criar entrada se ao mínimo um tipo de banca > 0
    if bancas_graduacao.len() > 0 or bancas_mestrado.len() > 0  or bancas_doutorado.len() > 0 [
        = Bancas <bancas>
        == Participação em banca de trabalhos de conclusão <bancas_conclusao>
    ]

    // criar entradas para graduação, se ao mínimo tem uma entrada
    // TODO: Não tenho certeza sobre o key, provavelmente dê erro
    if bancas_graduacao.len() > 0 {
        // criar cabeçalho
        [== Graduação <bancas_conclusao_graduacao>]

        // Para ordem decrescente (vantagem: na primeira entrada você pode ver quantas ações uma pessoa fez)
        let i = bancas_graduacao.len()

        for banca in bancas_graduacao {
            // criar entradas
            let participantes = ()
            let candidato = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.NOME-DO-CANDIDATO
            let titulo = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.TITULO
            let ano = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.ANO
            let programa = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.NOME-CURSO
            let universidade = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-GRADUACAO.NOME-INSTITUICAO
            
            // se somente tem uma entrada, type é dictionary
            // se tem mais de uma entrada, type é array
            // o texto vai ser formato no estilo de ABNT
            if type(banca.PARTICIPANTE-BANCA) == dictionary {
                if "NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA" in pessoa.keys() {
                    let name_parts = pessoa.at("NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA").split(", ")
                    let name = name_parts.at(0).slice(0, 1) + lower(name_parts.at(0).slice(1)) + ", " + name_parts.at(1).slice(0, 1) + "."
                    participants.push(name)
                }
            } else if type(banca.PARTICIPANTE-BANCA) == array {
                let subset = banca.PARTICIPANTE-BANCA
                for participante in subset {
                let nome_partes = participante.NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA.split(", ")
                let nome = upper(nome_partes.at(0)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                participantes.push(nome)
                }      
            }

            // criar string de todas pessoas na banca
            participantes = participantes.join("; ")
            
            // destacar o nome que foi indicado
            if not me == none {
                if type(participantes) != none and participantes != none {
                    let pesquisa = participantes.match(me)
                    if pesquisa.start == 0 {
                        participantes = [*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        participantes = [#participantes.slice(0, pesquisa.start)*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                    }
                }
            }

            // criar entrada final
            create-cols([*#i*], [#participantes Participação em banca de #candidato. #titulo, #ano. (#programa), #universidade ], "enum")

            // diminuir o número (enumerar descendo)
            i -= 1
        }
    }

    if bancas_mestrado.len() > 0 {
        // criar cabeçalho
        [== Mestrado <bancas_mestrado_graduacao>]

        // Para ordem decrescente (vantagem: na primeira entrada você pode ver quantas ações uma pessoa fez)
        let i = bancas_mestrado.len()

        for banca in bancas_mestrado {
            // criar entradas
            let participantes = ()
            let candidato = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.NOME-DO-CANDIDATO
            let titulo = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.TITULO
            let ano = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.ANO
            let programa = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.NOME-CURSO
            let universidade = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-MESTRADO.NOME-INSTITUICAO

            // se somente tem uma entrada, type é dictionary
            // se tem mais de uma entrada, type é array
            // o texto vai ser formato no estilo de ABNT
            if type(banca.PARTICIPANTE-BANCA) == dictionary {
                if "NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA" in pessoa.keys() {
                    let nome_partes = pessoa.at("NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA").split(", ")
                    let nome = nome_partes.at(0).slice(0, 1) + lower(nome_partes.at(0).slice(1)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                    // Array if only one person, therefore, always resonpsable
                    participants.push(nome)
                }
            } else if type(banca.PARTICIPANTE-BANCA) == array {
                let subset = banca.PARTICIPANTE-BANCA
                for participante in subset {
                    let nome_partes = participante.NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA.split(", ")
                    let nome = upper(nome_partes.at(0)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                    participantes.push(nome)
                }      
            }

            // criar string de todas pessoas na banca
            participantes = participantes.join("; ")

            // destacar o nome que foi indicado
            if not me == none {
                if type(participantes) != none and participantes != none {
                    let pesquisa = participantes.match(me)
                    if pesquisa.start == 0 {
                        participants = [*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        participantes = [#participantes.slice(0, pesquisa.start)*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                    }
                }
            }

            // criar entrada final
            create-cols([*#i*], [#participantes Participação em banca de #candidato. #titulo, #ano. (#programa), #universidade ], "enum")

            // diminuir o número (enumerar descendo)
            i -= 1
        }
    }
    
    // TODO: Não tenho certeza sobre o key! Provavelmente dê erro
    if bancas_doutorado.len() > 0 {
        // criar cabeçalho
        [== Doutorado <bancas_conclusao_doutorado>]

        // Para ordem decrescente (vantagem: na primeira entrada você pode ver quantas ações uma pessoa fez)
        let i = bancas_doutorado.len()

        for banca in bancas_doutorado {
            // criar entradas
            let participantes = ()
            let candidato = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.NOME-DO-CANDIDATO
            let titulo = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.TITULO
            let ano = banca.DADOS-BASICOS-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.ANO
            let programa = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.NOME-CURSO
            let universidade = banca.DETALHAMENTO-DA-PARTICIPACAO-EM-BANCA-DE-DOUTORADO.NOME-INSTITUICAO

            // se somente tem uma entrada, type é dictionary
            // se tem mais de uma entrada, type é array
            // o texto vai ser formato no estilo de ABNT
            if type(banca.PARTICIPANTE-BANCA) == dictionary {
                if "NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA" in pessoa.keys() {
                    let nome_partes = pessoa.at("NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA").split(", ")
                    let nome = nome_partes.at(0).slice(0, 1) + lower(nome_partes.at(0).slice(1)) + ", " + nome_partes.at(1).slice(0, 1) + "."
                    participantes.push(nome)
                }
            } else if type(banca.PARTICIPANTE-BANCA) == array {
                let subset = banca.PARTICIPANTE-BANCA
                for participante in subset {
                    let nome_parts = participante.NOME-PARA-CITACAO-DO-PARTICIPANTE-DA-BANCA.split(", ")
                    let nome = upper(nome_parts.at(0)) + ", " + nome_parts.at(1).slice(0, 1) + "."
                    participantes.push(nome)
                }      
            }

            // criar string de todas pessoas na banca
            participantes = participantes.join("; ")

            if not me == none {
                if type(participantes) != none and participantes != none {
                    let pesquisa = participantes.match(me)
                    if pesquisa.start == 0 {
                        participantes = [*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                    } else if pesquisa.start != none {
                        participantes = [#participantes.slice(0, pesquisa.start)*#participantes.slice(pesquisa.start, pesquisa.end)*#participantes.slice(pesquisa.end)]
                    }
                }
            }

            // criar entrada final
            create-cols([*#i*], [#participantes Participação em banca de #candidato. #titulo, #ano. (#programa), #universidade ], "enum")

            // diminuir o número (enumerar descendo)
            i -= 1
        }
    }
}

// Criando a última página
// A última página é um resumo de todas as informações
// Argumentos
//  - detalhes: o banco de dados com todas as informações (arquivo TOML)
//  - tipo_lattes: tipo de currículo Lattes
#let create-last-page(detalhes, tipo_lattes) = {
  
    [= Totais de produção]

    // Producao bibliografica
    // verificar bancos de dados
    let artigos = detalhes.PRODUCAO-BIBLIOGRAFICA.ARTIGOS-PUBLICADOS
    let livros = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.LIVROS-PUBLICADOS-OU-ORGANIZADOS.LIVRO-PUBLICADO-OU-ORGANIZADO
    let capitulos = detalhes.PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.CAPITULOS-DE-LIVROS-PUBLICADOS.CAPITULO-DE-LIVRO-PUBLICADO
    
    // criar sub-categórias para apresentações
    let apresentacoes = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.APRESENTACAO-DE-TRABALHO

    let conferencias = apresentacoes.filter(
        entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "CONFERENCIA"
    )
    let congressos = apresentacoes.filter(
        entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "CONGRESSO"
    )
    let seminarios = apresentacoes.filter(
        entry => entry.DADOS-BASICOS-DA-APRESENTACAO-DE-TRABALHO.NATUREZA == "SEMINARIO"
    )

    // Se pelo menos uma entrada em um desses, obtemos o cabeçalho
    if artigos.len() > 0 or livros.len() > 0 or capitulos > 0 or conferencia.len() > 0 or congresso.len() > 0  or seminaro.len() > 0 {
        [#link(<producao_bibliografica>)[== Produção bibliográfica]]
    }

    // Criar a soma de artigos
    if artigos.len() > 0 {
        create-cols([#link(<publicacao_artigos>)[Artigos completos] #box(width: 1fr, repeat[.])], [#artigos.len()], "lastpage")
    }
    
    // Criar a soma de livros
    if livros.len() > 0 {
        create-cols([#link(<publicacao_livros>)[Livros publicados #box(width: 1fr, repeat[.])]], [#livros.len()], "lastpage")
    }
    
    // Criar a soma de capítulos
    if capitulos.len() > 0 {
        create-cols([#link(<publicacao_capitulos>)[Capítulos de livros publicados #box(width: 1fr, repeat[.])]], [#capitulos.len()], "lastpage")
    }
    
    // Criar a soma de apresentações: Conferências
    if tipo_lattes == "completo" {
        if conferencias.len() > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Conferência ou palestra) #box(width: 1fr, repeat[.])]], [#conferencias.len()], "lastpage")
        }  

        // Criar a soma de apresentações: Congressos
        if congressos.len() > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Congresso) #box(width: 1fr, repeat[.])]], [#congressos.len()], "lastpage")
        }
        
        // Criar a soma de apresentações: Seminários
        if seminarios.len() > 0 {
            create-cols([#link(<producao_apresentacoes>)[Apresentações de trabalhos (Seminário) #box(width: 1fr, repeat[.])]], [#seminarios.len()], "lastpage")
        }
    }     
    
    // Producao tecnica
    // Criar bancos de dados
    let cursos_curtos = ()
    // TODO: Create cursos_curtos
    let didaticos = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.DESENVOLVIMENTO-DE-MATERIAL-DIDATICO-OU-INSTRUCIONAL
    let relatorios = detalhes.PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.RELATORIO-DE-PESQUISA

    // Criar cabeçalho
    if cursos_curtos.len() > 0 or didaticos.len() > 0 or relatorios.len() > 0 {
        [#link(<producao_tecnica>)[== Produção técnica]]
    }
    
    // criar soma de cursos curtos
    if cursos_curtos.len() > 0 {
        create-cols([#link(<ensino_atuacao>)[Curso de curta duração ministrado #box(width: 1fr, repeat[.])]], [#cursos_curtos.len()], "lastpage")
    }
    
    // criar soma de materiais didáticos
    if didaticos.len() > 0 {
        create-cols([#link(<producao_tecnica_demais>)[Desenvolvimento de material didático ou instrucional #box(width: 1fr, repeat[.])]], [#didaticos.len()], "lastpage")
    }
    
    // criar soma de relatórios
    if relatorios.len() > 0 {
        create-cols([#link(<producao_tecnica_demais>)[Relátorio de pesquisa #box(width: 1fr, repeat[.])]], [#relatorios.len()], "lastpage")
    }
    
    // Orientacoes
    // Criar banca de dados
    let orientacoes = detalhes.OUTRA-PRODUCAO
    
    // criar cabeçalho
    if "ORIENTACOES-EM-ANDAMENTO" in orientacoes.keys() {
        [#link(<orientacao>)[== Orientações]]
    } else if "ORIENTACOES-CONCLUIDAS" in orientacoes.keys() {
        [#link(<orientacao>)[== Orientações]]
    }

    // Criar bancos de dados para supervisões em andamento
    // TODO: não tenho certeza sobre a chave, não a encontrei no meu banco de dados
    // criar banco de dados total e entradas
    let andamentos = ()
    if "ORIENTACOES-EM-ANDAMENTO" in orientacoes {
        andamentos = orientacoes.ORIENTACOES-EM-ANDAMENTO

        // para graduação
        let graduacao_andamento = 0
        
        // TODO: não tenho certeza sobre a chave, nos outros bancos sempre foi OUTRAS-ORIENTACOES para graduação
        // Defina o número de orientações para o comprimento do array
        if "OUTRAS-ORIENTACOES-EM-ANDAMENTO" in andamentos.keys() {
            graduacao_andamento = andamentos.OUTRAS-ORIENTACOES-EM-ANDAMENTO.len()
        }

        // para mestrado
        let mestrado_andamento_orientador = 0
        let mestrado_andamento_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO" in andamentos.keys() {
            for orientacao in andamentos.ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    mestrado_andamento_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    mestrado_andamento_coorientador += 1 
                }
            }
        }

        // para doutorado
        // TODO: ainda não sei a chave correta, provavelmente precisarei corrigir quando tiver uma entrada
        let doutorado_andamento_orientador = 0
        let doutorado_andamento_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO" in andamentos.keys() {
            for orientacao in andamentos.ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    doutorado_andamento_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-EM-ANDAMENTO-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    doutorado_andamento_coorientador += 1 
                }
            }
        }

        // TODO: ainda não sei a chave correta, provavelmente precisarei corrigir quando tiver uma entrada
        // Criar campo se o comprimento for maior que 0 (orientador doutorado)
        if doutorado_andamento_orientador > 0 {
            create-cols([#link(<orientacao_andamento_doutorado_orientador>)[Orientação em andamento (tese de doutorado - orientador)] #box(width: 1fr, repeat[.])], [#doutorado_andamento_orientador], "lastpage")
        }

        // Criar campo se o comprimento for maior que 0 (co-orientador doutorado)
        if doutorado_andamento_coorientador > 0 {
            create-cols([#link(<orientacao_andamento_doutorado_coorientador>)[Orientação em andamento (tese de doutorado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_andamento_coorientador], "lastpage")
        }

        // Criar campo se o comprimento for maior que 0 (orientador mestrado)
        if mestrado_andamento_orientador > 0 {
            create-cols([#link(<orientacao_andamento_mestrado_orientador>)[Orientação em andamento (dissertação de mestrado - orientador) #box(width: 1fr, repeat[.])]], [#mestrado_andamento_orientador], "lastpage")
        }
        
        // Criar campo se o comprimento for maior que 0 (co-orientador doutorado)
        if mestrado_andamento_coorientador > 0 {
            create-cols([#link(<orientacao_andamento_mestrado_coorientador>)[Orientação em andamento (dissertação de mestrado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_andamento_coorientador], "lastpage")
        }

        // Criar campo se o comprimento for maior que 0 (graduacao)
        if graduacao_andamento > 0 { 
            create-cols([#link(<orientacao_andamento_graduacao>)[Orientação em andamento (trabalho de conclusão de curso de graduação) #box(width: 1fr, repeat[.])]], [#graduacao_andamento], "lastpage")
        }
    }

    // Orientações concluídas
    // criar banco de dados total e entradas
    let concluidas = ()

    if "ORIENTACOES-CONCLUIDAS" in orientacoes {
        concluidas = orientacoes.ORIENTACOES-CONCLUIDAS

        // para graduação
        let graduacao_concluidas = 0
        
        // TODO: não tenho certeza sobre o key
        if "OUTRAS-ORIENTACOES-CONCLUIDAS" in concluidas.keys() {
            graduacao_concluidas = concluidas.OUTRAS-ORIENTACOES-CONCLUIDAS.len()
        }

        // Criar bancos de dados
        let mestrado_concluidas_orientador = 0
        let mestrado_concluidas_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-CONCLUIDAS-PARA-MESTRADO" in concluidas.keys() {
            for orientacao in concluidas.ORIENTACOES-CONCLUIDAS-PARA-MESTRADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    mestrado_concluidas_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-MESTRADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    mestrado_concluidas_coorientador += 1 
                }
            }
        }

        // para doutorado
        // TODO: ainda não sei a chave correta, provavelmente precisarei corrigir quando tiver uma entrada
        let doutorado_concluidas_orientador = 0
        let doutorado_concluidas_coorientador = 0
        
        // Defina o número de orientações para o comprimento do array dependede do tipo de orientação (orientador ou co-orientador)
        if "ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO" in concluidas.keys() {
            for orientacao in concluidas.ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO {
                if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "ORIENTADOR" {
                    doutorado_concluidas_orientador += 1
                } else if orientacao.DETALHAMENTO-DE-ORIENTACOES-CONCLUIDAS-PARA-DOUTORADO.TIPO-DE-ORIENTACAO == "CO_ORIENTADOR" {
                    doutorado_concluidas_coorientador += 1 
                }
            }
        }

        // TODO: não tenho certeza sobre a chave acima, provavelmente há um erro aqui e preciso corrigir a chave acima
        // Criar campo se o comprimento for maior que 0 (orientador doutorado)
        if doutorado_concluidas_orientador > 0 {
            create-cols([#link(<orientacao_concluida_doutorado_orientador>)[Orientação concluída (tese de doutorado - orientador) #box(width: 1fr, repeat[.])]], [#doutorado_concluidas_orientador], "lastpage")
        }

        // Criar campo se o comprimento for maior que 0 (co-orientador doutorado)
        if doutorado_concluidas_coorientador > 0 {
            create-cols([#link(<orientacao_concluida_doutorado_coorientador>)[Orientação concluída (tese de doutorado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_concluidas_coorientador], "lastpage")
        }

        // Criar campo se o comprimento for maior que 0 (orientador mestrado)
        if mestrado_concluidas_orientador > 0 {
            create-cols([#link(<orientacao_concluida_mestrado_orientador>)[Orientação concluída (dissertação de mestrado - orientador) #box(width: 1fr, repeat[.])]], [#mestrado_concluidas_orientador], "lastpage")
        }

        // Criar campo se o comprimento for maior que 0 (co-orientador mestrado)
        if mestrado_concluidas_coorientador > 0 {
            create-cols([#link(<orientacao_concluida_mestrado_coorientador>)[Orientação concluída (dissertação de mestrado - co-orientador) #box(width: 1fr, repeat[.])]], [#mestrado_concluidas_coorientador], "lastpage")
        }

        //TODO: não tenho certeza sobre o key que usei acima, provavelmente dê erro
        // Criar campo se o comprimento for maior que 0 (graduação)
        if graduacao_concluidas > 0 { 
            create-cols([#link(<orientacao_concluida_graduacao>)[Orientação concluída (trabalho de conclusão de curso de graduação) #box(width: 1fr, repeat[.])]], [#graduacao_concluidas], "lastpage")
        }
    
        // Eventos
        // Criar cabeçalho se um dos dois estiver pelo menos nos dados
        // se tem entradas, vai seguir para criar as entradas
        if tipo_lattes == "completo" {
            if "PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO" in detalhes.DADOS-COMPLEMENTARES.keys() or "PARTICIPACAO-EM-EVENTOS-CONGRESSOS" in detalhes.DADOS-COMPLEMENTARES.keys(){
                [#link(<eventos>)[== Eventos]]
                
                // se tiver entradas para participações em eventos
                if "PARTICIPACAO-EM-EVENTOS-CONGRESSOS" in detalhes.DADOS-COMPLEMENTARES.keys() {
                    // criar banco de dados
                    let eventos = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-EVENTOS-CONGRESSOS

                    // criar variável para soma para cada tipo
                    let congressos2 = 0
                    let simposios = 0
                    let encontros = 0
                    let outras = 0

                    // Loop através dos eventos
                    // Os eventos são um array no qual cada evento é armazenado, portanto, podemos pegar o comprimento aqui
                    for event in eventos.keys() {
                        let subset = eventos.at(event)
                        if event == "PARTICIPACAO-EM-CONGRESSO" {
                            congressos2 = subset.len()
                        } else if event == "Simpósio" {
                            simposios = subset.len()
                        } else if event == "Encontro" {
                            encontros = subset.len()
                        } else {
                            outras += subset.len()
                        }
                    }

                // somente se estiver "completo"
                // Criar campo se o comprimento for maior que 0 (congressos)
                

                    if congressos2 > 0 { 
                        create-cols([#link(<eventos_participacao>)[Participações em eventos (Congresso) #box(width: 1fr, repeat[.])]], [#congressos2], "lastpage")
                    }

                    // Criar campo se o comprimento for maior que 0 (simposios)
                    if simposios > 0 { 
                        create-cols([#link(<eventos_participacao>)[Participações em eventos (Simpósios) #box(width: 1fr, repeat[.])]], [#simposios], "lastpage")
                    }

                    // Criar campo se o comprimento for maior que 0 (encontros)
                    if encontros > 0 { 
                        create-cols([#link(<eventos_participacao>)[Participações em eventos (Encontros) #box(width: 1fr, repeat[.])]], [#encontros], "lastpage")
                    }

                    // Criar campo se o comprimento for maior que 0 (outras)
                    if outras > 0 { 
                        create-cols([#link(<eventos_participacao>)[Participações em eventos (Outras) #box(width: 1fr, repeat[.])]], [#outras], "lastpage")
                    }
                }
            }

            // trabalhos em bancas de conclusão
            // se tiver entradas em participação em bancas
            if "PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO" in detalhes.DADOS-COMPLEMENTARES.keys() {
                // criar bancos
                let bancas = detalhes.DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO

                // para graduação
                // TODO: não tenho certeza sobre a chave
                let bancas_graduacao = 0 

                // criar soma de bancas de graduação
                if "PARTICIPACAO-EM-BANCA-DE-GRADUACAO" in bancas.keys() {
                    bancas_graduacao = bancas.PARTICIPACAO-EM-BANCA-DE-GRADUACAO.len()
                }

                // para mestrado
                let bancas_mestrado = 0 

                // criar soma de bancas de mestrado
                if "PARTICIPACAO-EM-BANCA-DE-MESTRADO" in bancas.keys() {
                    bancas_mestrado = bancas.PARTICIPACAO-EM-BANCA-DE-MESTRADO.len()
                }

                // para doutorado
                // TODO: não tenho certeza sobre a chave
                let bancas_doutorado = 0 
                // criar soma de bancas de doutorado
                if "PARTICIPACAO-EM-BANCA-DE-DOUTORADO" in bancas.keys() {
                    bancas_doutorado = bancas.PARTICIPACAO-EM-BANCA-DE-DOUTORADO.len()
                }

                // Criar entradas
                // criar entrado para doutorado (se não estiver 0)
    
                if bancas_doutorado > 0 { 
                    create-cols([#link(<bancas>)[Participação em banca de trabalhos de conclusão (doutorado) #box(width: 1fr, repeat[.])]], [#bancas_doutorado], "lastpage")
                }

                // criar entrado para mestrado (se não estiver 0)
                if bancas_mestrado > 0 { 
                    create-cols([#link(<bancas>)[Participação em banca de trabalhos de conclusão (mestrado) #box(width: 1fr, repeat[.])]], [#bancas_mestrado], "lastpage")
                }

                // criar entrado para graduação (se não estiver 0)
                if bancas_graduacao > 0 { 
                    create-cols([#link(<bancas>)[Participação em banca de trabalhos de conclusão (graduação) #box(width: 1fr, repeat[.])]], [#bancas_graduacao], "lastpage")
                }
            }
        }
    }
}
