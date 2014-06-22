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

  def test_step_block
    count = 0
    TimeRange.today.expand(:week).step(:day) do |day|
      count += 1
    end
    assert_equal 7, count
  end

end
