require "time"
require "active_support/time"
require "timerange/version"

class TimeRange < Range
  class << self
    attr_accessor :time_zone
  end

  def initialize(b = nil, e = Time.now, exclude_end = false, options = {})
    if b.is_a?(Range)
      b, e, exclude_end = b.begin, b.end, b.exclude_end?
    end

    if b.is_a?(Hash)
      options, b, e, exclude_end = b, nil, nil, false
    elsif e.is_a?(Hash)
      options, e, exclude_end = e, Time.now, false
    end

    time_zone = options[:time_zone] || TimeRange.time_zone || Time.zone || "Etc/UTC"
    if time_zone.is_a?(ActiveSupport::TimeZone) or (time_zone = ActiveSupport::TimeZone[time_zone])
      # do nothing
    else
      raise "Unrecognized time zone"
    end

    b = time_zone.parse(b) if b.is_a?(String)
    e = time_zone.parse(e) if e.is_a?(String)
    b = b.in_time_zone(time_zone)

    if options[:duration]
      e = b + options[:duration]
      exclude_end = true
    end
    e = e.in_time_zone(time_zone)

    @time_zone = time_zone
    @options = options.merge(time_zone: @time_zone)

    super(b, e, exclude_end)
  end

  # should step expand by default?
  # TODO return enum
  def step(period, options = {}, &block)
    period = period.is_a?(Symbol) || period.is_a?(String) ? 1.send(period) : period
    arr = [self.begin]
    yield(arr.last) if block_given?
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
    self.class.new(bucket(period, self.begin, options), e, true, @options.merge(options))
  end

  def expand_start(period, options = {})
    e = self.end
    e = e.in_time_zone(options[:time_zone]) if options[:time_zone]
    self.class.new(bucket(period, self.begin, options), e, exclude_end?, @options.merge(options))
  end

  def bucket(period, time, options = {})
    self.class.bucket(period, time, @options.merge(options))
  end

  def self.bucket(period, time, options = {})
    time_zone = options[:time_zone] || Time.zone
    day_start = options[:day_start] || 0
    week_start = options[:week_start] || 6

    week_start = [:mon, :tue, :wed, :thu, :fri, :sat, :sun].index((options[:week_start] || :sun).to_sym)
    if !week_start
      raise "Unrecognized :week_start option"
    end

    time = time.to_time.in_time_zone(time_zone) - day_start.hours

    time =
      case period.to_sym
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
    new(date, date).expand(:day)
  end

  def self.yesterday
    date = Date.yesterday
    new(date, date).expand(:day)
  end

  def +(period)
    self.class.new(self.begin + period, self.end + period, exclude_end?)
  end

  def -(period)
    self.class.new(self.begin - period, self.end - period, exclude_end?)
  end

end
