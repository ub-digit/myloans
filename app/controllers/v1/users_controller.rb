class V1::UsersController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def show

    unless authenticate_user
      render json: {message: "Invalid credentials, must give valid username and password"}, status: 401
    end

    user_id = params[:username]
    user = GundaApi.find_user(user_id)
    render json: {user: user}, status: 200

  end

  def authenticate
    success = authenticate_user

    if success
      render json: {authenticated: true}, status: 200
    else
      render json: {authenticated: false}, status: 401
    end
  end

  private
  def authenticate_user
    GundaApi.authenticate_user(username: params[:username], password: params[:password])
  end

end