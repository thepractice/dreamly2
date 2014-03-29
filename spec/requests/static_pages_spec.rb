require 'spec_helper'

describe "StaticPages" do

	subject { page }

	let(:base_title) { "Just Had a Dream" }

	describe "Home page" do
		before { visit root_path }

		it { should have_title("#{base_title}") }
		it { should have_content('home page') }
	end

	describe "Help page" do
		before { visit help_path }

		it { should have_title("#{base_title} | Help") }
		it { should have_content('help') }
	end

	describe "About page" do
		before { visit about_path }

		it { should have_title("#{base_title} | About") }
		it { should have_content('About') }
	end

	describe "Contact page" do
		before { visit contact_path }

		it { should have_title("#{base_title} | Contact") }
		it { should have_content('Contact') }
	end

	it "should have the right links in the layout" do
		visit root_path
		click_link "Help"
		expect(page).to have_title("#{base_title} | Help")
		click_link "About"
		expect(page).to have_title("#{base_title} | About")
		click_link "Home"
		expect(page).to have_title("#{base_title}")
		click_link "Contact"
		expect(page).to have_title("#{base_title} | Contact")
		click_link "Just Had a Dream"
		expect(page).to have_title("#{base_title}")
	end
end
