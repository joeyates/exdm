# exdm - Elixir Deployment Manager

[![Build Status](https://api.travis-ci.org/joeyates/exdm.svg)][Continuous Integration]
[![Hex.pm Version](http://img.shields.io/hexpm/v/exdm.svg)][Hex Package]

[Source Code]: https://github.com/joeyates/exdm "Source code at GitHub"
[Continuous Integration]: http://travis-ci.org/joeyates/exdm "Build status by Travis-CI"
[Hex Package]: https://hex.pm/packages/exdm "Hex Package"

exdm is intended to complement [exrm], by simplifying deployment of releases.


It provides a set of mix tasks to deploy applications, check their status and
start and stop them.

Releases created by exrm are pushed to remote servers and applications can be upgraded.

exdm allows the definition of multiple stages for your application, e.g.
`production`, `staging` and `ci`.

[exrm]: https://hexdocs.pm/exrm/extra-getting-started.html "exrm Documentation"

# Usage

Build the release using [exrm]:

```
MIX_ENV=prod mix release
```

Deploy:

```
mix deployment.deploy production
```

# Configuration

Add exdm to your deps in `mix.exs`:

```
defp deps do
  [{:exdm, "~> 0.0.1"}]
end
```

Add a section to your application config:
```
config :exdm, :production,
  host: "example.com",
  user: "deploy",
  application_path: "/srv/my_app"
```

# Other tasks

```
mix deployment.local              # prints the latest release version built locally
mix deployment.remote {stage}     # prints the version running on the remote host
mix deployment.can_deploy {stage} # are we ready to deploy?
mix deployment.start {stage}      # start the application
mix deployment.stop {stage}       # stop the application
mix deployment.is_running {stage} # prints yes/no/error
```

# exdm Development

## Tests

exdm's tests use the 'espec' library.

Run tests:
```
mix espec
```
