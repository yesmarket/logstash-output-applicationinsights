# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'rest-client'
require 'json'
require 'openssl'
require 'base64'
require 'time'

class LogStash::Outputs::ApplicationInsights < LogStash::Outputs::Base
  config_name "applicationinsights"

  # The URL of the Application Insights API for custom events and metrics
  config :uri, :validate => :string, :required => true

  # The Instrumentation Key of the Application Insights instance
  config :instrumentation_key, :validate => :string, :required => true

  config :schema_version, :validate => :string, :required => true

  public
  def register
  	raise ArgumentError, 'instrumentation key must be a valid uuid' unless @instrumentation_key.match(/^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/)
  end

  def receive(event)
    begin

      headers = {}
      headers['Content-Type'] = 'application/x-json-stream'

      data = event.to_json
      

      body =  {
        "name" => "Microsoft.ApplicationInsights.#{@instrumentation_key.tr('-','')}.Metric",
        "time" => Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
        "iKey" => @instrumentation_key,
        "tags" => {
          "ai.location.ip" => "", 
          "ai.cloud.roleInstance" => @device_id,
        },
        "data" => {
          "baseType" => "MetricData",
          "baseData" => {
            "ver" => @schema_version,
            "metrics" => [
              {
                "name" => "Count",
                "kind" => "Measurement",
                "value" => 1,
              }
            ],
            "properties" => {
              "type" => "Email",
              "Machine" => "DESKTOP-SKS35DF",
              "Result" => "Success"
            }
          }
        }
      }

      date = Time.now.httpdate
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

end
