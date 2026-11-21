<!--
  How to build, run, test and verify this app. Written by setup's phase 2,
  with every command tested rather than copied from a README.

  This is the most load-bearing context file: a verifier agent that cannot
  start the app cannot verify anything, and then the factory produces
  confident unverified PRs.
-->

# Runbook — bsf-fixtures/ruby-app

**Read this first: there is no application to build, run or test.** The
repository contains a README, the factory definition under `.factory/` and the
factory's thirty workflows under `.github/workflows/`. Nothing else. Every
command below is empty because there is no command, not because none was
found.

The sandbox manifest records this as `tier: static` with all four commands
`null`. A verifier working here can read and edit files and reason about text;
it cannot observe behaviour. Any claim that something *works* is out of reach
until the repository has code and this file is rewritten by an amendment
episode.

## Build

```bash
# none
```

No build step exists. There is no `Gemfile`, no `Rakefile`, no gemspec, no
`Makefile` and no compiled artifact. `commands.build` in the sandbox manifest
is `null`.

## Run

```bash
# none
```

The app is then at *nowhere*. There is no HTTP entrypoint — no `config.ru`, no
Rails or Sinatra application, no server script under `bin/`. `app_url` in the
sandbox manifest is `null`, so the trial skips its run step and no screenshot
is taken.

## Test

```bash
# none
```

No test framework is declared and no `spec/` or `test/` directory exists.
`commands.test` is `null` rather than a command that would pass without
asserting anything — a green vacuous test command is worse than an honest
absent one, because the gates would believe it.

`.factory/guardrails/coverage.json` already carries `floor_pct: 0`, which is
consistent: there is nothing to cover. Its `diff_min_pct: 80` will start to
bite the moment the first `.rb` file lands, so the change that introduces code
should introduce tests in the same PR.

## Verify

How to see for yourself that the app works, as a developer would:

1. You cannot. There is nothing to start and nothing to look at.
2. What *can* be confirmed by hand, and all it confirms is the environment:
   ```bash
   ruby -v     # ruby 3.3.8 (2025-04-09 revision b200bad6cd) [x86_64-linux-gnu]
   ruby -S bundle -v   # Bundler version 2.5.22
   rake --version      # rake, version 13.3.1
   ```
   These say the Ruby toolchain is on the runner. They say nothing about this
   repository, because this repository has no Ruby in it.
3. The first change that adds a runnable entrypoint must replace this section
   with real steps and open an amendment episode against the sandbox, since
   `capabilities.not_exercised` lists `config.ru`, `app/**`, `lib/**` and
   `bin/**` precisely so that change is caught.

## Seed data

```bash
# none
```

There is no data store to seed and no fixture format to seed it with.

## Commands that change persistent state

These are kept out of the build path on purpose. Each one writes to something
that outlives the process, so running it against the wrong target is the kind
of mistake that cannot be undone by reverting a commit.

| Command | Writes to | Only when |
| --- | --- | --- |
| | | |

None. No migration, no backfill, no publish step and no deploy script exists
in the repository.

## Services this app needs

| Service | How it starts | Reached at |
| --- | --- | --- |
| | | |

None. The sandbox's `services` list is empty, so the trial starts no
containers. No code in the repository opens a database, cache, queue or mail
connection.

## The sandbox's environment

Built from this list, and from nothing else. It does not inherit a
developer's environment and it does not read any `.env` file, because a
documented build command that runs a migration would otherwise migrate
whatever a developer's credentials happen to point at.

| Variable | Value in the sandbox |
| --- | --- |
| | | 

The list is empty. Nothing in the repository reads an environment variable, a
`.env` file, a settings module or a config file — there is no code to do the
reading. The sandbox therefore supplies only `PATH`, `HOME`, `TMPDIR`, `LANG`,
`CI` and `RUNNER_TEMP` (the runner's own base, which `bsf` passes through to
every command), and no application variable at all.

### What the toolchain actually resolves to

Worth recording, because it will matter the moment a `Gemfile` is added:

- `ruby` is `/usr/bin/ruby`, version **3.3.8**, with gems in
  `/var/lib/gems/3.3.0`.
- Bundler **2.5.22** ships with it as a default gem, but there is **no plain
  `bundle` on the system path** — only `/usr/bin/bundle3.3`. The reliable
  invocation is `ruby -S bundle`, which uses whichever `ruby` is first on
  `PATH` and its matching bundler.
- Inside the agent's own container a hostedtoolcache Ruby 4.0.9 shadows
  `bundle` (reporting 4.0.20) while `ruby` stays 3.3.8. That mismatch is an
  artefact of the agent image and will not be present on the trial runner, but
  a command written as a bare `bundle …` is fragile across both. Prefer
  `ruby -S bundle …`.
- `bundle install` in a directory without a `Gemfile` exits **10**
  ("Could not locate Gemfile"), which is why `commands.install` is `null`
  rather than an optimistic `bundle install`.
