<div align="center">
  <img src="logo.svg" width="150" />
  <p>
    <strong>A very lightweight authentication service for Traefik</strong>
  </p>
</div>

# Boréale
Boréale is a tiny and simple self-hosted service to handle forward authentication for services behind [Traefik reverse proxy](https://github.com/containous/traefik).

## Features
* Very lightweight, less than 60mb.
* User can use a custom login page.
* Has no external dependencies.
* Easy management through the Boréale CLI.
* Secure and encrypted cookie.
* Easy to deploy.

## Why?
Traefik currently supports some authentication schemes like basic auth and digest. While these works great, they are very limited, non-customizable and requires to log in each time you restart your browser.

There exists many services similar to Boréale, but they either rely on external services like Google OAuth, LDAP, keycloak, etc, or pack many features that are more suitable for a large organization.

The main goal of Boréale is to have a tiny self-contained solution that is more appropriate for a home server usage.

### Alternatives
* [Authelia](https://github.com/clems4ever/authelia) If you are looking of a complete solution for organizations.

* [Traefik Forward Auth](https://github.com/thomseddon/traefik-forward-auth) If you are looking for a Google OAuth-based authentication.

## Getting Started
### OTP Release
Boréale is written in Elixir and compiled using Distillery. This allows for self-contained executable (named OTP releases) that can be run anywhere, without relying on the Elixir and Erlang environements.

As such, you can simply download the release from [GitHub releases](https://github.com/lewazo/boreale/releases) and directly run it.

To start it, simply run `./boreale foreground`

To start it in a background processs, simply run `./boreale start`

**Note:** Make sure all required environment variables are set before launching the app. You can see a list of [all the variables here](#environment-variables). How the env variables are set is entirely up to you.

### Docker
While the OTP release is nice and very easy to use, it has the downside of needing to be compiled on an environment similar to the target environment. Currently, I only provide binaries compiled on Ubuntu 18.04 and MacOS Mojave.

This is why the recommended method for deploying Boréale is through Docker. Docker still uses an OTP release, but the release is actually compiled in the image build process. This has the advantage of having the same environment for running and compiling the release. The overall size is still very small, currently sitting at 58mb.

#### docker-compose
The easiest way to get started with the Docker release is using docker-compose. First, create a directory for the Boréale configurations to live in. It can be anywhere. Since I use an unRAID system, I put mine with my other docker applications in `/mnt/user/appdata`.

So inside `/mnt/user/appdata/boreale`, place the `.env` and `docker-compose.yml` file from the [examples here](examples/).

Create a `data` directory inside the previous directory for the docker volume. For me that would be `/mnt/user/appdata/boreale/data`. You can name it however you want as long as the correct name is set in the `docker-compose.yml` file.

Run `docker-compose up` to launch Boréale.

#### docker CLI
Of course using docker-compose is optional. You can use any containers manager you wish. Here's an example on how to run it directly from the docker CLI.

```
docker run \
  --name=boreale \
  --env-file <path to .env> \
  -p 5252:4000 \
  -v <path to data>:/opt/app/data \
  lewazo/boreale
```
### Environment variables
These are the environment variables that should be set in your `.env` file or set in your environment.

| Variable          | Description                              |
|-------------------|------------------------------------------|
| SECRET_KEY_BASE   | A key used for encryption                |
| COOKIE_NAME       | The name for the auth cookie             |
| SIGNING_SALT      | A key used for signing the cookie        |
| ENCRYPTION_SALT   | A key used for encrypting the cookie     |
| PAGE_TITLE        | The title of the login page              |

## Configuration
Most of the Boréale configuration is done through its CLI. To use the CLI, follow the instructions below depending on your environement.

#### OTP Release
When using the OTP release, simply run `./boreale cli` to access the CLI.

#### docker-compose
When using docker-compose, simply run `docker-compose exec boreale bin/boreale cli` in the same directory as your `.env` and `docker-compose.yml` file.

#### Docker CLI
When using the Docker CLI, you first need to get the container's ID. Run `docker ps` and find the container that has the `boreale:latest` image. Then, run `docker exec -it <CONTAINER ID> bin/boreale cli`.

### Traefik
In order for Traefik to forward the authentication to Boréale, there are some configurations that needs to be done.

In your `traefik.toml`, add the following lines under `[entryPoints.https.tls]`.
```
[entryPoints.https.auth.forward]
    address = "https://127.0.0.1:5252"
    [entryPoints.https.auth.forward.tls]
      insecureSkipVerify = true
```

Edit `127.0.0.1` for the IP of the host that runs Boréale. Match the port with the one defined in your `docker-compose.yml` or equivalent.

We use `insecureSkiVerify = true` so Traefik can trust our self-signed certificate. More info on that [here](#tls).

### Authorized users
An authorized user is a user who's allowed to log in and access all the web services behind Traefik.

To list all authorized users, use the CLI's `users` command.

To add a new user, use the CLI's `users add` command.

To delete a user, use the CLI's `users remove` command.

### Public domains
A public domain is a FQDN that is meant to access a public server. ie. it shouldn't ask for any authentication when visiting this domain.

To list all public domains, use the CLI's `domains` command.

To add a new public domain, use the CLI's `domains add` command.

To delete a public domain, use the CLI's `domains remove` command.

## Customization
Boréale ships with a default login form, but using your own is very easy.

Simply add a `login.html` and `login.css` inside the `data/` directory and it will be automatically used. The only constraints is to have `username` and `password` inputs and a form with the id `form`. Take a look at the [examples here](examples/) to see the code for the default login form.

The following screenshot shows the default login form.
![Boréale](screenshot.png)

## Security
### TLS
Boréale is meant to be accessed directly by forwarding the auth. As such, you **should not** add it as a backend in Traefik. ie. You should not have a `boreale.yourdomain.tld` or anything.

With this premise in mind, Boréale automatically creates a self-signed certificate in order to provide a complete HTTPS connection between Traefik and Boréale. This allows the server to set a `secure` cookie on the browser.

Since Boréale is only accessed through Traefik's authentication, using a self-signed certificate is perfectly fine if you trust your private network.

### HSTS
To protect your services from cookie hijacking and protocol downgrade attacks, you should have HSTS enabled. Since Traefik is the one that's terminating the connection, HSTS should be enabled on it rather than on Boréale.

## License
The source code and binaries of Boréale is subject to the [MIT License]().

The above logo is made by [perdanakun](https://www.iconfinder.com/perdanakun) and is available [here](https://www.iconfinder.com/icons/3405132/camp_forest_holidays_jungle_summer_vacation_icon) and subject to the [Creative Commons BY 3.0](https://creativecommons.org/licenses/by/3.0/) license.
