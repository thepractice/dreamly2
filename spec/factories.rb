FactoryGirl.define do
	factory :user do
		username		"Edward"
		email				"ed@example.com"
		password		"foobaristooshort"
		password_confirmation "foobaristooshort"
	end

	factory :dream do
		title "My title"
		body "Lorem ipsum"
		user
	end
end