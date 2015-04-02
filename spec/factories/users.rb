FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  factory :user, class: User do
    skip_create

    city "My City"
    street "My street"
    postal_code "12345"
    email {generate :email}
    name "John Doe"
    communication_preference 0

    trait :invalid_email do
      email 'hej@.com'
    end

    trait :no_email do
      email ""
    end

    trait :needs_email do
      communication_preference 1
    end

  end
end