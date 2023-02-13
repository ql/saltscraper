require_relative '../spec_helper.rb'

RSpec.describe Downloader do
  let(:connection) { nil }
  let(:service) { Downloader.new(url, connection: connection) }
  
  context 'on a happy path' do
    let(:url) { 'http://www.iscaliforniaonfire.com/' }

    it 'works', vcr: true do
      expect(service.call).to include('Yes') 
    end
  end
end
