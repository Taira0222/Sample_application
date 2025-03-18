require "test_helper"

class SessionsHelperTest <ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do # セッションが存在しない状態でもcookiesからユーザーを正しく取得できるか
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil whenre member digest is wrong" do # 不正なremember_digest（＝DB側のトークンのハッシュ値）になった場合にユーザーが認識されないか
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end