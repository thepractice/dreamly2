class ArticlesController < ApplicationController
	before_filter :admin_user, except: [:show, :index]

	def index
		@articles = Article.paginate(page: params[:page], per_page: 10).order('created_at DESC')
	end

	def show
		@article = Article.find(params[:id])
	end

	def new
		@article = current_user.articles.build
		respond_to do |format|
			format.html
			format.js
		end
	end	

	def create
		@article = current_user.articles.build(article_params)

		respond_to do |format|
			if @article.save
				flash[:success] = "Article saved."
				format.html { redirect_to @article, notice: "Article saved." }
				format.js { render js: "window.location.href = ('#{help_path}');"}
				format.json { render json: @article, status: :created, location: @article }
			else
				format.html { render 'articles/new' }
				format.json { render json: @article.errors.full_messages, status: :unprocessable_entity }
			end
		end
	end

	def edit
		@article = Article.find(params[:id])
	end

	def update
		@article = Article.find(params[:id])

		respond_to do |format|
			if @article.update_attributes(article_params)
				flash[:success] = "Changes saved"
				format.html { redirect_to @article }
				format.json { render json: @article, location: @article }
			else
				format.html { render 'edit' }
				format.json { render json: @article.errors.full_messages, status: :unprocessable_entity }
			end
		end
	end

	def destroy
		@article.destroy
		redirect_to root_url
	end	


	private

		def article_params
			params.require(:article).permit(:title, :body,:published)
		end

		def admin_user
			redirect_to root_url unless [72, 68, 74].include?(current_user.id)
		end

end