#import "@preview/datify:0.1.3": *
#import "utils.typ": *

// Function _create-cols: setting style and table
// Arguments:
// - left: the content to be placed in the first column (Type: Any)
// - right: the content to be placed in the second column (Type: Any)
// - ..args: additional named arguments for customization

#let _create-cols(left, right, type, ..args) = {
  
  // Set the block style with no spacing below
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

  // Create a table with specified column widths and no border strokes
  table(
    columns: col_width, // Set column widths
    stroke: none, // No border strokes
    
    // Spread any named arguments
    ..args.named(),
    
    // Insert the left and right content into the table
    left,
    right,
  )
}

// Function create-cols: Putting input into the table
// Arguments:
// - left-side: the content to be aligned to the right (Type: Any)
// - right-side: the content to be formatted as a paragraph with justified alignment (Type: Any)
// - type: string which type: small, wide, or enum
#let create-cols(left-side, right-side, type) = {
  
  // Call the _cv-cols with aligned left-side and justified right-side parameters
  if type == "lastpage" {
    _create-cols(
        align(right, left-side),
        par(right-side, justify:false),
        type
    )
  } else {
    _create-cols(
        // Align the left-side content to the right
        align(right, left-side),
        // Format the right-side content as a paragraph with justified alignment
        align(left, par(right-side, justify: true)),
        type
        )
  }
}


#let lattes-cv(
  me: str,
  last_page: true,
  kind: "completo", 
  subtitle: "Curriculum Vitae",
  date: none,
  database: "output.toml",
  body,
) = {
    // define details:
    let details = toml(database)

    // define author
    let author = details.DADOS-GERAIS.NOME-COMPLETO

    
    // define the document 
    set document(title: "CV Lattes", author: author)

    // set text options (size, font, language)
    set text(
        size: 12pt,
        font: "Source Sans Pro",
        lang: "pt", 
        region: "br"
    )

    // create title page
    set page(
        paper: "a4",
        margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm)
    )
    
    align(horizon + center)[
        #text(20pt, author, weight: "bold", fill: rgb("B2B2B2"))
        
        #text(subtitle, weight: "semibold")
    ]

    align(bottom + center)[
        #text(custom-date-format(date, "Month de YYYY", "pt"))
    ]

    pagebreak()

    // rest of the document
    set page(
        paper: "a4",
        margin: (top: 2cm, bottom: 2cm, left: 2cm, right: 2cm),
        footer: context [
            #set align(right)
            #set text(8pt)
            Página #counter(page).display("1 de 1", both: true)
        ]
    )

    // new numbering beginning from 1
    counter(page).update(1)

    // section on personal information
    align(top + left)[
        #text(20pt, author, weight: "bold", fill: rgb("B2B2B2"))

        #text(subtitle, weight: "regular")
    ]

    line(length: 100%)

    // Begin Content
    create-identification(details)  

    create-languages(details)
    
    create-prices(details)

    create-education(details, kind)
    
    create-advanced-training(details)

    create-atuacao(details)
    
    if kind == "completo" {
        create-projects(details)
    }    

    create-revisor(details)

    if kind != "resumido" {
        create-areas-atuacao(details)
    }

    create-bibliography(details, me, kind)

    if kind == "completo" {
        create-innovations(details)
    }
    
    create-supervisions(details)

    if kind == "completo" {
        create-events(details)
    
        create-examinations(details, me)
    }
    
    if last_page == true {
        pagebreak()

        create-last-page(details, kind)
    } 
}