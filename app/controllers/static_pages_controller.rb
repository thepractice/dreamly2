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
    @dreams = []
    @dream_items = @searchitems.where(searchable_type: "Dream")

    if params[:impression].present?   
      @dream_items.each do |dream_item|
        if Dream.find(dream_item.searchable_id).impression >= params[:impression].to_f
          @dreams.push(Dream.find(dream_item.searchable_id))
        end
      end
    else
      @dream_items.each do |dream_item|
        @dreams.push(Dream.find(dream_item.searchable_id))
      end
    end

    @users = []
    @user_items = @searchitems.where(searchable_type: "User")
    @user_items.each do |user_item|
      @users.push(User.find(user_item.searchable_id))
    end

  end

end
