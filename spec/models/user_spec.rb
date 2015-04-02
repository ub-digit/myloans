require 'rails_helper'

RSpec.describe User, :type => :model do

  describe "permitted params" do
    context "valid parameters given" do
      it "should return a hash" do
        user = User.new(barcode: 1, city: 'city', street: 'street', postal_code: '12345')
        hash = user.gunda_params
        expect(hash).to be_a Hash
        expect(hash[:barcode]).to be_truthy
      end
    end
  end

  describe "email" do
    context "with communication preference set to 1 or 3" do
      context "with an empty email address" do
        it "should invalidate" do
          user = build(:user, :needs_email, :no_email)
          expect(user.valid?).to be_falsey
          expect(user.errors.messages[:email].size).to be 1
        end
      end
      context "with a misstyled email address" do
        it "should invalidate" do
          user = build(:user, :needs_email, :invalid_email)
          expect(user.valid?).to be_falsey
          expect(user.errors.messages[:email].size).to be 1
        end
      end
      context "with a valid email address" do
        it "should validate" do
          user = build(:user, :needs_email)
          expect(user.valid?).to be_truthy
        end
      end
    end
    context "with communication preference set to 0" do
      context "with an invalid email address" do
        it "should invalidate object" do
          user = build(:user, :invalid_email)
          expect(user.valid?).to be_falsey
          expect(user.errors.messages[:email].size).to be 1
        end
      end
    end
  end

  describe "city" do
    context "has city" do
      it "should validate object" do
        user = build(:user)
        expect(user.valid?).to be_truthy
      end
    end
    context "has no city" do
      it "should invalidate object" do
        user = build(:user)
      end
    end
  end

end