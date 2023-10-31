class CommentsController < ApplicationController
  def index
    @comments = Comment.all
    render status: :ok
  end

  def show
    @comment = Comment.find(params[:id])
    render status: :ok
  end
end
