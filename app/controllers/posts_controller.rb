class PostsController < ApplicationController
  before_action :set_user, only: %i[index create]
  before_action :set_post, only: %i[show like]

  def index
    @posts = @user.posts
  end

  def show
    @comment = Comment.new
  end

  def create
    @post = @user.posts.build(post_params)
    if @post.save
      redirect_to post_path(@post), notice: 'Post created successfully.'
    else
      render :new
    end
  end

  def like
    @post.likes.create(user: current_user)
    redirect_to post_path(@post), notice: 'Post liked successfully.'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end
end
