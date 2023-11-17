class CommentsController < ApplicationController
  load_and_authorize_resource
  def index
    @user = User.find(params[:user_id])
    @post = @user.posts.find(params[:post_id])
    @comments = @post.comments
    respond_to do |format|
      format.html
      format.json { render json: @comments }
    end
  end
  def create
    post = Post.find(params[:post_id])
    @comment = post.comments.new(author: current_user, **comment_params)
      if @comment.save
        flash[:notice] = 'Comment created successfully!'
        redirect_to user_post_path(post.author, post)
      else
        flash[:alert] = 'Comment was not created!'
      end
  end
  def destroy
    @comment = Comment.find(params[:id])
    post = @comment.post
    if @comment.destroy
      flash[:notice] = 'Comment deleted successfully!'
    else
      flash[:alert] = 'Error deleting the comment!'
    end
    redirect_to user_post_path(post.author, post), status: :see_other
  end
  private
  def comment_params
    params.require(:comment).permit(:text)
  end
end