FactoryGirl.define do
  factory :job do
    page_resource { create(:page_resource) }

    trait :updating do
      status :updating
    end

    trait :creating do
      status :creating
    end

    trait :successful do
      status :done
    end

    trait :failed do
      status :failed
    end

    factory :updating_job, traits: [:updating]
    factory :creating_job, traits: [:creating]
    factory :successful_job, traits: [:successful]
    factory :failed_job, traits: [:failed]

  end
end