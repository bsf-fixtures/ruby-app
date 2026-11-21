# frozen_string_literal: true

require "minitest/autorun"
require "time"
require_relative "../lib/scheduling/calendar"

class TestCalendar < Minitest::Test
  def at(hhmm)
    Time.parse("2026-11-20 #{hhmm}:00 UTC")
  end

  def slot(from, to)
    Scheduling::Slot.new(at(from), at(to))
  end

  def setup
    @calendar = Scheduling::Calendar.new("Room A")
  end

  def test_books_a_free_slot
    @calendar.book(slot("09:00", "10:00"))
    assert_equal 60, @calendar.booked_minutes
  end

  def test_back_to_back_bookings_do_not_clash
    # The reason the range is half-open: 09:00-10:00 and 10:00-11:00 are two
    # bookings, not a conflict.
    @calendar.book(slot("09:00", "10:00"))
    @calendar.book(slot("10:00", "11:00"))
    assert_equal 120, @calendar.booked_minutes
  end

  def test_an_overlap_raises_naming_the_clash
    @calendar.book(slot("09:00", "10:00"))
    error = assert_raises(Scheduling::Calendar::Conflict) { @calendar.book(slot("09:30", "10:30")) }
    assert_includes error.message, "09:00-10:00"
  end

  def test_a_slot_must_end_after_it_starts
    assert_raises(ArgumentError) { slot("10:00", "10:00") }
    assert_raises(ArgumentError) { slot("11:00", "10:00") }
  end

  def test_gaps_between_bookings
    @calendar.book(slot("10:00", "11:00"))
    @calendar.book(slot("13:00", "14:00"))
    gaps = @calendar.gaps(at("09:00"), at("17:00")).map(&:to_s)
    assert_equal ["09:00-10:00", "11:00-13:00", "14:00-17:00"], gaps
  end
end
