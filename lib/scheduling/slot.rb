# frozen_string_literal: true

module Scheduling
  # A half-open time range: a slot that ends at 10:00 does not overlap one
  # that starts at 10:00. Closed ranges make every back-to-back booking look
  # like a conflict, which is the bug this type exists to prevent.
  class Slot
    attr_reader :starts_at, :ends_at

    def initialize(starts_at, ends_at)
      raise ArgumentError, "a slot must end after it starts" unless ends_at > starts_at

      @starts_at = starts_at
      @ends_at = ends_at
    end

    def overlaps?(other)
      starts_at < other.ends_at && other.starts_at < ends_at
    end

    def minutes
      ((ends_at - starts_at) / 60).to_i
    end

    def to_s
      "#{starts_at.strftime('%H:%M')}-#{ends_at.strftime('%H:%M')}"
    end
  end
end
