class ArticlesController < ApplicationController
	before_filter :admin_user, except: [:show, :index]

	def index
		if current_user && current_user.admin?
			@articles = Article.paginate(page: params[:page], per_page: 10).order('created_at DESC')
		else
			@articles = Article.where(published: true).paginate(page: params[:page], per_page: 10).order('created_at DESC')
		end
	end

	def show
		@article = Article.find(params[:id])
		@commentable = @article
	end

	def new
		#@article = current_user.articles.build
		@article = Article.new
		respond_to do |format|
			format.html
			format.js
		end
	end	

	def create
		#@article = current_user.articles.build(article_params)
		@article = Article.new(article_params)

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
			params.require(:article).permit(:title, :body, :published, :author, :publish_date)
		end

		def admin_user
			redirect_to root_url unless current_user.admin?
		end

end