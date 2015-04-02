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

    context "for a user with minimal contact info" do
      it "will return a user with minimal contact info" do
        message = { barcode: "8979879872" }
        fixture = File.read("spec/fixtures/patronAccount/minimal.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("8979879872")
        expect(user.street).to be_truthy
        expect(user.city).to be_truthy
        expect(user.postal_code).to be_truthy
        expect(user.phone_nr).to be_falsey
        expect(user.mobile_nr).to be_falsey
        expect(user.email).to be_falsey
      end
    end


    context "for a user with valid contact info" do
      it "will return a user with valid contact info" do
        message = { barcode: "5181961938" }
        fixture = File.read("spec/fixtures/patronAccount/valid_contact_info.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("5181961938")
        expect(user.street).to be_truthy
        expect(user.city).to be_truthy
        expect(user.postal_code).to be_truthy
        expect(user.phone_nr).to be_truthy
        expect(user.mobile_nr).to be_truthy
        expect(user.email).to be_truthy
      end
    end

    context "for a user lacking requests" do
      it "will return a user with an empty requests list " do
        message = { barcode: "8" }
        fixture = File.read("spec/fixtures/patronAccount/zero_requests.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("8")
        expect(user).to be_truthy
        expect(user.requests).to be_truthy
        expect(user.requests.first).to be_falsey
        expect(user.requests.class == Array).to be_truthy
        expect(user.requests.length == 0).to be_truthy
      end
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


    context "for a user with one checkout" do
      it "will return a user with a list of one checkout" do
        message = { barcode: "8" }
        fixture = File.read("spec/fixtures/patronAccount/one_checkout.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("8")
        expect(user).to be_truthy
        expect(user.checkouts).to be_truthy
        expect(user.checkouts.first).to be_truthy
        expect(user.checkouts.class == Array).to be_truthy
        expect(user.checkouts.length == 1).to be_truthy
        expect(user.checkouts.first.class == Checkout).to be_truthy
      end
    end

    context "for a user with many checkouts" do
      it "will return a user with a list of checkouts" do
        message = { barcode: "10" }
        fixture = File.read("spec/fixtures/patronAccount/many_checkouts.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("10")
        expect(user).to be_truthy
        expect(user.checkouts).to be_truthy
        expect(user.checkouts.class == Array).to be_truthy
        expect(user.checkouts.length >= 2).to be_truthy
        expect(user.checkouts.each{|checkout| checkout.class == Checkout}).to be_truthy
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

    context "for a user with exactly one fine" do
      it "will return a user with a list containing one fine" do
        message = { barcode: "13" }
        fixture = File.read("spec/fixtures/patronAccount/one_fine.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("13")
        expect(user).to be_truthy
        expect(user.fines).to be_truthy
        expect(user.fines.class == Array).to be_truthy
        expect(user.fines.length == 1).to be_truthy
        expect(user.fines.each{|fine| fine.class == Fine}).to be_truthy
      end
    end

    context "for a user with no fine" do
      it "will return a user with an empty fine list" do
        message = { barcode: "8" }
        fixture = File.read("spec/fixtures/patronAccount/zero_fines.xml")
        savon.expects(:patron_account).with(message: message).returns(fixture)

        user = GundaApi.find_user("8")
        expect(user).to be_truthy
        expect(user.fines).to be_truthy
        expect(user.fines.class == Array).to be_truthy
        expect(user.fines.length == 0).to be_truthy
        expect(user.fines.each{|fine| fine.class == Fine}).to be_truthy
      end
    end
  end


  describe "renew" do
   context "when renewing a renewable checkout for a user" do
      it "will return checkout data" do
        message = {patronBarcode: "90", selectedCheckouts: {:@checkoutId => "123456"}}
        fixture = File.read("spec/fixtures/renew/success.xml")
        savon.expects(:renewal).with(message: message).returns(fixture)

        checkout = GundaApi.renew(barcode: "90", checkout_id: "123456")
        expect(checkout.barcode).to be_truthy
        expect(checkout.title).to be_truthy
        expect(checkout.checkout_id).to be_truthy
        expect(checkout.due_date).to be_truthy
        expect(checkout.recallable_date).to be_truthy
        expect(checkout.status).to be_truthy
      end
    end
    context "when renewing a non-renewable checkout for a user" do
      it "will return an empty data object" do
        message = {patronBarcode: "91", selectedCheckouts: {:@checkoutId => "654321"}}
        fixture = File.read("spec/fixtures/renew/error.xml")
        savon.expects(:renewal).with(message: message).returns(fixture)

        checkout = GundaApi.renew(barcode: "91", checkout_id: "654321")
        expect(checkout.nil?).to be_truthy
      end
    end

  end
end
