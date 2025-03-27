class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  # パスワード再設定の有効期限が切れていないかの対応


  def new
  end
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] ="Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger]= "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty? # （3）への対応　 新しいパスワードと確認用パスワードが空文字列になっていないか
      @user.errors.add(:password, :blank)
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params) # （4）への対応   新しいパスワードが正しければ、更新する
      @user.forget # 二次セッションをnilにする
      reset_session # 一次セッションをリセットする
      log_in @user
      @user.update_attribute(:reset_digest,nil) # PW変更に使用するためなので、ログイン後はreset_diigestは不要。詳細はp.676 
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity # （2）への対応　 無効なパスワードであれば失敗させる（失敗した理由も表示する）
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # before フィルタ

    def get_user
      @user = User.find_by(email: params[:email])
    end

    #正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset,params[:id]))
        redirect_to root_url
      end
    end

    # 期限切れかどうかを確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
