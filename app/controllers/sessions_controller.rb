class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase) # @userとしたのは,integrationテスト時に使用するため。Rails Tutorial p.503を参照
    if @user&.authenticate(params[:session][:password]) # そのuserのPWが正しいか
      reset_session #session id を更新してセッション固定を防止
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      log_in @user
      redirect_to @user
    else
    # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' 
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in? # ログインした状態でないとログアウトできないように設定 詳細はRails Tutorial p.486 
    redirect_to root_url, status: :see_other
  end
end
