class V1::UsersController < ApplicationController

  # Returns a full user object including child elements
  def show

    unless authenticate_user
      render json: {message: "Invalid credentials, must give valid username and password"}, status: 401
    end

    user_id = params[:username]
    user = GundaApi.find_user(user_id)
    render json: {user: user}, status: 200

  end

  # Authenticates user by given credentials
  def authenticate
    success = authenticate_user

    if success
      render json: {authenticated: true}, status: 200
    else
      render json: {authenticated: false}, status: 401
    end
  end

  # Cancels a request for current user
  def cancel_request
    unless authenticate_user
      render json: {message: "Invalid credentials, must give valid username and password"}, status: 401
    end

    if GundaApi.cancel_request(barcode: params[:username], request_id: params[:request_id])
      render json: {success: true}, status: 200
    else
      render json: {success: false}, status: 400
    end

  end

  def renew
    unless authenticate_user
      render json: {message: "Invalid credentials, must give valid username and password"}, status: 401
    end
    checkout = GundaApi.renew(barcode: params[:username], checkout_id: params[:checkout_id])
    if !checkout.nil?
      render json: {success: true, checkout: checkout}, status: 200
    else
      render json: {success: false}, status: 400
    end
  end

  # Updates user attributes
  def update
    unless authenticate_user
      render json: {message: "Invalid credentials, must give valid username and password"}, status: 401
    end

    if GundaApi.update_user(User.permitted_params(params))
      render json: {success: true}, status: 200
    else
      render json: {success: false}, status: 400
    end
  end

  private
  def authenticate_user
    GundaApi.authenticate_user(username: params[:username], password: params[:password])
  end

end