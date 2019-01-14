# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'rest-client'
require 'json'
require 'time'

class LogStash::Outputs::ApplicationInsights < LogStash::Outputs::Base
  config_name "applicationinsights"

  # The URL of the Application Insights API for custom events and metrics
  config :uri, :validate => :string, :required => true

  # The Instrumentation Key of the Application Insights instance
  config :instrumentation_key, :validate => :string, :required => true

  config :schema_version, :validate => :string, :required => true

  config :source_ip, :validate => :string, :required => false

  # list of Key names in in-coming record to deliver.
  #config :filters, :validate => :array, :default => []

  public
  def register
  	raise ArgumentError, 'instrumentation key must be a valid uuid' unless @instrumentation_key.match(/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/)
  end

  def receive(event)
    begin
      event_hash = event.to_hash
      values = event_hash['data']
      meta = {
        :name => "Microsoft.ApplicationInsights.#{@instrumentation_key.tr('-', '')}.Metric",
        :time => Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
        :iKey => @instrumentation_key,
        :data => {
          :baseType => 'MetricData',
          :baseData => {
            :ver => @schema_version
          }
        }
      }
      unless @source_ip.nil?
        meta[:tags] = {'ai.location.ip' => @source_ip}
      end
      telemetry = []
      values.each do |value|
        metric = deep_copy(meta)
        metrics = []
        metrics << {:name => value['name'], :kind => 'Measurement', :value => value['value']}
        metric[:data][:baseData][:metrics] = metrics
        metric[:data][:baseData][:properties] = value['dimensions']
        telemetry << metric.to_json.gsub(/[ \n]/, '')
      end
      headers = {'Content-Type' => 'application/x-json-stream'}
      body = telemetry.join('')
      response = RestClient.post(@uri, body, headers)
      unless response.code == 200
        #puts "DataCollector API request failure: error code: #{response.code}, data=>#{event}"
        @logger.error("DataCollector API request failure: error code: #{response.code}, data=>#{event}")
      end
    rescue Exception => ex
      #puts "Exception occured in posting to DataCollector API: '#{ex}', data=>#{event}"
      @logger.error("Exception occured in posting to DataCollector API: '#{ex}', data=>#{event}")
    end
  end

  def deep_copy(o)
    Marshal.load(Marshal.dump(o))
  end

end
