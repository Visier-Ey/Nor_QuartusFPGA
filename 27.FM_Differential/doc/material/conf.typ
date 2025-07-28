#import "./scripts/functions.typ": *

#let primary-color = rgb("#5c5454")
#let primary-color-shadow = rgb("#c0c0c09e")
#let secondary-color = rgb("#ff4800d3")
#let secondary-color-shadow = rgb("#ff480071")
#let moon-color = rgb("#cfcfcf")
#let moon-color-shadow = rgb("#01010110")
#let font-black = rgb("#000000")
#let font-black-shadow = rgb("#00000030")


#let conf(
  title: none,
  subtitle: none,
  authors: (),
  abstract: [],
  claim: none,
  date: none,
  mode: "",
  lang: "en",
  terms: (),
  doc,
) = {
  set table(
    inset: 0pt
  )
  show table: it => {
    if (it.inset != 0pt) {
      it
    } else {
      table(
        ..it.children,
        columns: it.columns,
        stroke: (x, y) => if (y == 0) {
          (bottom: 1pt + black, top: 1pt + black)
        } else if (y == it.children.len() / it.columns.len()  - 1) {
          (bottom: 0.7pt + black)
        },
        align: center,
        inset: 5pt,
        column-gutter: 0pt
      )
    }
  }

  /* -------------------------------------------
   *  Body content
   *  ------------------------------------------- */
  {
    //* Some Global Settings
    set list(marker: ([•], [--]))
    set par(
      first-line-indent: (
        amount: if lang == "zh" { 1.5em } else { 1.5em },
        all: true,
      ),
    )
    set heading(numbering: "1.1.1.1")

    set figure(
      numbering: _ => context {
        let chapter = counter(heading).display()
        let fig-num = counter(figure).display("1")
        [#chapter.#fig-num]
      },
      caption: [],
      
    )
    //* Reset page footer and header
    counter(page).update(1)
    set page(
      header: context {
        align(left)[
          #text(8pt, moon-logo(8pt, 1pt) + " " + title)
        ]
      },
      footer: context {
        let page-counter = counter(page).display()
        let chapter = query(heading.where(level: 1).before(here())).last()
        {
          set align(right)
          line(length: 100%, stroke: 0.5pt + luma(20))
          v(5pt)
          text(
            8pt,
            if chapter != none {
              chapter.body + " • Page " + page-counter
            } else {
              "Page " + page-counter
            },
          )
        }
      },
    )

    set align(center)
    text(17pt, [#title])

    v(0.5em)

    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 24pt,
      ..authors.map(author => [
        #author.name \
        #author.affiliation \
        #link("mailto:" + author.email)
      ]),
    )
    v(0.8em)
    let _abstract = if lang == "zh" { "摘要" } else { "Abstract" }
    par(justify: false)[
      *#_abstract* \
      #abstract
    ]

    v(1.5em)

    set align(left)
    doc
  }
}

