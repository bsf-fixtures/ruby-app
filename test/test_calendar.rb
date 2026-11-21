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

  def first_free(minutes)
    @calendar.first_free_slot(minutes, at("09:00"), at("17:00")).to_s
  end

  def test_first_free_slot_on_an_empty_day_is_the_working_day
    assert_equal "09:00-17:00", first_free(60)
  end

  def test_first_free_slot_skips_gaps_that_are_too_short
    @calendar.book(slot("09:30", "10:00"))
    @calendar.book(slot("11:00", "12:00"))
    assert_equal "10:00-11:00", first_free(60)
  end

  def test_a_gap_of_exactly_n_minutes_is_free_for_n_minutes
    @calendar.book(slot("09:00", "10:00"))
    @calendar.book(slot("11:00", "17:00"))
    assert_equal "10:00-11:00", first_free(60)
  end

  def test_a_booking_outside_working_hours_does_not_stretch_the_free_slot
    # Without the clamp the answer comes straight from gaps and leaks outside
    # working hours: 08:00-17:00 and 09:00-18:00.
    @calendar.book(slot("07:00", "08:00"))
    assert_equal "09:00-17:00", first_free(60)
    @calendar = Scheduling::Calendar.new("Room A")
    @calendar.book(slot("18:00", "19:00"))
    assert_equal "09:00-17:00", first_free(60)
  end

  def test_no_free_slot_raises_rather_than_returning_one_outside_working_hours
    @calendar.book(slot("09:00", "16:30"))
    error = assert_raises(Scheduling::Calendar::NoFreeSlot) { first_free(60) }
    assert_includes error.message, "09:00-17:00"
    assert_includes error.message, "60 minutes"
  end
end
