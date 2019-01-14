# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/applicationinsights"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::ApplicationInsights do

  let(:uri) { 'https://dc.services.visualstudio.com/v2/track' }
  let(:instrumentation_key) { 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' }
  let(:schema_version) { '2' }
  let(:source_ip) { '192.168.99.100' }

  let(:cfg) {
    {
      'uri' => uri,
      'instrumentation_key' => instrumentation_key,
      'schema_version' => schema_version
    }
  }

  let(:output) { LogStash::Outputs::ApplicationInsights.new(cfg) }

  before do
    output.register
  end

  describe "#receive" do
    it "test" do
      metric = {
        :data => [
          {
            :name => "Count",
            :value => 1,
            :dimensions => {
              :type => "Email",
              :Machine => "DESKTOP-SKS35DF",
              :Result => "Success"
            }
          },
          {
            :name => "Test",
            :value => 2,
            :dimensions => {
              :type => "SMS",
              :Machine => "DESKTOP-SKS35DF",
              :Result => "Success"
            }
          }
        ]
      }
      event = LogStash::Event.new(metric)
      expect {output.receive(event)}.to_not raise_error
    end

  end
end
