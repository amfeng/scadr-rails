class UserSessionsController < ApplicationController
  def new
    redirect_to user_path(current_user_session.user) if current_user_session
    @user_session = UserSession.new
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      session[:username] = @user_session.username
      flash[:notice] = "Logged in as #{@user_session.username}."
      redirect_to @user_session.user
    else
      flash[:error] = "Failed to log in."
      render :action => :new
    end
  end

  def destroy
    if current_user_session.destroy
      session[:username] = nil
      flash[:notice] = "You are now logged out."
    else
      flash[:error] = "Failed to log out."
    end
    redirect_to root_path
  end
end
