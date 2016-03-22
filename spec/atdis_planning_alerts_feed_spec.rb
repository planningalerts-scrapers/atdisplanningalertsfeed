# TODO Shift to spec helper

$: << "#{File.dirname(__FILE__)}/.."
require 'atdisplanningalertsfeed'

Bundler.require :development, :test

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
  c.default_cassette_options = { record: :new_episodes}
  c.configure_rspec_metadata!
end


#
describe ATDISPlanningAlertsFeed, :vcr do
  before :each do
    @options = {
      lodgement_date_start: Date.parse("2016-02-21"),
      lodgement_date_end: Date.parse("2016-03-22")
    }
  end
  context 'valid feed' do
    it 'should not error' do
      ATDISPlanningAlertsFeed.save("http://mycouncil2.solorient.com.au/Horizon/@@horizondap_ashfield@@/atdis/1.0/")
    end
  end
  context 'dodgy pagination' do
    it 'should not error' do
      ATDISPlanningAlertsFeed.save("https://myhorizon.maitland.nsw.gov.au/Horizon/@@horizondap@@/atdis/1.0/")
    end
  end
end