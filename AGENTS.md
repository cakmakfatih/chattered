# Project conventions

## Go project layout

For Go projects created or changed in this workspace, use the patterns from [golang-standards/project-layout](https://github.com/golang-standards/project-layout): put executable entry points under `cmd/<app>` and private application code under `internal/`. Add optional directories such as `pkg`, `api`, or `deployments` only when the project needs them. This is the user's preferred default for future Go projects as well.
