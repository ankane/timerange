require_relative "test_helper"

class TestTimeRange < Minitest::Test

  def test_time_range
    day = Time.parse("2014-06-01")
    assert_equal 7, TimeRange.new(range: day..day).expand(:week).step(:day).size
  end

  def test_today
    day = Time.now.midnight
    tr = TimeRange.today
    assert_equal day, tr.begin
    assert_equal day + 1.day, tr.end
    assert tr.exclude_end?
  end

end
