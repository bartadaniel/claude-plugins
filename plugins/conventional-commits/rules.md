# Conventional Commits

All commit messages MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

## Format

```
<type>[(scope)]: <subject>

[body]

[footer(s)]
```

- **Subject line**: imperative mood, lowercase, no period, max 72 characters
- **Body**: wrap at 100 characters per line, separated from subject by a blank line
- **Footer**: token-based (e.g., `BREAKING CHANGE:`, `Refs:`, `Closes:`)

## Allowed Types

| Type | When to use |
|------|-------------|
| `feat` | A new feature visible to the end user |
| `fix` | A bug fix |
| `docs` | Documentation-only changes |
| `style` | Formatting, whitespace, semicolons — no logic change |
| `refactor` | Code restructuring that neither fixes a bug nor adds a feature |
| `perf` | A performance improvement |
| `test` | Adding or updating tests — no production code change |
| `build` | Changes to the build system or external dependencies |
| `ci` | CI/CD configuration and scripts |
| `chore` | Maintenance tasks that don't fit above (release config, .gitignore, etc.) |
| `revert` | Reverts a previous commit — reference the reverted SHA in the body |

## Scope

Optional. Lowercase, describes the area affected. Examples: `auth`, `api`, `ui`, `db`, `config`.

```
feat(auth): add OAuth2 login flow
fix(api): handle null response from /users endpoint
```

## Breaking Changes

Mark with `!` after the type/scope **and** include a `BREAKING CHANGE:` footer:

```
feat(api)!: change /users response format to paginated

BREAKING CHANGE: GET /users now returns { data: [], meta: { page, total } }
instead of a flat array. All clients must update their response parsing.
```

## Writing Commit Bodies — The Why Matters

Since commits are AI-generated, the body should capture context that the diff alone cannot convey. The subject line says *what* changed — the body must explain *why*.

### Always include

- **The reasoning**: Why was this change necessary? What problem does it solve?
- **The approach**: If the approach isn't obvious from the diff, explain the choice.

### When applicable

- **Alternatives considered**: What else was tried or evaluated, and why it was rejected. This is especially valuable for non-obvious decisions.
- **Root cause** (for fixes): Describe the underlying cause, not just the symptom. "The retry loop never reset the counter" is better than "fix retry logic".
- **Motivation** (for refactors): Why now? Performance? Readability? Preparing for an upcoming feature?

### Avoid

- Restating the diff: "Change X to Y in file Z" — we can see that.
- Filler phrases: "This commit updates..." — just state the reason.
- Empty bodies on non-trivial changes: If the subject line alone doesn't tell the full story, add a body.

## Examples

### Good

```
feat(auth): add session timeout after 30 minutes of inactivity

Users reported staying logged in indefinitely on shared machines,
creating a security risk. A 30-minute idle timeout balances security
with usability — shorter timeouts caused friction during testing.

The timeout resets on any API call, not just page navigation, so
background polling keeps active sessions alive.

Closes #142
```

```
fix(api): prevent duplicate webhook deliveries on retry

The webhook dispatcher retried failed deliveries but didn't check
whether the first attempt actually succeeded with a delayed response.
This caused merchants to process the same event twice.

Root cause: the retry scheduler read from a stale snapshot of the
delivery log. Switching to a real-time query against the write replica
eliminates the race condition.

Considered adding idempotency keys on the merchant side, but that
pushes the fix onto every consumer — solving it at the source is
cleaner.
```

```
refactor(db): extract query builder from repository classes

Three repositories duplicated the same WHERE-clause construction with
slight variations. Extracting a shared query builder reduces ~120 lines
of duplication and makes it straightforward to add filtering for the
upcoming advanced search feature.
```

```
chore: update .gitignore for IDE artifacts
```

### Bad

```
fix: fix bug
```
*No context — which bug? Why did it happen?*

```
updated the login page
```
*Missing type, not imperative, no explanation.*

```
feat(auth): add OAuth2 login flow

This commit adds OAuth2 login flow to the authentication module.
The changes include updating the auth controller and adding new routes.
```
*The body just restates the diff — says nothing about why OAuth2 was chosen or what it replaces.*
