begin
  require 'metric_fu'
  MetricFu::Configuration.run do |config|
    config.metrics  = [:churn, :saikuro, :flog, :flay, :reek]
      # Removed: :roodi, :stats, :rcov
    config.graphs = [:flog, :flay, :reek]
      # Removed: :roodi, :rcov
  end
rescue LoadError
end
