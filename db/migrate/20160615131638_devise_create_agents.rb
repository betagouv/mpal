class DeviseCreateAgents < ActiveRecord::Migration[4.2]
  def change
    create_table :agents do |t|
      ## CAS authenticatable
      t.string :username, :null => false

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet     :current_sign_in_ip
      t.inet     :last_sign_in_ip

      t.timestamps null: false
    end

    add_index :agents, :username,             unique: true
  end
end
