require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "timecop"

Time.zone = "Pacific Time (US & Canada)"

Timecop.freeze
