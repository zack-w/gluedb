FactoryGirl.define do
  factory :user do
    email 'example@example.com'
    password '12345678'
    password_confirmation '12345678'
    approved true
  end

  trait :without_email do
    email ' '
  end

  trait :without_password do
    password ' '
  end

  trait :without_password_confirmation do
    password_confirmation ' '
  end

  factory :invalid_user, traits: [:without_email, :without_password, :without_password_confirmation]
end