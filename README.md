# TimeRange

Time ranges for Ruby

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'timerange'
```

## Features

```ruby
time_range = TimeRange.new(range: 7.days.ago..Time.now)
time_range.step(:day)
time_range.expand(:day).step(1.day)
time_range.expand(:week)
```

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/timerange/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/timerange/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features
