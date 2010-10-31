class UsersController < ApplicationController

  # def index
  # end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    # FIXME: Why do I need to do this?
    @user.username = params[:user][:username]
    if @user.save
      flash[:notice] = "Your account \"#{@user.username}\" has been created!"
      session[:usename] = @user.username
      redirect_to @user
    else
      render :action => :new
    end
  end

  def show
    @user = User.find_user(params[:id])
    @thoughts = @user.my_thoughts(10)
    @thoughtstream = @user.thoughtstream(10)
    @can_subscribe = current_user != @user && !current_user.following.include?(@user)
  end

end
