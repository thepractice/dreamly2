require 'spec_helper'

describe Dream do
  
  let(:user) { FactoryGirl.create(:user) }
  let(:dream) { user.dreams.build(title: "My title", body: "Lorem ipsum") }
  #before { @dream = user.dreams.build(title: "My title", body: "Lorem ipsum") }

  subject { dream }

  it { should respond_to(:title) }
  it { should respond_to(:body) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is not present" do
  	before { dream.user_id = nil }
  	it { should_not be_valid }
  end

  describe "with blank content" do
  	before { dream.body = " " }
  	it { should_not be_valid }
  end
end
