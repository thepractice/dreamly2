require 'spec_helper'

describe User do
  
  let(:user) { FactoryGirl.create(:user) } 

  subject { user }

  it { should respond_to(:dreams) }

  describe "dream associations" do
  	before { user.save }
  	let!(:first_dream) do
  		FactoryGirl.create(:dream, user: user, created_at: 1.day.ago)
  	end
  	let!(:second_dream) do
  		FactoryGirl.create(:dream, user: user, created_at: 1.hour.ago)
  	end

  	it "should destroy associated dreams" do
  		dreams = user.dreams.to_a
  		user.destroy
  		expect(dreams).not_to be_empty
  		dreams.each do |dream|
  			expect(Dream.where(id: dream.id)).to be_empty
  		end
  	end
  end
end
