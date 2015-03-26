require 'rails_helper'

# require the helper module
require "savon/mock/spec_helper"

RSpec.describe GundaApi, :type => :model do

  # include the helper module
  include Savon::SpecHelper

  # set Savon in and out of mock mode
  before(:all) { savon.mock!   }
  after(:all)  { savon.unmock! }

  describe "show" do
    it "will return a user for a valid barcode" do
      message = { barcode: "123456789" }
      fixture = File.read("spec/fixtures/patronAccount/tmp.xml")
      # set up an expectation
      savon.expects(:patron_account).with(message: message).returns(fixture)
      # call the service
      user = GundaApi.find_user("123456789")
      expect(user).to be_truthy
    end

    context "for a user with many requests" do
      it "will return a user with a list of requests" do
        message = { barcode: "6" }
        fixture = File.read("spec/fixtures/patronAccount/many_requests.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("6")
        expect(user).to be_truthy
        expect(user.requests).to be_truthy
        expect(user.requests.first).to be_truthy
        expect(user.requests.each{|req| req.class == Request}).to be_truthy
      end
    end
  end

end
