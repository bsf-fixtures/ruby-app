# History — ruby-app

Setup wrote this file at the start of the repo's life with the factory, so
most of it is honestly empty. The sources that would normally seed it barely
exist here: the checked-out git history is a single squashed commit
(`b6443c7`, 2026-11-21, "Upgrade the factory to build-software-factory
ecee54e (#7)"), the six pull requests on the repository are the factory's own
bootstrap and upgrade PRs plus the one that added the fixture's code — none
is a product review with corrections to mine — no factory work item has run,
and no mined agent-correction sessions were supplied to this episode. Rather
than invent lessons, the rows below are limited to what is verifiable.

## Lessons

| What happened | What to do instead | Where it came from |
| --- | --- | --- |
| The first attempt to set this factory up measured the sandbox at **static** and its pull request was closed without merging. It was designed against a repository that did not yet contain the application code: PR #6, "Add the fixture's application code", merged at 05:09:33 on 2026-11-21, one second before PR #5 was closed. | Nothing about the Ruby code — this is a lesson about sequencing. Check that `lib/` and `test/` actually hold the subject before concluding there is nothing to build or test. This round reads them and claims `build_and_test`. | PR #5, "Set up the software factory" (closed unmerged 2026-11-21), and PR #6 (merged 2026-11-21) |
| — | **No lessons from the product code itself yet.** Nothing has gone wrong in `lib/` or `test/` that anyone wrote down: no revert, no incident note, no `FIXME` or `TODO` in the product code or its config, no scored factory run. The first real entry should come from a scored run or a human correction, not from setup guessing. | — |

## Problem classes already eliminated

Kept so nobody proposes a rule that exists, and so a regression is
recognisable as one.

| Problem class | How it was eliminated | When |
| --- | --- | --- |
| Back-to-back bookings read as a conflict. A closed time range makes 09:00–10:00 collide with 10:00–11:00, so a room that is fully and correctly booked looks double-booked. | `Scheduling::Slot` is a half-open range: `starts_at < other.ends_at && other.starts_at < ends_at`. The class comment says this is "the bug this type exists to prevent", and `test_back_to_back_bookings_do_not_clash` fails if anyone closes the range. | Present in the code as first committed; the squashed history gives no earlier date. |
| A clash a caller can ignore. A `book` that returns `false` leaves a caller believing the room is held, with nothing downstream able to tell the difference — the room ends up double-booked in the real world while the data looks fine. | `Calendar#book` raises `Calendar::Conflict` naming the slot it clashes with. The reasoning is in the comment above the method; `test_an_overlap_raises_naming_the_clash` holds both the raise and the message naming the other slot. | As above. |
| A slot that ends before, or exactly when, it starts. A zero-length or reversed slot overlaps nothing and quietly books successfully. | `Slot#initialize` raises `ArgumentError` unless `ends_at > starts_at`, so the invalid object never exists for later code to mishandle. `test_a_slot_must_end_after_it_starts` covers both the equal and the reversed case. | As above. |
| A class with no record of why it exists. | `Style/Documentation` is explicitly enabled in `.rubocop.yml` and every class carries a comment giving its reason. The README states this was done deliberately so the rule pack's baseline "has something real to hold". Enforced, so it is a rule rather than a lesson — listed here only so nobody proposes adding the cop again. | As above. |

## Escalations

Work the factory could not finish, and why. A pattern across several of these
is a signal about the factory rather than about the work.

| Work item | Where it stopped | Cause |
| --- | --- | --- |
| — | **None.** This is the factory's first setup on this repo; no work item has run, so nothing has escalated. | — |
