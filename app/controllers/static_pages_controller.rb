class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end

  def graph
  end

  def search
    @searchitems = PgSearch.multisearch(params[:query])
    @dream_items = @searchitems.where(searchable_type: "Dream")
    @dreams = []
    @dream_items.each do |dream_item|
      @dreams.push(Dream.find(dream_item.searchable_id))
    end
    @users = []
    @user_items = @searchitems.where(searchable_type: "User")
    @user_items.each do |user_item|
      @users.push(User.find(user_item.searchable_id))
    end

  end

end
