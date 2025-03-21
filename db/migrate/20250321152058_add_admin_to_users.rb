class AddAdminToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :admin, :boolean, default: false # defaultの初期値はnilだが、明示的にfalseと書いている
  end
end
