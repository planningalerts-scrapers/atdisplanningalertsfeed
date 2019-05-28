# frozen_string_literal: true

# TODO: Shift to spec helper

$LOAD_PATH << "#{File.dirname(__FILE__)}/.."
require "atdisplanningalertsfeed"

Bundler.require :development, :test

require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end

describe ATDISPlanningAlertsFeed, :vcr do
  before :each do
    @options = {
      lodgement_date_start: Date.parse("2016-02-21"),
      lodgement_date_end: Date.parse("2016-03-22"),
      # Make the tests run quietly
      logger: Logger.new("/dev/null")
    }
  end
  context "valid feed" do
    it "should not error on empty feed" do
      records = ATDISPlanningAlertsFeed.save(
        "http://mycouncil2.solorient.com.au/Horizon/@@horizondap_ashfield@@/atdis/1.0/",
        @options
      )

      expect(records.length).to eq 0
    end
  end
  context "dodgy pagination" do
    it "should not error" do
      records = ATDISPlanningAlertsFeed.save(
        "https://myhorizon.maitland.nsw.gov.au/Horizon/@@horizondap@@/atdis/1.0/",
        @options
      )

      expect(records.length).to eq 120
    end
  end

  context "really dodgy pagination" do
    it "should not error" do
      records = ATDISPlanningAlertsFeed.save(
        "https://da.kiama.nsw.gov.au/atdis/1.0/",
        @options
      )

      expect(records.length).to eq 43
    end
  end

  context "with a flakey service" do
    # TODO: This spec should always force a
    # RestClient::InternalServerError: 500 Internal Server Error
    it "should not error" do
      @options.merge!(flakey: true)
      # TODO: This doesn't work as expected (stackleveltoodeep), but the VCR cassette should work
      # allow_any_instance_of(ATDIS::Feed).to
      # receive(:applications).and_raise(
      #   RestClient::InternalServerError.new("500 Internal Server Error"))

      url = "http://myhorizon.cootamundra.nsw.gov.au/Horizon/@@horizondap@@/atdis/1.0/"
      records = ATDISPlanningAlertsFeed.save(url, @options)

      # TODO: Expectation that a HTTP 500 on the first page recovers gracefully
      expect(records.length).to eq 0
    end

    it "should not error half way through processing" do
      @options.merge!(flakey: true)

      # TODO: This doesn't work as expected
      # But I have faked the response in the cassette
      # allow_any_instance_of(ATDIS::Models::Page).to
      # receive(:next_page).and_raise(
      #   RestClient::InternalServerError.new("500 Internal Server Error"))

      # Yass isn't actually flakey, but Cootamundra is *too* flakey
      # This scenario replicates one page of many having an unhandled exception
      # (seen in Horizon DAP feeds)
      url = "http://mycouncil.yass.nsw.gov.au/Horizon/@@horizondap@@/atdis/1.0/"
      records = ATDISPlanningAlertsFeed.save(url, @options)

      # TODO: Expectation that a HTTP 500 on the second page still allows several errors to process
      expect(records.length).to eq 20
    end
  end
end
