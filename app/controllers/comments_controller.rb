class CommentsController < ApplicationController
  def index
    @comments = Comment.all
    render status: :ok
  end

  def show
    @comment = Comment.find(params[:id])
    render status: :ok
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      render json: @comment, status: :created
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
