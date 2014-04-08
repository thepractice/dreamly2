FactoryGirl.define do
	factory :user do
		sequence(:username)		{ |n| "Person #{n}" }
		sequence(:email)			{ |n| "person_#{n}@example.com" }
		password		"foobaristooshort"
		password_confirmation "foobaristooshort"
	end

	factory :dream do
		sequence(:title) { |n| "Dream #{n}" }
		sequence(:body)	 { |n| "Body #{n}" }
		user
	end
end