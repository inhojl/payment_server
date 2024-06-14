[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}", "priv/*/seeds.exs"],
  locals_without_parens: [
    # Absinthe-specific functions
    arg: 2,
    # Absinthe-specific functions
    resolve: 1,
    middleware: 1
  ],
  export: [
    locals_without_parens: [
      # Absinthe-specific functions
      arg: 2,
      # Absinthe-specific functions
      resolve: 1,
      middleware: 1
    ]
  ]
]
