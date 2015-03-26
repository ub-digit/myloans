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
      fixture = File.read("spec/fixtures/patronAccount.xml")

      # set up an expectation
      savon.expects(:patron_account).with(message: message).returns(fixture)

      # call the service
      user = GundaApi.find_user("123456789")

      expect(user).to be_truthy
    end
  end

end
