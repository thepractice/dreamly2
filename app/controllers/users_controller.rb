class UsersController < ApplicationController

	def show
		@user = User.find(params[:id])
		@dreams = @user.dreams.paginate(page: params[:page])
	end
end