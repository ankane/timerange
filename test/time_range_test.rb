require_relative "test_helper"

class TestTimeRange < Minitest::Test

  def test_time_range
    day = Time.parse("2014-06-01")
    assert_equal 7, TimeRange.new(day..day).expand(:week).step(:day).size
  end

  def test_time_zone
    day = Time.parse("2014-06-01")
    time_zone = "Eastern Time (US & Canada)"
    assert_equal time_zone, TimeRange.new(day, time_zone: time_zone).expand(:week).first.time_zone.name
  end

  def test_today
    day = Time.now.midnight
    tr = TimeRange.today
    assert_equal day, tr.begin
    assert_equal day + 1.day, tr.end
    assert tr.exclude_end?
  end

  def test_step_block
    count = 0
    TimeRange.today.expand(:week).step(:day) do |day|
      count += 1
    end
    assert_equal 7, count
  end

  def test_duration
    tr = TimeRange.new("2014-06-01", duration: 1.week)
    day = Time.zone.parse("2014-06-01")
    assert_equal day, tr.begin
    assert_equal day + 1.week, tr.end
    assert tr.exclude_end?
  end

  def test_last
    tr = TimeRange.new(4.weeks.ago)
    assert_equal 4.weeks.ago, tr.begin
    assert_equal Time.zone.now, tr.end
    assert !tr.exclude_end?
  end

  def test_math
    assert_equal TimeRange.today, TimeRange.yesterday + 1.day
    assert_equal TimeRange.yesterday, TimeRange.today - 1.day
  end

end
