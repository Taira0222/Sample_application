require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper # full_titleメソッドを使用するため

  def setup
    @user =users(:michael)
  end

  test 'Home display' do # 演習p.821
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select 'strong#following', text: @user.following.count.to_s
    assert_select 'strong#followers', text: @user.followers.count.to_s
    
  end

  test "profile display"do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title',full_title(@user.name)
    assert_select 'h1', text:@user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body # responce.bodyはbody要素だけでなくhtml全体を指す
    assert_select 'div.pagination',count: 1
    assert_select 'strong#following', text: @user.following.count.to_s # 演習p.821
    assert_select 'strong#followers', text: @user.followers.count.to_s # 演習p.821
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end


end
