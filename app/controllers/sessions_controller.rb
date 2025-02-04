class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase) # 入力されたemailと同じデータがDB内にあるか
    if user && user.authenticate(params[:session][:password]) # そのuserのPWが正しいか
    # ユーザーログイン後にユーザー情報のページにリダイレクトする
      reset_session #session id を更新してセッション固定を防止
      log_in user
      redirect_to user
    else
    # エラーメッセージを作成する
      flash[:danger] = 'Invalid email/password combination' # 本当は正しくない
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
  end
end
