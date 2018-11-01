# frozen_string_literal: true

class Grvpc::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  skip_before_action :verify_authenticity_token, :only => [:destroy]

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  #def create
  #  super
  #end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password, :remember_me])
  end

  # The path used after sign in.
  def after_sign_in_path_for(resource)
    super(resource)
    grvpc_index_path
  end
end
