class ThoughtsController < ApplicationController
  def new
    @owner = User.find_user(params[:user_id])
    @thought = Thought.new
  end

  def create
    @thought = Thought.new params[:thought]
    @thought.owner = current_user.username
    @thought.timestamp = Time.now.to_i
    if @thought.save
      flash[:notice] = "New thought created."
      redirect_to user_path(current_user)
    else
      flash[:error] = "Save failed."
      render :action => :new
    end
  end

  def edit
  end

  # def show
  #   @owner = User.find_user(params[:user_id])
  #   @thought = Thought.find_thought(params[:user_id], params[:id])
  # end

end
