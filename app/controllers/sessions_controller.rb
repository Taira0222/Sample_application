class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase) # 入力されたemailと同じデータがDB内にあるか
    if user&.authenticate(params[:session][:password]) # そのuserのPWが正しいか
      reset_session #session id を更新してセッション固定を防止
      log_in user
      redirect_to user
    else
    # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' 
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_url, status: :see_other
  end
end
