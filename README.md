# GitWerk

## Development on Docker
```
touch assets/js/main.js
docker-compose run gitwerk bash
git@0da4aa9be510:~/gitwerk$ mix ecto.create && mix ecto.migrate
git@0da4aa9be510:~/gitwerk$ cd assets && npm install
docker-compose up
```

you can connect to ssh using
```
ssh -T -p 2222 git@localhost
```

and visit the main ui using [`localhost:3000`](http://localhost:3000) and api using
[`localhost:4000`](http://localhost:4000)


and then follow the normal setup

## Development setup
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

