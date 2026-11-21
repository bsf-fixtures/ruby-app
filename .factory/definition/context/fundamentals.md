<!--
  The conventions no check enforces. Everything here is something a script
  could not decide, which is why it is prose.

  The bar for a line in this file: it has to be a judgement. If a static rule
  could catch it, it belongs in .factory/guardrails/ instead, because a rule
  is reproducible and prose is something agents argue with.

  Each line carries where it came from, so a line nobody can justify can be
  removed later.
-->

# Fundamentals — bsf-fixtures/ruby-app

## Dominant patterns

For each recurring concern, the pattern most of this codebase already uses.
Follow it rather than introducing a second way of doing the same thing.

| Concern | The pattern here | Source |
| --- | --- | --- |
| | | |

The table is empty and should stay empty until there is code. A dominant
pattern is an observation about what a codebase already does most often; this
codebase contains no application file, so every row would be a preference
imported from somewhere else and dressed up as a finding. There is not one
`.rb` file to generalise from.

The first few changes that add code are therefore unusually consequential:
whatever they do becomes the dominant pattern by default. The gardener and the
scheduled review should fill this table from the code once it exists, not
before.

## Product intent

What this product is trying to be, where that would change a decision an
agent has to make.

Everything known about intent comes from two lines of README — "# ruby-app" and
"Build Software Factory: Fixture of a Ruby App to install factory on" — and the
repository's name and owner (`bsf-fixtures`). Read literally, that says this is
a **fixture**: a repository that exists so the Build Software Factory can be
installed onto it and exercised. It names Ruby as the intended language and
does not say what the app is for.

There is no product brief, no issue, no design doc and no commit touching
application code (the only commit on `main`, `1ff638c`, upgrades the factory
itself). So:

- **Ruby is the stated language.** It is the one genuine constraint available,
  and `ruby 3.3.8` is what the runner provides.
- **What the app does is undecided.** No agent should infer a domain, a
  framework, a persistence choice or an HTTP surface from the name
  "ruby-app". A specification for this repository has to come from a human or
  from an issue, not from this file.
- **Where a decision cannot be deferred,** state the assumption in the PR
  rather than burying it, and expect it to become binding — see the note about
  dominant patterns above.

## Taste

Things a reviewer would ask for that no rule states.

Nothing can be stated here from evidence yet; there is no code, no PR against
application code and no review history to read. One observation does carry over
from the repository as it stands, because it was true of the setup work itself:

- **An absent thing is recorded as absent, not guessed at.** The sandbox
  manifest's commands are `null` and its `env` list is empty because this repo
  genuinely has none, and the schema distinguishes that from "the factory does
  not know". When something is missing, say so and say how you checked. The
  temptation in an empty repository is to write a command that passes
  vacuously; that produces a green gate over nothing. (Source: setup's own
  episode, round 1 — a guarded `bundle install` would have had the trial
  certify this repository as `build_and_test`, and was rejected for that
  reason.)

## Deliberate exceptions

Places that look like they break a rule and should stay as they are, with the
reason. Without this section, cleanup keeps rediscovering them.

| Place | Looks like | Why it stays |
| --- | --- | --- |
| `.factory/bin/runner.tgz` and `.factory/bin/bsf` | A binary blob and a shell script checked into the repository, with no source alongside and no linter covering them. | Deliberate. The runner is packed so that no linter, formatter or type checker in this repository reads it — the launcher script says so in its own header. It is replaced wholesale by a factory upgrade and must never be edited in place. |
| `.github/workflows/*.lock.yml` | Large generated YAML committed next to its source, duplicating it. | Deliberate. Each `factory-role-*.md` is the source and `gh aw compile` produces the matching `.lock.yml`; both must be committed for Actions to run them. `bsf audit` reports a lock file that has drifted from its source, so hand-editing a lock file is the failure mode, not committing it. |
| `.factory/guardrails/baselines.json` with an empty `rules` object, and `coverage.json` with `floor_pct: 0` | Guardrails configured to enforce nothing. | Correct for now: there is no linter configured and no code to cover, so there is nothing to baseline. These tighten as code arrives (`diff_min_pct` is already 80). Lowering them *later*, once they hold real numbers, is exactly what Gate 1 treats as weakening. |
