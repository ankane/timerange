require_relative "test_helper"

class TestTimeRange < Minitest::Test

  def test_time_range
    day = Time.parse("2014-06-01")
    assert_equal 7, TimeRange.new(range: day..day).expand(:week).step(:day).size
  end

end
