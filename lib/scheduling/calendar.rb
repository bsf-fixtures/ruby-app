# frozen_string_literal: true

require_relative "slot"

module Scheduling
  # A day's bookings for one room.
  class Calendar
    class Conflict < StandardError; end
    class NoFreeSlot < StandardError; end

    attr_reader :room, :slots

    def initialize(room)
      @room = room
      @slots = []
    end

    # Books a slot, or raises naming the one it clashes with.
    #
    # Raising rather than returning false: a caller that ignores a false is
    # left believing the room is booked, and nothing downstream can tell.
    def book(slot)
      clash = slots.find { |existing| existing.overlaps?(slot) }
      raise Conflict, "#{slot} clashes with #{clash}" if clash

      @slots = (slots + [slot]).sort_by(&:starts_at)
      slot
    end

    def free?(slot)
      slots.none? { |existing| existing.overlaps?(slot) }
    end

    def booked_minutes
      slots.sum(&:minutes)
    end

    # The gaps between bookings, which is what a scheduler actually needs.
    def gaps(day_start, day_end)
      edges = [day_start, *slots.flat_map { |s| [s.starts_at, s.ends_at] }, day_end]
      edges.each_slice(2).filter_map do |from, to|
        next if to.nil? || to <= from

        Slot.new(from, to)
      end
    end

    # The first stretch of at least `minutes` inside the working day, which is
    # what a scheduler needs to offer a booking.
    #
    # Each gap is clamped to the day: gaps trusts its edges, so a booking
    # outside the window stretches a gap beyond it. Raising rather than
    # returning nil, so a caller cannot pass a missing slot on to book.
    def first_free_slot(minutes, day_start, day_end)
      gaps(day_start, day_end).each do |gap|
        from = [gap.starts_at, day_start].max
        to = [gap.ends_at, day_end].min
        next if to <= from
        return Slot.new(from, to) if (to - from) >= minutes * 60
      end
      raise NoFreeSlot, "no free slot of #{minutes} minutes in #{Slot.new(day_start, day_end)}"
    end
  end
end
