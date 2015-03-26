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

    context "for a user with one request" do
      it "will return a user with a list of one request" do
        message = { barcode: "7" }
        fixture = File.read("spec/fixtures/patronAccount/one_request.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("7")
        expect(user).to be_truthy
        expect(user.requests).to be_truthy
        expect(user.requests.first).to be_truthy
        expect(user.requests.class == Array).to be_truthy
        expect(user.requests.length == 1).to be_truthy
        expect(user.requests.first.class == Request).to be_truthy
      end
    end

    context "for a user with many requests" do
      it "will return a user with a list of requests" do
        message = { barcode: "6" }
        fixture = File.read("spec/fixtures/patronAccount/many_requests.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("6")
        expect(user).to be_truthy
        expect(user.requests).to be_truthy
        expect(user.requests.class == Array).to be_truthy
        expect(user.requests.length >= 2).to be_truthy
        expect(user.requests.each{|req| req.class == Request}).to be_truthy
      end
    end


    context "for a user with one loan" do
      it "will return a user with a list of one loan" do
        message = { barcode: "8" }
        fixture = File.read("spec/fixtures/patronAccount/one_checkout.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("8")
        expect(user).to be_truthy
        expect(user.current_loans).to be_truthy
        expect(user.current_loans.first).to be_truthy
        expect(user.current_loans.class == Array).to be_truthy
        expect(user.current_loans.length == 1).to be_truthy
        expect(user.current_loans.first.class == Loan).to be_truthy
      end
    end

    context "for a user with many loans" do
      it "will return a user with a list of loans" do
        message = { barcode: "10" }
        fixture = File.read("spec/fixtures/patronAccount/many_checkouts.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("10")
        expect(user).to be_truthy
        expect(user.current_loans).to be_truthy
        expect(user.current_loans.class == Array).to be_truthy
        expect(user.current_loans.length >= 2).to be_truthy
        expect(user.current_loans.each{|loan| loan.class == Loan}).to be_truthy
      end
    end

    context "for a user with many fines" do
      it "will return a user with a list of fines" do
        message = { barcode: "14" }
        fixture = File.read("spec/fixtures/patronAccount/two_fines.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("14")
        expect(user).to be_truthy
        expect(user.fines).to be_truthy
        expect(user.fines.class == Array).to be_truthy
        expect(user.fines.length >= 2).to be_truthy
        expect(user.fines.each{|fine| fine.class == Fine}).to be_truthy
      end
    end

  end
end
