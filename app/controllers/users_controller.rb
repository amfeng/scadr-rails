class UsersController < ApplicationController

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    # FIXME: Why do I need to do this?
    @user.username = params[:user][:username]
    if @user.save
      flash[:notice] = "Your account \"#{@user.username}\" has been created!"
      redirect_to @user
    else
      render :action => :new
    end
  end

  def show
    @user = User.find(:first, :conditions => { :username => params[:id] })
    @thoughts = @user.get_thoughts
  end

end
