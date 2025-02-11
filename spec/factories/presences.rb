FactoryBot.define do
  factory :presence do
    association :user, factory: :user
  end
end