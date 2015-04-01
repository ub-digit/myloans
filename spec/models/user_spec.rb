require 'rails_helper'

RSpec.describe User, :type => :model do

  describe "permitted params" do
    context "valid parameters given" do
      it "should return a hash" do
        user = User.new({barcode: 1, city: 'city', street: 'street', postal_code: '12345'})
        hash = user.gunda_params
        expect(hash).to be_a Hash
        expect(hash[:barcode]).to be_truthy
      end
    end
  end

  describe "city" do
    it {should validate_presence_of(:city)}
  end

end