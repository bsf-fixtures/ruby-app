# frozen_string_literal: true

require_relative "slot"

module Scheduling
  # A day's bookings for one room.
  class Calendar
    class Conflict < StandardError; end

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
  end
end
