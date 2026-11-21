# ruby-app

Build Software Factory fixture: a small Ruby library with minitest and
RuboCop, for the Ruby rule pack.

The subject is scheduling, chosen because its rules are about *logic* rather
than formatting: a half-open time range, so that back-to-back bookings are
two bookings and not a conflict; raising on an overlap rather than returning
false, so a caller cannot ignore it and leave the room double-booked.

## Test

```bash
bundle install
bundle exec ruby -Ilib test/test_calendar.rb
bundle exec rubocop
```

## What the factory should find here

- `Style/Documentation` is on, so every class needs the comment explaining
  why it exists — the rule pack's baseline has something real to hold.
- The tests state the two decisions a change could quietly reverse: the
  half-open range, and raising rather than returning false.
