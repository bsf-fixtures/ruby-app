# Fundamentals — ruby-app

## Dominant patterns

For each recurring concern, the pattern most of this codebase already uses.
Follow it rather than introducing a second way of doing the same thing.

| Concern | The pattern here | Source |
| --- | --- | --- |
| Reporting that an operation cannot proceed | Raise, never return a falsey value. `Calendar#book` raises `Calendar::Conflict`; the comment above it gives the reason — "a caller that ignores a false is left believing the room is booked, and nothing downstream can tell". | `lib/scheduling/calendar.rb:17-23`; held by `test_an_overlap_raises_naming_the_clash` |
| Rejecting an invalid value | Raise `ArgumentError` from `initialize`, so an invalid object cannot come into existence and no later code has to re-check it. | `lib/scheduling/slot.rb:11`; held by `test_a_slot_must_end_after_it_starts` |
| Asking a question vs. performing an action | A predicate (`free?`) answers without raising; the action (`book`) raises. The two live side by side so a caller can choose. | `lib/scheduling/calendar.rb:21-31` |
| Time ranges | Half-open, always: `starts_at < other.ends_at && other.starts_at < ends_at`. A slot ending at 10:00 does not overlap one starting at 10:00. | `lib/scheduling/slot.rb:4-6,18` |
| Changing a collection | Rebuild and reassign rather than mutate: `@slots = (slots + [slot]).sort_by(&:starts_at)`. `slots` is kept sorted by start as an invariant, which is what makes `gaps` work. | `lib/scheduling/calendar.rb:25` |
| Deriving a view of the data | A query method that returns new value objects rather than exposing internals for the caller to assemble: `gaps` returns `Slot`s. | `lib/scheduling/calendar.rb:37-45` |
| Where an error class lives | Nested in the class that raises it (`Calendar::Conflict`), not in a separate errors file. | `lib/scheduling/calendar.rb:8` |
| Class documentation | Every class carries a comment saying *why it exists*, not what it does. `Style/Documentation` is explicitly enabled so this is also checked. | `.rubocop.yml`; `lib/scheduling/slot.rb:4-6`, `lib/scheduling/calendar.rb:6` |
| File header | `# frozen_string_literal: true` on line 1 of every `.rb` file, including the `Gemfile`. | all four Ruby files |
| String literals | Double quotes throughout, enforced by `Style/StringLiterals: EnforcedStyle: double_quotes`, which the config says was chosen to match the code that already existed. | `.rubocop.yml` |
| Loading another file | `require_relative` with a path relative to the file, never a load-path `require`. `-Ilib` is for the caller's benefit, not the library's. | `lib/scheduling/calendar.rb:3`, `test/test_calendar.rb:5` |
| Error message content | Name both parties, using the type's own `to_s`: `"#{slot} clashes with #{clash}"`, where `Slot#to_s` is `HH:MM-HH:MM`. The test asserts on the message, so the format is part of the contract. | `lib/scheduling/calendar.rb:23`, `lib/scheduling/slot.rb:25-27`, `test/test_calendar.rb:36` |
| Test structure | minitest only: a `Minitest::Test` subclass, plain `def test_*` methods, `setup` for the subject, small private-by-convention helpers (`at`, `slot`) to keep each test one idea. No mocks, no stubs, no fixtures, no shared test helper file. | `test/test_calendar.rb` |
| Time values in tests | A fixed date with an explicit zone — `Time.parse("2026-11-20 #{hhmm}:00 UTC")` — behind an `at("09:00")` helper. Never `Time.now`, never a local zone. | `test/test_calendar.rb:8-10` |
| Dependencies | Two, both development tools (minitest, rubocop), both pinned with `~>`. The library code itself requires nothing — not even a stdlib file. | `Gemfile`; no `require` of a gem anywhere in `lib/` |

## Product intent

This is a scheduling library, and the README is explicit about why that
subject was chosen: its rules are about *logic* rather than formatting. The
product is the guarantee, not the API surface.

Two guarantees carry the whole thing, and both are stated in comments next to
the code that provides them:

- **A back-to-back booking is two bookings, not a conflict.** This is what the
  half-open range buys. A closed range makes 09:00–10:00 and 10:00–11:00
  collide, which is the single most common scheduling bug.
- **A conflict cannot be ignored.** `book` raises. A caller that drops the
  result still gets stopped; a caller that wanted to ask first has `free?`.

