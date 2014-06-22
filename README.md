# TimeRange

Time ranges for Ruby

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'timerange'
```

## Features

```ruby
time_range = TimeRange.new(7.days.ago..Time.now)
time_range.step(1.day)
time_range.expand(:week).step(1.day)

TimeRange.new("2014-06-01", "2014-06-07")
TimeRange.new("2014-06-01", duration: 1.week)
TimeRange.new(4.weeks.ago).expand_start(:week) # last 4 weeks

TimeRange.today
TimeRange.yesterday

TimeRange.today + 4.weeks
TimeRange.today - 4.weeks

TimeRange.bucket(:hour, user.created_at)
TimeRange.bucket(:day, user.created_at, day_start: 2) # 2 am
TimeRange.bucket(:week, user.created_at, week_start: :mon) # start weeks on Monday
TimeRange.bucket(:month, user.created_at, time_zone: "Pacific Time (US & Canada)")
```

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/timerange/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/timerange/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
