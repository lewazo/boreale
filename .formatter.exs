# Used by "mix format"
locals_without_parens = [plug: 1, plug: 2]

[
  locals_without_parens: locals_without_parens,
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
