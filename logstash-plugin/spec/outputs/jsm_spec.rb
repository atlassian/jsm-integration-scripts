require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/jsm"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::Jsm do

  subject {LogStash::Outputs::Jsm.new("apiKey" => "my_api_key" )}
  let(:logger) { subject.logger}

  describe "receive message" do

    it "when jsmAction is not specified" do
      expect(logger).to receive(:warn).with("No JSM action defined").once
      subject.receive({"message" => "test_alert","@version" => "1","@timestamp" => "2015-09-22T11:20:00.250Z"})
    end

    it "when jsmAction is not valid" do
      action = "invalid"
      expect(logger).to receive(:warn).with("Action #{action} does not match any available action, discarding..").once
      subject.receive({"message" => "test_alert","@version" => "1","@timestamp" => "2015-09-22T11:20:00.250Z", "jsmAction" => action})
    end

    it "when jsmAction is 'create'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "jsmAction" => "create"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.jsmBaseUrl}#{subject.createActionUrl}").once
      subject.receive(event)
    end

    it "when jsmAction is 'close'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "jsmAction" => "close"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.jsmBaseUrl}#{subject.closeActionUrl}").once
      subject.receive(event)
    end

    it "when jsmAction is 'acknowledge'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "jsmAction" => "acknowledge"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.jsmBaseUrl}#{subject.acknowledgeActionUrl}").once
      subject.receive(event)
    end

    it "when jsmAction is 'note'" do
      event = {"message" => "test_alert", "@version" => "1", "@timestamp" => "2015-09-22T11:20:00.250Z", "jsmAction" => "note"}
      expect(logger).to receive(:info).with("processing #{event}").once
      expect(logger).to receive(:info).with("Executing url #{subject.jsmBaseUrl}#{subject.noteActionUrl}").once
      subject.receive(event)
    end
  end
end
