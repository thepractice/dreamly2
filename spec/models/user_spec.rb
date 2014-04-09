require 'spec_helper'

describe User do
  
  let(:user) { FactoryGirl.create(:user) } 

  subject { user }

  it { should respond_to(:dreams) }

  describe "dream associations" do
  	before { user.save }
  	let!(:older_dream) do
  		FactoryGirl.create(:dream, user: user, created_at: 3.day.ago, dreamed_on: 3.day.ago)
  	end
  	let!(:newer_dream) do
  		FactoryGirl.create(:dream, user: user, created_at: 1.hour.ago, dreamed_on: 1.hour.ago)
  	end

    it "should have the right dreams in the right order" do
      expect(user.dreams.to_a).to eq [newer_dream, older_dream]
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
