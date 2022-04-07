class CreateManagementIncomes < ActiveRecord::Migration[7.0]
  def change
    create_table :management_incomes do |t|
      t.integer :amount
      t.timestamps
    end
  end
end
