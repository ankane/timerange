require "active_support/time"

class TimeRange < Range
  VERSION = "0.0.1"

  def initialize(b = nil, e = nil, exclude_end = nil, options = {})
    if b.is_a?(Hash)
      options = b
    end

    if options[:range]
      range = options[:range]
      super(range.begin, range.end, range.exclude_end?)
    else
      super
    end
  end

  def step(period, options = {}, &block)
    arr = [bucket(period, self.begin, options)]
    yield(arr.first) if block_given?
    while v = arr.last + 1.send(period) and cover?(v)
      yield(v) if block_given?
      arr << v
    end
    arr
  end

  def expand(period, options = {})
    e =
      if exclude_end? and self.end == bucket(period, self.end, options)
        self.end
      else
        bucket(period, self.end + 1.send(period), options)
      end
    self.class.new(range: Range.new(bucket(period, self.begin, options), e, true))
  end

  def bucket(period, time, options = {})
    self.class.bucket(period, time, options)
  end

  def self.bucket(period, time, options = {})
    time_zone = Time.zone
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
