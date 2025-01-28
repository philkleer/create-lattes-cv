# create-lattes-cv

# 👷🏼‍♀️ ⚠ Ainda em construção, não está pronto para todos os tipos de entradas.

[LATTES](https://lattes.cnpq.br) é uma ótima plataforma para acadêmicos armazenarem todo o seu trabalho científico. No entanto, as opções de exportação são bastante frustrantes, já que a exportação em RTF não resulta em um currículo com uma boa aparência.

Por isso, estou tentando resolver esse problema exportando o arquivo XML e criando este modelo para gerar um PDF bem formatado usando [Typst](https://typst.app). Se você ainda não conhece o [Typst](https://typst.app), ele é uma linguagem muito mais fácil de aprender e um compositor mais rápido do que o LaTeX.

Eu iniciei este projeto e, como no meu currículo do [LATTES](https://lattes.cnpq.br) não estão disponíveis todas as opções possíveis, pode haver erros quando você testá-lo. Você pode abrir uma [issue]() ou criar um pull request com uma solução sugerida. Além disso, este é apenas o começo, então o código pode não estar tão simples e bonito quanto deveria ser.

## Fonts

Eu uso [Source Sans Pro](https://fonts.google.com/specimen/Source+Sans+3), que você pode obter [aqui](https://fonts.google.com/specimen/Source+Sans+3).

## Uso

### Exportar arquivo XML e criar arquivo toml
Como estou mais familiarizado com arquivos toml e seu uso no [Typst](https://typst.app), criei o script em Python `helper.py`, que converte seu arquivo XML do [LATTES](https://lattes.cnpq.br) em um arquivo toml. Para fazer a transformação, basta executar a seguinte linha no terminal, onde o script está localizado:

```bash
python3 helper.py caminho-para-o-seu-arquivo-xml
```

Isso criará o arquivo `meu-arquivo.toml`, que você poderá usar nos documentos do Typst.

### Criando o PDF 

A estrutura do arquivo principal é bastante simples. Você só precisa indicar qual versão do currículo deseja no argumento `kind`: `resumido`, `ampliado` ou `completo`. Dependendo da sua escolha, você utiliza a função específica:

```typst
// Import of libraries
#import "lib.typ": *
#import "@preview/datify:0.1.3": *

#show: lattes-cv.with(
  database: "data/lattes.toml",
  kind: "completo",
  me: "KLEER",
  date: datetime.today()
  last_page: true
)     
```

#### Uso de Typst local

Antes de usar, você precisa instalar ou fazer update para Typst 0.12. Como você poderia instalar é descrevido [aqui](https://github.com/typst/typst).

#### Uso no editor online de Typst
Você poderia usar o editor online de [Typst](https://typst.app) para criar um projeto. Você poderia copiar esse projeto que já tem todos os arquivos (sem o arquivo criado do Lattes): [Link](https://typst.app/project/rDHeKkEoT9UuHDnnH93mQq). Você poderia copiar o projeto para usar.

Antes de executar, você somente precisa fazer o upload do arquivo transformado para `.toml` do Lattes. 

### Uso ou melhorias das funções

Esta é uma primeira abordagem simples para uma solução, e eu ainda não estruturei tudo completamente. O objetivo principal, até o momento, é ter funções para cada área que são chamadas se a área específica estiver presente nos dados XML/TOML.

As variáveis locais (em funções, loops, etc.) têm nomes em português. As variáveis globais têm nomes em inglês (global refere-se ao uso em `lib.typ`).

### Como participar? (pull request)

Se você quiser participar no projeto, você pode gerar um *fork* e depois um *pull request* para adicionar seu código. 

### O que já está incluído

Embaixo tem uma tabela sobre as áreas no currículo Lattes. Eu não tenho todas categórias no meu, enfim eu não sei quais categórias são incluídas. Se você tiver uma dessas categórias marcada com 🧐 no seu currículo, você poderia alterar a tabela. 

#### Status de programar a área

👷🏼 : precisa de trabalho (parcialmente codificado)

🎬 : finalizado

⛔️ : ainda não é começado

#### Inclusão no tipo de currículo

❌ : não incluído no tipo

✅ : incluído no tipo

🧐 : não certo que é incluído ou não

| Área | Coded? | Parte de tipo *completo* | Parte de tipo *ampliado* | Parte de tipo *resumido* | Key para área | 
| :---------------- | :----:| :----:| :----:| :----:| :---------|
| **Identificação** |  🎬 | ✅ | ✅ | ✅ | `detalhes.DADOS-GERAIS` |
| **Licenças** | ⛔️ | 🧐 | 🧐 | 🧐 |  |
| **Idiomas** | 🎬 | ✅ | ✅ | ❌ | `DADOS-GERAIS.IDIOMAS` |
| **Prêmios e títulos** (provavelmente nem todos tipos) |  👷🏼 | ✅ | ✅ | ❌ |`DADOS-GERAIS.PREMIOS-TITULOS` |
| **Formação acadêmica** (provavelmente nem todos tipos) | 👷🏼 | ✅ | ✅ | ✅ | `DADOS-GERAIS.FORMACAO-ACADEMICA-TITULACAO` |
| **Formação complementar** |  🎬 |  ✅ |  ✅ |  ✅ | `DADOS-COMPLEMENTARES.FORMACAO-COMPLEMENTAR` |
| **Atuação profissional** (talvez tenha mais tipos) | 👷🏼 |  ✅ |  ✅ |  ✅ | `DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL` |
| Atuação profissional - Vínculos | 🎬 |  ✅ |  ✅ |  ✅ | |
| Atuação profissional - Vínculos - Atividades Comissões (provavelmente não todos tipos) | 👷🏼 |  ✅ |  ✅ |  ✅ | |
| Atuação profissional - Vínculos - Atividades Ensino (provavelmente não todos tipos) | 👷🏼 |  ✅ |  ✅ |  ✅ | |
| **Projetos** (talvez tenha mais tipos) | 👷🏼 |  ✅ |  ❌ |  ❌ | `DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL.ATIVIDADES-DE-PARTICIPACAO-EM-PROJETO` |
| Projetos - Projetos de pesquisa |  🎬 |  ✅ |  ❌ | ❌ |  |
| Projetos - Projetos de desenvolvimento tecnologica |  👷🏼 |  ✅ |  🧐 | 🧐 |  |
| Projetos - Projetos de extensão |  👷🏼 |  ✅ |  🧐 | 🧐 |  |
| Projetos - Projetos de ensino |  🎬 |   ✅ |  ❌ | ❌ |  |
| Projetos - Outros tipos de extensão |  👷🏼 |  ✅ |  🧐 | 🧐 | |
| **Revisor periódico** | 🎬 |  ✅ |  ✅ |  ✅ | `DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL.VINCULOS.OUTRO-VINCULO-INFORMADO` |
| **Membro de comitê de assessora** | 🎬 |  ✅ |  ✅ |  ✅ | `DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL.VINCULOS.OUTRO-VINCULO-INFORMADO` |
| **Revisor de projeto de agência de fomento** | 🎬 |  ✅ |  ✅ |  ✅ | `DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL.VINCULOS.OUTRO-VINCULO-INFORMADO` |
| **Área de atuação** |   🎬 |  ✅ |  ✅ | ❌ | `DADOS-GERAIS.AREAS-DE-ATUACAO.AREA-DE-ATUACAO`  |
| **Produção bibliográfica** (talvez tenha mais tipos) | 👷🏼 | ✅ | ✅ | ✅ |`PRODUCAO-BIBLIOGRAFICA` |
| Produção bibliográfica - artigos | 🎬 |  ✅ |  ✅ |  ✅ |`PRODUCAO-BIBLIOGRAFICA.ARTIGOS-PUBLICADOS.ARTIGO-PUBLICADO` |
| Produção bibliográfica - livros | 🎬 |  ✅ |  ✅ |  ✅ | `PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.LIVROS-PUBLICADOS-OU-ORGANIZADOS`|
| Produção bibliográfica - capítulos de livros | 🎬 |  ✅ |  ✅ |  ✅ | `PRODUCAO-BIBLIOGRAFICA.LIVROS-E-CAPITULOS.CAPITULOS-DE-LIVROS-PUBLICADOS`|
| Produção bibliográfica - texto em jornal ou revista | ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Produção técnica** | 👷🏼 | ✅ | ✅ | ✅ | |
| Produção técnica - Demais produções técnicas | 👷🏼 |  ✅ |  ✅ | ✅ | |
| Produção técnica - Assessoria | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Extensão tecnológica |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Programa de computador sem registro | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Produtos |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Processos |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Trabalhos técnicos |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Extensão tecnológica |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Outras produções técnicas |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Entrevistas, mesas redondas, programas e comentários na mídia |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Redes sociais, websites, blogs |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção técnica - Apresentações de trabalho e palestra | 🎬 |  ✅ |  ❌ | ❌ | `PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.APRESENTACAO-DE-TRABALHO` |
| **Produção artista/cultural** | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção artista/cultural - Artes cénicas | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção artista/cultural - Música | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção artista/cultural - Artes visuais | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Produção artista/cultural - Outra produção artista/cultural | ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Patentes e registros** | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Patente | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Programa de Computador registrado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Cultivar protegida | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Cultivar registrada | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Desenho industrial registrado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Marca registrada | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Patentes e registros - Topografia de circuito integrado registrada| ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Inovação** (somente um filtro) | 👷🏼 | ✅ | ❌ | ❌ | `DADOS-GERAIS.ATUACOES-PROFISSIONAIS.ATUACAO-PROFISSIONAL` com filtro `FLAG-POTENCIAL-INOVACAO == "SIM"`|
| Inovação - Patente | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Programa de Computador registrado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Cultivar protegida | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Cultivar registrada | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Desenho industrial registrado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Marca registrada | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Topografia de circuito integrado registrada| ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Programa de Computador sem registro | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Produtos | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Processos ou técnicas | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Inovação - Projeto de pesquisa | 👷🏼 |  ✅ |  ❌ | ❌ | |
| Inovação - Projeto de desenvolvimento tecnologica | 👷🏼 | 🧐 | 🧐 | 🧐 | |
| Inovação - Projeto de extensão | 👷🏼 |  🧐 | 🧐 | 🧐 | |
| Inovação - Projeto de ensino | 👷🏼 |  ✅ |  ❌ | ❌ | |
| Inovação - Outros projetos | 👷🏼 |  🧐 | 🧐 | 🧐 | |
| **Educação e Popularização de C&T** (somente um filtro) | 👷🏼 |  ✅ |  ❌ | ❌ | |
| Educação e Popularização de C&T - Artigos aceitos para publicação |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Livros e capítulos  |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Texto em jornal ou revista (magazine) |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Trabalhos publicados em anais de eventos  |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Apresentação de trabalho e palestra | ✅ |  ✅ |  ❌ | ❌ | |
| Educação e Popularização de C&T - Programa de computador sem registro |  ⛔️ | 🧐 | 🧐 | 🧐 | `PRODUCAO-TECNICA.DEMAIS-TIPOS-DE-PRODUCAO-TECNICA.APRESENTACAO-DE-TRABALHO` com filtro `FLAG-DIVULGACAO-CIENTIFICA == "SIM"` |
| Educação e Popularização de C&T - Curso de curta duração ministrado |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Desenvolvimento de material didático ou instrucional |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Entrevista, mesas redondas, programas e comentários na mídia |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Programa de Computador Registrado |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Organização de eventos, congressos, exposições, feiras e olimpíadas  |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Participação de eventos, congressos, exposições, feiras e olimpíadas |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Redes sociais, websites e blogs |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Artes visuais |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Artes cênicas |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Músicas |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Outra produção bibliográfica |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Outra produção técnica |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| Educação e Popularização de C&T - Outra produção artística/ cultural |  ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Orientaçãoes e Supervisões** | 👷🏼 | ✅ | ✅ | ✅ | `OUTRA-PRODUCAO` |
| Orientações e Supervisões - em andamento (not tested yet) | 👷🏼 | ✅ | ✅ | ✅ | `OUTRA-PRODUCAO.ORIENTACOES-EM-ANDAMENTO` ?|
| Orientações e Supervisões - em andamento - graduação (not tested yet) | 👷🏼 | ✅ | ✅ | ✅ | |
| Orientações e Supervisões - em andamento - mestrado (not tested yet) | 👷🏼 | ✅ | ✅ | ✅ | |
| Orientações e Supervisões - em andamento - doutorado (not tested yet) | 👷🏼 | ✅ | ✅ | ✅ | |
| Orientações e Supervisões - em andamento - Monografia de conclusão de curso de aperfeiçoamento/especialização | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - em andamento - Iniciação Científica | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - em andamento - Supervisão de pós-doutorado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - em andamento - orientação de outra natureza | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - concluídas | 👷🏼 | ✅ | ✅ | ✅ | `OUTRA-PRODUCAO.ORIENTACOES-CONCLUIDAS` |
| Orientações e Supervisões - concluídas - graduação (not all types tested) | 👷🏼 | ✅ | ✅ | ✅ | |
| Orientações e Supervisões - concluídas - mestrado | 🎬 | ✅ | ✅ | ✅ | |
| Orientações e Supervisões - concluídas - doutorado (not tested) | 👷🏼 | ✅ | ✅ | ✅ | |
| Orientações e Supervisões - concluídas - Monografia de conclusão de curso de aperfeiçoamento/especialização | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - concluídas - Iniciação Científica | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - concluídas - Supervisão de pós-doutorado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Orientações e Supervisões - concluídas - orientação de outra natureza | ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Eventos** | 👷🏼 |  ✅ |  ❌ | ❌ | `DADOS-COMPLEMENTARES` |
| Eventos - Participação em eventos, congressos, exposições, feiras e olimpíadas | 🎬 |  ✅ |  ❌ | ❌ | `DADOS-COMPLEMENTARES.PARTICIPACAO-EM-EVENTOS-CONGRESSOS` |
| Eventos - Organização de eventos, congressos, exposições, feiras e olimpíadas | ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Bancas** | 👷🏼 |  ✅ |  ❌ | ❌ | `DADOS-COMPLEMENTARES` |
| Bancas - Participação em banca de trabalhos de conclusão | 👷🏼 |  ✅ |  ❌ | ❌ | `DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO` |
| Bancas - Participação em banca de trabalhos de conclusão - graduação (not tested) | 👷🏼 |  ✅ |  ❌ | ❌ |`DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO.PARTICIPACAO-EM-BANCA-DE-GRADUACAO` |
| Bancas - Participação em banca de trabalhos de conclusão - mestrado | 🎬 | ✅ |  ❌ | ❌ | `DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO.PARTICIPACAO-EM-BANCA-DE-MESTRADO` |
| Bancas - Participação em banca de trabalhos de conclusão - doutorado (not tested) | 👷🏼 |  ✅ |  ❌ | ❌ | `DADOS-COMPLEMENTARES.PARTICIPACAO-EM-BANCA-TRABALHOS-CONCLUSAO.PARTICIPACAO-EM-BANCA-DE-DOUTORADO` |
| Bancas - Participação em banca de trabalhos de conclusão - Exame de qualificação de doutorado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de trabalhos de conclusão - Exame de qualificação de mestrado | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de trabalhos de conclusão - Curso de aperfeiçoamento/especialização | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de comissões julgadores - Professor titular | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de comissões julgadores - Concurso público | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de comissões julgadores - Livre-docência | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de comissões julgadores - Avaliação de cursos | ⛔️ | 🧐 | 🧐 | 🧐 | |
| Bancas - Participação em banca de comissões julgadores - Outra | ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Citações** | ⛔️ | 🧐 | 🧐 | 🧐 | |
| **Totais de produções** (você poderia escolher também para resumido e ampliado com argumento `last_page`) | 👷🏼 | ✅ | ❌ | ❌ | |
| **Outras informações relevantes** | ⛔️ |🧐 | 🧐 | 🧐 | |

## Exemplos ("completo")

![LATTES CV 1](assets/pagina-1.png)

![LATTES CV 2](assets/pagina-2.png)

![LATTES CV 3](assets/pagina-3.png)

![LATTES CV 4](assets/pagina-4.png)

![LATTES CV 5](assets/pagina-5.png)
