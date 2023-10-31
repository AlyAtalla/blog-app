class LikesController < ApplicationController
  def index
    @likes = Like.all
    render status: :ok
  end

  def show
    @like = Like.find(params[:id])
    render status: :ok
  end
end
