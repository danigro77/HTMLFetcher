FactoryGirl.define do
  factory :page_resource do
    url { Faker::Internet.url('test.com') }

    trait :with_html do
      html { "<html><head></head><body>HEY threre</body></html>"}
    end

    trait :recent_update do
      updated_at DateTime.current.beginning_of_day
    end

    trait :old_update do
      updated_at DateTime.current - 1.day
    end

    factory :recent_resource, traits: [:with_html, :recent_update]
    factory :old_resource, traits: [:with_html, :old_update]

  end
end