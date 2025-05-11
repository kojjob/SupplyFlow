class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :activate, :deactivate, :reset_password ]

  def index
    authorize User
    @users = policy_scope(User).where(organization: current_user.organization).order(created_at: :desc)
  end

  def show
    authorize @user
  end

  def new
    @user = User.new(organization: current_user.organization)
    authorize @user
  end

  def create
    @user = User.new(user_params)
    @user.organization = current_user.organization
    @user.created_by = current_user

    # Generate a random password if not provided
    @user.password = SecureRandom.hex(8) if @user.password.blank?

    authorize @user

    if @user.save
      # Log the activity
      current_user.log_activity("user.created", { user_id: @user.id, user_email: @user.email })

      # Send welcome email with password reset instructions
      # @user.send_reset_password_instructions

      redirect_to users_path, notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(user_params)
      # Log the activity
      current_user.log_activity("user.updated", { user_id: @user.id, user_email: @user.email })

      redirect_to users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user

    if @user.destroy
      # Log the activity
      current_user.log_activity("user.deleted", { user_id: @user.id, user_email: @user.email })

      redirect_to users_path, notice: "User was successfully deleted."
    else
      redirect_to users_path, alert: "Unable to delete user."
    end
  end

  def activate
    authorize @user, :activate?

    if @user.update(active: true)
      # Log the activity
      current_user.log_activity("user.activated", { user_id: @user.id, user_email: @user.email })

      redirect_to users_path, notice: "User was successfully activated."
    else
      redirect_to users_path, alert: "Unable to activate user."
    end
  end

  def deactivate
    authorize @user, :deactivate?

    if @user.update(active: false)
      # Log the activity
      current_user.log_activity("user.deactivated", { user_id: @user.id, user_email: @user.email })

      redirect_to users_path, notice: "User was successfully deactivated."
    else
      redirect_to users_path, alert: "Unable to deactivate user."
    end
  end

  def reset_password
    authorize @user, :reset_password?

    # Generate a new password
    new_password = SecureRandom.hex(8)

    if @user.update(password: new_password)
      # Log the activity
      current_user.log_activity("user.password_reset", { user_id: @user.id, user_email: @user.email })

      # Send password reset email
      # UserMailer.password_reset(@user, new_password).deliver_later

      redirect_to users_path, notice: "Password was reset to: #{new_password}"
    else
      redirect_to users_path, alert: "Unable to reset password."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :phone_number, :role, :active, :password, :password_confirmation)
  end
end
