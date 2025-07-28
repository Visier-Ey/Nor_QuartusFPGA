//! FUNCTIONS AND MACROS

#let blink(term) = box[✨ #term ✨]

#let moon-logo(spect, baseline) = box(
  baseline: baseline,
  image("../assets/moon-smooth.svg", width: spect, height: spect),
)


#let warning(content) = {
  box(
    stroke: (left: 7pt + rgb("F61359")),
    inset: (y: 1em, x: 1.3em),
    grid(
      columns: (0.5em, 95%),
      gutter: 2.7em,
      image("../assets/warning.png", width: 0.8cm), align(horizon, text(content)),
    ),
  )
}

#let info(content) = {
  box(
    stroke: (left: 7pt + rgb("FFC13D")),
    inset: (y: 0.5em, x: 1.3em),
    grid(
      columns: (0.2em, 95%),
      gutter: 3em,
      image("../assets/info.png", width: 0.8cm), align(horizon, text(content)),
    ),
  )
}

#let comment(theme: "blue-theme", content) = {
  box(
    stroke: (left: 7pt + rgb("999999")),
    inset: (y: 0.5em, x: 1.3em),
    grid(
      columns: (1em, 95%),
      gutter: 2.3em,
      image("../assets/comment.png", width: 0.8cm), align(horizon, text(content)),
    ),
  )
}
