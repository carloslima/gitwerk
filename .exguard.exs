use ExGuard.Config

guard("elixir test", run_on_start: true)
|> command("mix test --color --stale")
|> watch({~r{lib/(?<lib_dir>.+_web)/(?<dir>.+)/(?<file>.+).ex$}i, fn m -> "test/#{m["lib_dir"]}/#{m["dir"]}/#{m["file"]}_test.exs" end})
|> watch(~r{\.(erl|ex|exs|eex|xrl|yrl)\z}i)
|> ignore(~r{deps})
|> notification(:off)

guard("elm test", run_on_start: true)
|> command("elm-app assets/elm-app/")
|> watch(~r{\.(elm)\z}i)
|> ignore(~r{elm-stuff})
|> notification(:auto)
