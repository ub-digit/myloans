class V1::UsersController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def show
    begin
      user_id = params[:id]
      user = GundaApi.find_user(user_id)
      render json: {user: user}, status: 200
    rescue => error 
      render json: {error: error}, status: 404
    end
  end
end