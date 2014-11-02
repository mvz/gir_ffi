module Minitest
  class StatsReporter < AbstractReporter
    def initialize _options
      @results = []
    end

    def start
      @current_time = Time.now
    end

    def record result
      @results << result
    end

    def report
      slowest = @results.sort_by(&:time).reverse.first(10)
      slowest.each do |result|
        puts format("%10.4f %s", result.time, result.location)
      end
    end
  end

  def self.plugin_stats_init options
    reporter << StatsReporter.new(options)
  end
end
