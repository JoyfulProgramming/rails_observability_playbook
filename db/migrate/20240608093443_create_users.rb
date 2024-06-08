# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :number_of_profile_visits

      t.timestamps
    end
  end
end
