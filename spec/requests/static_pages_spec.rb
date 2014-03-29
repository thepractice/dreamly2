require 'spec_helper'

describe "StaticPages" do

	subject { page }

	let(:base_title) { "Just Had a Dream" }

	describe "Home page" do
		before { visit 'static_pages/home' }

		it { should have_title("#{base_title}") }
		it { should have_content('home page') }
	end

	describe "Help page" do
		before { visit 'static_pages/help' }

		it { should have_title("#{base_title} | Help") }
		it { should have_content('help') }
	end

	describe "About page" do
		before { visit 'static_pages/about' }

		it { should have_title("#{base_title} | About") }
		it { should have_content('About') }
	end

	describe "Contact page" do
		before { visit 'static_pages/contact' }

		it { should have_title("#{base_title} | Contact") }
		it { should have_content('Contact') }
	end
end
