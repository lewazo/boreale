<div align="center">
  <img src="logo.svg" width="150" />
  <p>
    <strong>A very lightweight authentication service for Traefik</strong>
  </p>
</div>

# Boréale
Boréale is a tiny and simple self-hosted service to handle forward authentication for services behind [Traefik reverse proxy](https://github.com/containous/traefik).

## Features
* Very lightweight, less than 50 MB.
* User can use a custom login page.
* SSO for all subdomains.
* Has no external dependencies.
* Easy management through the Boréale CLI.
* Secure and encrypted cookie.
* Easy to deploy.

## Why?
Traefik currently supports some authentication schemes like basic auth and digest. While these works great, they are very limited, non-customizable and requires to log in each time you restart your browser.

There exists many services similar to Boréale, but they either rely on external services like Google OAuth, LDAP, keycloak, etc, or pack many features that are more suitable for a large organization.

The main goal of Boréale is to have a tiny self-contained solution that is more appropriate for a home server usage.

### Alternatives
* [Authelia](https://github.com/clems4ever/authelia) If you are looking for a complete solution for organizations.

* [Traefik Forward Auth](https://github.com/thomseddon/traefik-forward-auth) If you are looking for a Google OAuth-based authentication.

## Getting Started
The recommended way of deploying Boréale is through the official Docker image.

Pass all [required environment variables](#environment-variables) with the `-e` option or add them to a `.env` file as shown [in the examples](examples/).

Mount a volume for the `data` directory, which is where the Boréale configurations will live in on the host.

You can also use `docker compose` with the `docker-compose.yml` [example provided here](examples/).

```
docker run \
  --name=boreale \
  --env-file <path to .env file> \
  -p 5252:4000 \
  -v <path to data/ dir>:/opt/app/data \
  lewazo/boreale
```


## Configuration
Most of the Boréale configuration is done through its CLI. To use the CLI, follow the instructions below depending on your environement.

#### docker compose
When using docker compose, simply run `docker compose exec boreale bin/boreale-cli` in the same directory as your `docker-compose.yml` file.

#### Docker CLI
When using the Docker CLI, you first need to get the container's ID. Run `docker ps` and find the container running the `lewazo/boreale` image. Then, run `docker exec -it <CONTAINER ID> bin/boreale-cli`.


### Traefik
In order for Traefik to forward the authentication to Boréale, there are some configurations that needs to be done.

In the following snippets, edit `127.0.0.1` for the IP of the host that runs Boréale. Match the port with the one forwarded to the container.

We use `insecureSkipVerify = true` so Traefik can trust our self-signed certificate. More info on that [here](#tls).

#### For Traefik version below 2.0
In your `traefik.toml`, add the following lines under `[entryPoints.https.tls]`.
```
[entryPoints.https.auth.forward]
    address = "https://127.0.0.1:5252"
    [entryPoints.https.auth.forward.tls]
      insecureSkipVerify = true
```

#### For Traefik version 2.0 and above
In your dynamic configuration file, define a middleware for Boréale like the following :

**Note :** Traefik v2.0 now allows the use of the YAML file format. The following configuration uses the YAML format because in my opinion it is easier than TOML to use. You can still use TOML if you wish.

```
http:
  middlewares:
    boreale:
      forwardAuth:
        address: "https://127.0.0.1:5252"
        tls:
          insecureSkipVerify: true
```

Then add the middleware to all the routers you wish to guard with Boréale. If you use a configuration with labels, then simply add this label to your routers `"traefik.http.routers.<router name>.middlewares=boreale@file"`.

### SSO
SSO (Single sign-on) can be achieved using the `domain` cookie attribute. If your services are setup by subdomains like `service1.domain.tld`, `service2.domain.tld`, then you can use the SSO feature. If you use completely different domains like `service1-domain.tld` and `service2-domain.tld` then this won't work because of the `same origin` policy.

To enable SSO, set the `SSO_DOMAIN_NAME` environment variable to your root domain, e.g., `domain.tld`. This will make all `*.domain.tld` **and** `domain.tld` requests share the same cookie. So a user only has to login to one service. The user will then be authentified on every other services.

Not setting the variable will disable SSO.

### Authorized users
An authorized user is a user who's allowed to log in and access all the web services behind Traefik.

To list all authorized users, use the CLI's `users` command.

To add a new user, use the CLI's `users add` command.

To delete a user, use the CLI's `users remove` command.

### Public domains
**Note:** Starting with Traefik v2.0, adding public domains isn't necessary anymore because we can choose which routers forwards the auth to Boréale by adding or not the middleware to routers. For Traefik v1.x, this isn't possible because the configuration is global; all requests are forwarded to Boréale. Public domains are the only way to have a 'whitelist' for those versions.

A public domain is a FQDN that is meant to access a public server, i.e., it shouldn't ask the user to authenticate when visiting this domain. This acts as a kind of whitelist for your domains.

To list all public domains, use the CLI's `domains` command.

To add a new public domain, use the CLI's `domains add` command.

To delete a public domain, use the CLI's `domains remove` command.

### Environment variables
These are the environment variables that should be set in your `.env` file or set in your environment.

| Variable          | Description                                            | Default                | Optional? |
|-------------------|--------------------------------------------------------|------------------------|-----------|
| COOKIE_NAME       | The name for the authentication cookie                 | _boreale_auth          | Optional  |
| ENCRYPTION_SALT   | The key used for encrypting the cookie                 | *none*                 | Required  |
| GID               | The group ID of your user on the host                  | 9001                   | Optional  |
| PAGE_TITLE        | The title of the login page                            | Boréale Authentication | Optional  |
| PORT              | The listening HTTPS port (OTP release only)            | 4000                   | Optional  |
| SECRET_KEY_BASE   | The key used for encryption (Must be 64 bytes long)    | *none*                 | Required  |
| SIGNING_SALT      | The key used for signing the cookie                    | *none*                 | Required  |
| SSO_DOMAIN_NAME   | The root domain name. Check [here for more info](#sso) | *none*                 | Optional  |
| UID               | The user ID of your user on the host                   | 9001                   | Optional  |

## Customization
Boréale ships with a default login form, but using your own is very easy.

Simply add a `login.html` and `login.css` inside the `data/` directory and it will be automatically used. The only constraints is to have `username` and `password` inputs and a form with the id `form`. Take a look at the [examples here](examples/) to see the code for the default login form. Make sure to set the `UID` and `GID` variables as the same as your host's user so that the container can read the files. You can run the `id` command on your host to get the uid and gid.

The following screenshot shows the default login form.
![Boréale](screenshot.png)

## Security
### TLS
Boréale is meant to be accessed directly by forwarding the auth. As such, you **should not** add it as a backend in Traefik, i.e., you should not have a `boreale.yourdomain.tld` or anything.

With this premise in mind, Boréale automatically creates a self-signed certificate in order to provide a complete HTTPS connection between Traefik and Boréale. This allows the server to set a `secure` cookie on the browser.

Since Boréale is only accessed through Traefik's authentication, using a self-signed certificate is perfectly fine if you trust your private network.

### HSTS
To protect your services from cookie hijacking and protocol downgrade attacks, you should have HSTS enabled. Since Traefik is the one that's terminating the connection, HSTS should be enabled on it rather than on Boréale.

## License
The source code and binaries of Boréale is subject to the [MIT License]().

The above logo is made by [perdanakun](https://www.iconfinder.com/perdanakun) and is available [here](https://www.iconfinder.com/icons/3405132/camp_forest_holidays_jungle_summer_vacation_icon) and subject to the [Creative Commons BY 3.0](https://creativecommons.org/licenses/by/3.0/) license.
