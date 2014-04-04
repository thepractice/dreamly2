require 'spec_helper'

describe "User pages" do
	
	subject { page }

	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		let!(:dream1) { FactoryGirl.create(:dream, user: user, body: "Foo") }
		let!(:dream2) { FactoryGirl.create(:dream, user: user, body: "Bar") }

		before { visit user_path(user) }

		it { should have_content(user.username) }
		it { should have_title(user.username) }

		describe "dreams" do
			it { should have_content(dream1.body) }
			it { should have_content(dream2.body) }
			it { should have_content(user.dreams.count) }
		end
	end
end