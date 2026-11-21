<!--
  What has gone wrong before, and what was learned. Seeded by setup from the
  mined corrections, then added to by the scheduled review.

  This file is for failures whose lesson could not be turned into a check. A
  correction that became a rule does not belong here: the rule is the record,
  and repeating it in prose means two things to keep in step.
-->

# History — bsf-fixtures/ruby-app

Nothing has gone wrong here yet, because nothing has been built here yet. All
three tables are empty, and each one says below what was actually checked to
establish that — an empty table that was never looked into is indistinguishable
from an empty table that was.

## Lessons

| What happened | What to do instead | Where it came from |
| --- | --- | --- |
| | | |

No lessons to seed. `.factory/guardrails/candidates.json` holds
`{"schema": "candidates/1", "candidates": []}` — no corrections have been
mined, so there is no record of a human correcting an agent in this repository.
There is also no application code whose past bugs could be read from history:
`main` has a single commit, `1ff638c`, which upgrades the factory itself.

## Problem classes already eliminated

Kept so nobody proposes a rule that exists, and so a regression is
recognisable as one.

| Problem class | How it was eliminated | When |
| --- | --- | --- |
| | | |

None. `.factory/guardrails/baselines.json` has an empty `rules` object, so no
static rule has ever been enforced here and nothing has been driven to zero.
`coverage.json` sits at `floor_pct: 0`, which reflects having no code rather
than having eliminated untested code.

## Escalations

Work the factory could not finish, and why. A pattern across several of these
is a signal about the factory rather than about the work.

| Work item | Where it stopped | Cause |
| --- | --- | --- |
| | | |

None. The factory has just been installed; no work item has been dispatched, so
there is no run to have escalated.

## What the first entries here are likely to be

Not history — a note for whoever reads this file next, to be deleted once there
are real rows above. The repository has no code, no tests and no linter, so the
sandbox is `tier: static` and verification cannot observe behaviour. The
foreseeable first escalations are changes that run into exactly that: a change
adding a `Gemfile`, a change adding tests, or a change adding an HTTP
entrypoint. Each of those paths is already named in the sandbox manifest's
`capabilities.not_exercised`, so the expected outcome is an amendment episode
that extends the sandbox — not a stuck run. If one of them *does* get stuck
instead, that is a signal about the amendment path and belongs in the
escalations table above.
