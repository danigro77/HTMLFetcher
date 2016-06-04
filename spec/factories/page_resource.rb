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

    trait :with_updating_job do
      ignore do
        jobs_count 1
      end
      after(:create) do |page, evaluator|
        create_list(:updating_job, evaluator.jobs_count, page_resource: page)
      end
    end

    trait :with_done_job do
      ignore do
        jobs_count 1
      end
      after(:create) do |page, evaluator|
        create_list(:successful_job, evaluator.jobs_count, page_resource: page)
      end
    end

    trait :with_creating_job do
      ignore do
        jobs_count 1
      end
      after(:create) do |page, evaluator|
        create_list(:creating_job, evaluator.jobs_count, page_resource: page)
      end
    end

    trait :with_failed_job do
      ignore do
        jobs_count 1
      end
      after(:create) do |page, evaluator|
        create_list(:failed_job, evaluator.jobs_count, page_resource: page)
      end
    end

    factory :recent_resource, traits: [:with_html, :recent_update, :with_done_job]
    factory :old_resource, traits: [:with_html, :old_update, :with_done_job]
    factory :old_updating_resource, traits: [:with_html, :old_update, :with_updating_job]
    factory :new_creating_resource, traits: [:with_creating_job]
    factory :new_failed_resource, traits: [:with_failed_job]

  end
end