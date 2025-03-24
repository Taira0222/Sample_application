class User < ApplicationRecord 
  attr_accessor :remember_token, :activation_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  class << self
    #渡された文字列のハッシュ値を返す
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost:cost)
    end

    # ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest # 返り値としてremember_digestを設定
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember # remember_digestがtrueならremember_digestを、remember_digestがfalseならrememberを返り値に設定
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token) 
    return false if remember_digest.nil? # これがないとremember_digestがnilの際に例外が発生
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil) 
  end

  private

    # メールアドレスをすべて小文字化にする
    def downcase_email
      email.downcase!
    end

    # 有効化トークンとダイジェストを作成、代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
