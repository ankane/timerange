require "active_support/time"

class TimeRange < Range
  VERSION = "0.0.1"

  def initialize(options = {})
    range = options[:range]
    super(range.begin, range.end, range.exclude_end?)
  end

  def step(period, options = {})
    arr = [bucket(period, self.begin, options)]
    while v = arr.last + 1.send(period) and cover?(v)
      arr << v
    end
    arr
  end

  def expand(period, options = {})
    self.class.new(range: Range.new(bucket(period, self.begin, options), bucket(period, self.end + 1.send(period), options), true))
  end

  def time_zone
    Time.zone
  end

  def bucket(period, time, options = {})
    day_start = 0
    week_start = 6 # sunday
    time = time.to_time.in_time_zone(time_zone) - day_start.hours

    time =
      case period
      when :second
        time.change(usec: 0)
      when :minute
        time.change(sec: 0)
      when :hour
        time.change(min: 0)
      when :day
        time.beginning_of_day
      when :week
        # same logic as MySQL group
        weekday = (time.wday - 1) % 7
        (time - ((7 - week_start + weekday) % 7).days).midnight
      when :month
        time.beginning_of_month
      else # year
        time.beginning_of_year
      end

    time + day_start.hours
  end

  def self.today
    date = Date.today
    new(range: date..date).expand(:day)
  end

  def self.yesterday
    date = Date.yesterday
    new(range: date..date).expand(:day)
  end

end
