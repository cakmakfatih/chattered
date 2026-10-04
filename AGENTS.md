# Project conventions

## Git operations

- Do not perform any Git operation unless the user explicitly requests it. This includes read-only inspection commands such as `git status`, `git log`, and `git diff`, as well as operations such as fetch, checkout, branch, merge, commit, and push.
- Commit only when the user explicitly asks. Never commit or push without explicit user instruction.
- When Git work is authorized, follow Git Flow principles.
- Write all commit messages in English.

## Language and naming

- Write all documentation in English, including README files and other document files.
- Use English for identifiers and names, including variables, functions, types, files, and resources. Follow the casing and formatting conventions established by the project and implementation language.
- Use Turkish only for user-facing language inside the application. Turkish does not apply to identifiers, technical names, documentation, or commit messages.
- Apply Clean Code Architecture naming logic so names communicate meaning and responsibility while remaining consistent with the project's existing language and naming conventions.
- Name functions clearly for the action they perform and the responsibility they own.

## Function design

- Keep functions short, focused, understandable, and limited to a cohesive responsibility.
- Avoid excessive context and unrelated responsibilities. Use engineering judgment rather than a rigid line-count limit.

## Go project layout

For Go projects created or changed in this workspace, use the patterns from [golang-standards/project-layout](https://github.com/golang-standards/project-layout): put executable entry points under `cmd/<app>` and private application code under `internal/`. Add optional directories such as `pkg`, `api`, or `deployments` only when the project needs them. This is the user's preferred default for future Go projects as well.
