# GitWerk

## Setup ssh server

```
mkdir -p priv/dev/ssh_keys
cd priv/dev/ssh_keys
ssh-keygen -b 256 -t ecdsa -f ssh_host_ecdsa_key
ssh-keygen -b 1024 -t dsa -f ssh_host_dsa_key
ssh-keygen -b 2048 -t rsa -f ssh_host_rsa_key
```

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
ssh -T -p 8989 git@localhost
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

