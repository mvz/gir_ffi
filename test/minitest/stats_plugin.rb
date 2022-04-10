# frozen_string_literal: true

module Minitest
  class StatsReporter < AbstractReporter
    def initialize(_options)
      @results = []
    end

    def start
      @current_time = Time.now
    end

    def record(result)
      @results << result
    end

    def report
      slowest = @results.sort_by(&:time).last(10).reverse
      slowest.each do |result|
        puts format("%<time>10.4f %<location>s",
                    time: result.time,
                    location: result.location)
      end
    end
  end

  def self.plugin_stats_init(options)
    reporter << StatsReporter.new(options)
  end
end
