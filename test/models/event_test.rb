require 'test_helper'

class EventTest < ActiveSupport::TestCase

  test "one simple test example" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal [], availabilities[0][:slots]
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
    assert_equal [], availabilities[2][:slots]
    assert_equal Date.new(2014, 8, 16), availabilities[6][:date]
    assert_equal 7, availabilities.length
  end

  test "no availabilities test" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 09:30"), ends_at: DateTime.parse("2014-08-11 12:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
  end

  test "appointment out of opening test" do

    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 09:00"), ends_at: DateTime.parse("2014-08-11 13:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]
  end

  test "no opening test" do

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal 7, availabilities.length
  end

  test "non clean hours test" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:37"), ends_at: DateTime.parse("2014-08-04 12:37"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:37"), ends_at: DateTime.parse("2014-08-11 11:37")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal ["9:37", "10:07", "11:37", "12:07"], availabilities[1][:slots]
  end

  test "weekly recurring event set AFTER the tested date test" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-18 09:30"), ends_at: DateTime.parse("2014-08-18 12:30"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-18 10:30"), ends_at: DateTime.parse("2014-08-18 11:30")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 11), availabilities[1][:date]
    assert_equal [], availabilities[1][:slots]

    availabilities = Event.availabilities DateTime.parse("2014-08-17")
    assert_equal Date.new(2014, 8, 18), availabilities[1][:date]
    assert_equal ["9:30", "10:00", "11:30", "12:00"], availabilities[1][:slots]
  end

  test "multiple openings and appointments test" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 12:30"), weekly_recurring: false
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 14:00"), ends_at: DateTime.parse("2014-08-04 18:00"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 10:30"), ends_at: DateTime.parse("2014-08-04 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 11:30"), ends_at: DateTime.parse("2014-08-04 12:00")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 14:00"), ends_at: DateTime.parse("2014-08-04 14:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-04 16:00"), ends_at: DateTime.parse("2014-08-04 18:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-04")
    assert_equal Date.new(2014, 8, 04), availabilities[0][:date]
    assert_equal ["9:30", "10:00", "12:00", "14:30", "15:00", "15:30"], availabilities[0][:slots]
  end

  test "full week test" do
    
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-04 09:30"), ends_at: DateTime.parse("2014-08-04 18:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-05 09:30"), ends_at: DateTime.parse("2014-08-05 18:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-06 09:30"), ends_at: DateTime.parse("2014-08-06 18:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-07 09:30"), ends_at: DateTime.parse("2014-08-07 18:00"), weekly_recurring: true
    Event.create kind: 'opening', starts_at: DateTime.parse("2014-08-08 09:30"), ends_at: DateTime.parse("2014-08-08 18:00"), weekly_recurring: true
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 10:30"), ends_at: DateTime.parse("2014-08-11 11:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 11:30"), ends_at: DateTime.parse("2014-08-11 12:00")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 14:00"), ends_at: DateTime.parse("2014-08-11 14:30")
    Event.create kind: 'appointment', starts_at: DateTime.parse("2014-08-11 16:00"), ends_at: DateTime.parse("2014-08-11 18:00")

    availabilities = Event.availabilities DateTime.parse("2014-08-10")
    assert_equal Date.new(2014, 8, 10), availabilities[0][:date]
    assert_equal 0, availabilities[0][:slots].length
    assert_equal 9, availabilities[1][:slots].length
    assert_equal 17, availabilities[2][:slots].length
    assert_equal 17, availabilities[3][:slots].length
    assert_equal 17, availabilities[4][:slots].length
    assert_equal 17, availabilities[5][:slots].length
    assert_equal 0, availabilities[6][:slots].length
    assert_equal 7, availabilities.length
  end
end
