require "time"
require "active_support/time"

class TimeRange < Range
  attr_reader :time_zone

  VERSION = "0.0.1"

  def initialize(b = nil, e = nil, exclude_end = nil, options = {})
    if b.is_a?(Hash)
      options = b
    end
    @options = options

    time_zone = options[:time_zone] || Time.zone || "Etc/UTC"
    if time_zone.is_a?(ActiveSupport::TimeZone) or (time_zone = ActiveSupport::TimeZone[time_zone])
      @time_zone = time_zone
    else
      raise "Unrecognized time zone"
    end

    if options[:range]
      range = options[:range]
      super(range.begin.in_time_zone(time_zone), range.end.in_time_zone(time_zone), range.exclude_end?)
    elsif options[:start]
      start = options[:start]
      start = time_zone.parse(start) if start.is_a?(String)
      e = start + options[:duration]
      super(start, e, true)
    else
      super
    end
  end

  def step(period, options = {}, &block)
    period = period.is_a?(Symbol) || period.is_a?(String) ? 1.send(period) : period
    arr = [self.begin]
    yield(arr.first) if block_given?
    while v = arr.last + period and cover?(v)
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

  def expand_start(period, options = {})
    self.class.new(range: Range.new(bucket(period, self.begin, options), self.end, exclude_end?))
  end

  def bucket(period, time, options = {})
    self.class.bucket(period, time, options)
  end

  def self.bucket(period, time, options = {})
    time_zone = options[:time_zone] || Time.zone
    day_start = options[:day_start] || 0
    week_start = options[:week_start] || 6
    time = time.to_time.in_time_zone(time_zone) - day_start.hours

    period = period.to_sym
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
      when :year
        time.beginning_of_year
      else
        raise "Invalid period"
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
