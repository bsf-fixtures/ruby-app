# Feature map — ruby-app

A small Ruby library for room scheduling: a half-open time `Slot` and a
per-room `Calendar` that refuses to double-book. It is a Build Software
Factory fixture for the Ruby rule pack (minitest + RuboCop), and it is a
library only — there is no server, no CLI and no executable.

## Feature folders

| Folder | Owns | Depends on |
| --- | --- | --- |
| `lib/scheduling/` | The whole domain, in two files. `slot.rb`: `Scheduling::Slot`, a half-open time range — `overlaps?`, `minutes`, `to_s` as `HH:MM-HH:MM`, and an `ArgumentError` in `initialize` for a slot that does not end after it starts. `calendar.rb`: `Scheduling::Calendar`, one room's bookings — `book` (raises `Calendar::Conflict`), `free?`, `booked_minutes`, `gaps`, and the `Conflict` error class itself. | Nothing. `calendar.rb` requires `slot.rb` by relative path; neither file requires anything from the Ruby stdlib or a gem. Callers supply the time values. |
| `test/` | The minitest suite. One file, `test_calendar.rb`, which loads the library through `require_relative "../lib/scheduling/calendar"` and names the two decisions a change could quietly reverse: back-to-back bookings are not a clash, and an overlap raises rather than returning false. | `lib/scheduling/`, `minitest/autorun`, and stdlib `time` for `Time.parse`. |

## Shared

| Folder | What it is | Rule |
| --- | --- | --- |
| — | **There is no shared folder in this repo.** `lib/scheduling` is the only feature, so nothing has had a second caller yet. Recorded as absent rather than guessed at. | The first thing two features both need gets a new folder under `lib/`, and each feature requires it by relative path — the only import style the repo uses. |
| `.rubocop.yml`, `Gemfile` (repo root) | The toolchain. `Gemfile` pins minitest `~> 5.25` and rubocop `~> 1.69`; `.rubocop.yml` sets `TargetRubyVersion: 3.3`, `NewCops: enable`, `Style/Documentation: Enabled`, `Metrics/MethodLength: Max: 15`, and double-quoted strings. | Changing a lint rule is changing the repo's standard, not a detail of one change. `Gemfile.lock` is not committed (see `.gitignore`). |
| `.github/workflows/ci.yml` | The repo's own CI: `ruby/setup-ruby@v1` at Ruby 3.3, then `bundle exec ruby -Ilib test/test_calendar.rb`, then `bundle exec rubocop`. | The two commands CI runs are the two the sandbox must keep passing. |
| `.factory/`, the `factory-*` workflows, `.playwright/` | The Build Software Factory's own definition, compiled role workflows and guardrails. Not product code. | Changed only through the factory's own processes, never as part of a scheduling change. `.playwright/` is empty and the library has no UI to drive. |

## Where things go

- **A new feature** gets its own folder under `lib/`, alongside `scheduling/`,
  with a file per class and a matching `test/test_<thing>.rb`.
- **Something used by two features** moves to a new folder under `lib/`, and
  not before the second use. One caller is not a shared concern. There is no
  such folder today, so the first one sets the precedent.
- **Nothing in a feature folder imports from another feature folder.** Where
  two features need the same thing, it belongs in shared.

## Not in this repo

- **No application.** No `bin/`, no `exe/`, no server, no CLI, no `main`.
  Nothing here can be started; the library is loaded with `ruby -Ilib`.
  This is why the sandbox tier is `build_and_test` and `app_url` is null.
- **No gemspec and no packaging.** The `Gemfile` declares development
  dependencies only; nothing describes this as a publishable gem, and there is
  no release or deploy step anywhere in the repo.
- **No configuration of any kind.** No `ENV[...]` read, no config file, no
  settings module, no `.env` or example env file — checked across `lib/` and
  `test/`. The sandbox's environment list is correspondingly empty.
- **No persistence, no network, no third party.** A `Calendar` is an in-memory
  array of slots that lives as long as the object. Nothing opens a socket,
  a file or a database.
- **No Rakefile, no test helper, no CI matrix.** One test file, run directly.
- **No `Gemfile.lock`.** It is listed in `.gitignore`, so every install
  resolves afresh within the `~>` constraints.
