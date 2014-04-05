require 'spec_helper'

describe "Authentication" do
	
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
end