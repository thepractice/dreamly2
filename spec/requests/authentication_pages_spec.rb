require 'spec_helper'

describe "Authentication" do

	subject { page }
	
	describe "for non-signed-in users" do
		let(:user) { FactoryGirl.create(:user) }

		describe "in the Dreams controller" do

			describe "submitting to the create action" do
				before { post dreams_path }
				specify { expect(response).to redirect_to(new_user_session_path) }
			end

			describe "submitting to the destroy action" do
				before { delete dream_path(FactoryGirl.create(:dream)) }
				specify { expect(response).to redirect_to(new_user_session_path) }
			end
		end
	end

	describe "Microposts" do

		describe "for incorrect users" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user) }
			let(:dream) { FactoryGirl.create(:dream, user: user) }

			before { sign_in wrong_user }

			describe "editing dream" do
				before { visit edit_dream_path(dream.id) }

				it { should_not have_content("Edit dream") }
			end
		end
	end
end