class PostsController < ApplicationController
  load_and_authorize_resource
  layout 'standard'
  def index
    @user = User.find(params[:user_id])
    @posts = Post.where(author_id: params[:user_id]).order(id: :asc)
    @posts = @posts.paginate(page: params[:page], per_page: 5)
  end

  def show
    @user = User.find(params[:user_id])
    @post = Post.includes(:author, :comments, :likes).find_by(author_id: @user.id, id: params[:id])
    if @post
      @comment = Comment.new
      @like = Like.new
    else
      flash[:alert] = 'Post not found!'
      redirect_to user_post_path(@user, params[:id])
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.author = current_user
    if @post.save
      flash[:success] = 'Post created successfully!'
      redirect_to user_posts_url
    else
      flash.now[:error] = 'Error: Post could not be created!'
      render :new, locals: { post: @post }
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.author.decrement!(:posts_counter)
    @post.destroy!
    flash[:success] = 'Post was deleted successfully!'
    redirect_to user_posts_url
  end

  private

  def post_params
    params.require(:post).permit(:title, :text)
  end
end
