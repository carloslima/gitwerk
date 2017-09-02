use ExGuard.Config

guard("elixir test", run_on_start: true)
|> command("mix test --color")
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> ignore(~r{deps})
|> notification(:off)

guard("elm test", run_on_start: true)
|> command("elm-test assets/tests/")
|> watch(~r{\.(elm)\z}i)
|> ignore(~r{elm-stuff})
|> notification(:auto)
