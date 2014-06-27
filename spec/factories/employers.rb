FactoryGirl.define do
  factory :employer do
    name 'Das Coffee'
    fein '111111111'

    trait :fein_too_short do
      fein '1'
    end

    factory :invalid_employer, traits: [:fein_too_short]
  end
end