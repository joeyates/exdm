# exdm - Elixir Deployment Manager

exdm is intended to complement [exrm](https://hexdocs.pm/exrm/extra-getting-started.html),
by simplifying deployment of releases.

exdm provides a set of mix tasks to deploy applications, check their status and
start and stop them.

Releases created by exrm are pushed to remote servers and applications can be upgraded.

exdm allows the definition of multiple stages for your appplication, e.g.
`production`, `staging` and `ci`.

# Usage

deps:
...

Add a section to your application config:
```
config :exdm, :production,
  host: "example.com",
  user: "deploy",
  application_path: "/srv/my_app"
```

Build the release using exrm:

```
MIX_ENV=prod mix release
```

```
mix deployment.deploy production
```

This checks the following:
* is a release available of the current version of the application?
* is the applicatiojn running on the remote host?
* if so, is it possible to upgrade from the local release from the current state?
* if not, exdm will try to run the initial deployment.

# Other tasks

```
mix deployment.remote     # prints the version running on the remote host
mix deployment.local      # prints the latest release version built locally
mix deployment.can_deploy # are we ready to deploy?
```