Where this changes a decision an agent has to make: a change that makes a
conflict *survivable* — returning `false` or `nil`, logging and continuing,
swallowing `Conflict` in a rescue, adding a `force:` flag that skips the
check — is against the intent even if the test suite can be edited until it
passes. If such a change is genuinely wanted, it is a change to the product's
promise and should be argued for as one, not slipped in as a refactor.

The library deliberately does not know what a time *is*. It compares,
subtracts and calls `strftime` on whatever it is handed. Keep it that way
unless there is a reason: it is what lets a caller pass `Time`, `DateTime` or
its own type.

## Taste

Things a reviewer would ask for that no rule states.

- **A comment says why, not what.** Every comment in `lib/` names the bug the
  design prevents or the need the method serves — `gaps` is introduced as
  "the gaps between bookings, which is what a scheduler actually needs". A new
  class comment that restates the class name satisfies `Style/Documentation`
  and misses the entire point of having it enabled.
- **A test is named after the decision it protects, not the method it calls.**
  `test_back_to_back_bookings_do_not_clash`, not `test_overlaps`. Two of the
  five tests carry a comment explaining which reversal they are there to
  catch. A new test should be able to say what breaking it would mean.
- **Methods stay readable in one glance.** The longest, `gaps`, is eight
  lines against a cap of fifteen; most are two or three. The cap is the
  ceiling, not the target.
- **The public surface stays small and earned.** `Calendar` exposes six
  things, each one something a scheduler actually needs. Prefer adding a test
  over adding an accessor, and prefer a method that returns the answer over
  one that exposes the state to compute it.
- **No defensive type checking.** `Slot` never asks whether its endpoints are
  `Time`s; it uses `<`, `-` and `strftime` and lets a wrong type fail loudly.
  Adding `raise TypeError unless starts_at.is_a?(Time)` would narrow the type
  for no gain.
- **No new dependency for something the stdlib or ten lines can do.** The
  library has zero runtime dependencies today and that is a feature of it.
- **Tests build their own data inline.** Five tests and no fixture file; keep
  it that way until a test is genuinely hard to read without one.

## Deliberate exceptions

Places that look like they break a rule and should stay as they are, with the
reason. Without this section, cleanup keeps rediscovering them.

| Place | Looks like | Why it stays |
| --- | --- | --- |
| `.rubocop.yml`, `Style/Documentation: Enabled: true` | Redundant — the cop is on by default for this RuboCop version. | Stated on purpose. The README says it is there "so the rule pack's baseline has something real to hold". Removing it as dead config removes a deliberate statement of the repo's standard. |
| `.rubocop.yml`, `Metrics/MethodLength: Max: 15` | A loosened default (10). | A considered ceiling for this codebase, and nothing is near it — the longest method is eight lines. Tightening it back would be churn, not improvement. |
| `.rubocop.yml`, `Style/StringLiterals: double_quotes` | An arbitrary style pick. | The config carries its own reason: "The code uses double quotes throughout; keep the style it already has." Consistency with existing code was the argument; flipping it would rewrite every file. |
| `Calendar#gaps` building an edge list and using `each_slice(2)` | Clever for its own sake; an explicit loop over pairs would be more obvious. | The edge list is exactly the sequence of boundaries, so slicing it in twos *is* the list of gaps, and `filter_map` drops the zero-length ones. `test_gaps_between_bookings` pins the behaviour, including the leading and trailing gaps. Rewrite it only with a test that fails first. |
| `Gemfile.lock` in `.gitignore` | Wrong for an application — lockfiles are normally committed. | Normal for a library: resolving afresh within the `~>` constraints is what CI does (`bundler-cache: true` builds its own lock), and it is how a library finds out early that a new minor of a dependency broke it. **Not stated anywhere in the repo** — the `.gitignore` line is the only evidence, so treat this as an observation rather than a documented decision. |
| `Calendar#slots` as a plain `attr_reader` returning the live array | A caller could mutate the internal array and bypass `book` entirely. | **No reason is recorded for this anywhere**, and setup is not inventing one. `book` never mutates in place, so the array a caller holds is a snapshot in practice, and the tests do not cover mutation through the reader. Worth a deliberate decision — freeze it, dup it, or write down that it is fine — rather than being quietly changed either way. |
