# Runbook — ruby-app

Every command below was run in the setup sandbox and its result is reported
as it happened.

## Build

```bash
null
```

There is nothing to build. This is a plain Ruby library: no compiler, no
bundler step, no asset pipeline, no code generation. The sandbox manifest's
`build` command is `null` because that is a fact about the repo, not a gap in
what setup found.

`bundle exec rubocop` was considered for this slot — it is CI's second step —
and deliberately left out. RuboCop is this repo's linter and the factory's
static gate runs it against per-file baselines, which tolerate offenses that
already exist; a raw `bundle exec rubocop` as the build would be a second,
stricter copy of the same check and would disagree with the gate. It is
recorded under `dropped` in the manifest. For the record, it passes here:
`4 files inspected, no offenses detected`.

## Run

```bash
null
```

The app is then at **nowhere — there is no app**. This repo has no `bin/`,
no `exe/`, no server and no CLI entry point. `lib/scheduling` is loaded by a
caller; nothing here starts a process. `app_url` in the manifest is null and
the tier is `build_and_test` for this reason.

## Install

```bash
RB=$(ls -d /opt/hostedtoolcache/Ruby/3.3.*/x64/bin 2>/dev/null | sort -V | tail -1); export PATH="${RB:-$(dirname "$(command -v bundle)")}:$PATH"; bundle config set --local path vendor/bundle && bundle install
```

The README says `bundle install`. Two things were added to make it work on
the runner, both found by running it:

1. **`bundle config set --local path vendor/bundle`.** A bare `bundle install`
   writes to the shared gem home, which is read-only here —
   `Bundler::ReadOnlyFileSystemError ... /opt/hostedtoolcache/Ruby/4.0.9/x64/lib/ruby/gems/4.0.0/cache/ast-2.4.3.gem`.
   Installing into the working copy avoids it. `.bundle/` and `/vendor` are
   both already in `.gitignore`, so this leaves no trace in the repo.
2. **The `PATH` prefix.** On the runner, `ruby` and `bundle` come from
   different Ruby installations: `ruby` is `/usr/bin/ruby` (3.3.8) while
   `bundle` resolves to the tool cache's Ruby 4.0.9. Gems installed by one are
   invisible to the other, and `bundle exec ruby` fails with
   `Bundler::GemNotFound`. The prefix puts a single Ruby's `bin` directory
   first so install and test agree. It prefers a 3.3.x from the tool cache,
   which is the version `.rubocop.yml` targets and the version
   `.github/workflows/ci.yml` pins, and falls back to whichever Ruby owns
   `bundle` if no 3.3 is present. Measured here: Ruby 3.3.13.

Since `Gemfile.lock` is gitignored, this resolves afresh each time. It
resolved to minitest 5.27.0 and rubocop 1.92.3 (16 gems) when setup ran.

## Test

```bash
RB=$(ls -d /opt/hostedtoolcache/Ruby/3.3.*/x64/bin 2>/dev/null | sort -V | tail -1); export PATH="${RB:-$(dirname "$(command -v bundle)")}:$PATH"; bundle exec ruby -Ilib test/test_calendar.rb
```

This is CI's first step, with the same `PATH` prefix as install for the same
reason. Result in the sandbox:

```
5 runs, 8 assertions, 0 failures, 0 errors, 0 skips
```

It takes well under a second. There is no test runner, no `Rakefile` and no
second test file: `test/test_calendar.rb` is the whole suite, and a new test
file has to be named on the command line the same way.

The lint half of CI is `bundle exec rubocop` (same prefix). It is not the
manifest's test command because the static gate owns it, but it is the other
thing a change here has to keep green.

## Verify

How to see for yourself that the library works, as a developer would:

1. `bundle exec ruby -Ilib test/test_calendar.rb` — expect `5 runs, 8
   assertions, 0 failures, 0 errors, 0 skips`. A change that alters behaviour
   and still prints this has not been verified; read which tests cover the
   path you changed.
2. `bundle exec rubocop` — expect `4 files inspected, no offenses detected`.
   `Style/Documentation` is on, so a new class without its "why" comment
   fails here.
3. For a behaviour change, exercise it directly rather than only through the
   suite. There is no app to click, so a console is the equivalent of looking
   at the screen:

   ```bash
   bundle exec ruby -Ilib -rtime -rscheduling/calendar -e '
     at = ->(s) { Time.parse("2026-11-20 #{s}:00 UTC") }
     cal = Scheduling::Calendar.new("Room A")
     cal.book(Scheduling::Slot.new(at["10:00"], at["11:00"]))
     cal.book(Scheduling::Slot.new(at["11:00"], at["12:00"]))   # back-to-back: allowed
     puts cal.booked_minutes                                     # => 120
     puts cal.gaps(at["09:00"], at["17:00"]).map(&:to_s).inspect
     begin
       cal.book(Scheduling::Slot.new(at["10:30"], at["11:30"]))  # overlap: raises
     rescue Scheduling::Calendar::Conflict => e
       puts "Conflict: #{e.message}"
     end'
   ```

   Run with the same `PATH` prefix as above. This was run during setup and
   printed `120`, `["09:00-10:00", "12:00-17:00"]` and
   `Conflict: 10:30-11:30 clashes with 10:00-11:00`.
4. There is nothing to screenshot. A verifier that expects a browser here is
   expecting the wrong thing; see `capabilities.not_exercised` in the
   manifest.

## Seed data

```bash
null
```

There is no seed command and nothing to seed. A `Calendar` starts empty, in
memory, and is discarded with the process. The tests build the slots they
need in `setup` and in each test method.

## Commands that change persistent state

These are kept out of the build path on purpose. Each one writes to something
that outlives the process, so running it against the wrong target is the kind
of mistake that cannot be undone by reverting a commit.

| Command | Writes to | Only when |
| --- | --- | --- |
| — | **None found.** Nothing in this repo writes to a database, a file, an object store or a remote service. `bundle install` writes only to `vendor/bundle` and `.bundle/` in the working copy, both gitignored and both safe to delete. | — |

## Services this app needs

| Service | How it starts | Reached at |
| --- | --- | --- |
| — | **None.** No database, cache, queue, mail catcher or third-party API. The manifest's `services` and `stubs` lists are empty because the library opens no connections at all. | — |

## The sandbox's environment

Built from this list, and from nothing else. It does not inherit a
developer's environment and it does not read any `.env` file, because a
documented build command that runs a migration would otherwise migrate
whatever a developer's credentials happen to point at.

| Variable | Value in the sandbox |
| --- | --- |
| — | **The list is empty.** Searched `lib/` and `test/` for `ENV[`, `ENV.fetch`, config files and settings modules, and found none: no Ruby file in this repo reads a single environment variable. The sandbox therefore declares no variables, and the only environment the commands get is the shell baseline the runner always provides (`PATH`, `HOME`, `TMPDIR`, `LANG`, `CI`, `RUNNER_TEMP`), which is what makes `ruby` and `bundle` findable. |
