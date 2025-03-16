module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end   
   # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id]= user.id
    cookies.permanent[:remember_token] =user.remember_token
  end

    # 記憶トークンcookie に対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id]) # 今まで通り、ログインしている際にはsessionがまだ有効なので@current_userをsessionからできる。　かっこにしているのは、比較(==)出ないことを明示するため
      @current_user ||= User.find_by(id: user_id) # @current_userがtrueなら@current_userを、falseなら@current_user= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id]) # ブラウザ再訪問時にはセッションがないため、cookiesを使用してcurrent_userを設定する
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token]) # DBのremeber_digestとcookieのremember_tokenが等しいか確認
        log_in user
        @current_user = user
      end
    end
  end

   #ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続セッションを破棄する
  def forget(user)
    user.forget # DB上のremeber_digestをnilにする
    cookies.delete(:user_id) # cookiesのuser_idを削除
    cookies.delete(:remember_token) # cookiesのremember_tokenを削除
  end


   #現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil #安全のため
  end
end
