class CreateLeagues < ActiveRecord::Migration[5.1]
  def change
    create_table :leagues do |t|
      t.string :name,                                               
                null: false
      t.string :entry_fee,              
                default: 'free',            
                null: false
      t.string :commissioner,                                       
                null: false
      t.string :mode,                  
                default: "Fantasy Friendly", 
                null: false
      t.datetime :start_date,          
                default: DateTime.now,       
                null: false
      t.datetime :end_date,            
                default: 1.month.from_now,   
                null: false
      t.integer :rounds,               
                default: 1,                  
                null: false
      t.boolean :exchange_risk,        
                default: false,              
                null: false
      t.boolean :exchange_fees,        
                default: false,              
                null: false
      t.boolean :high_be_score,        
                default: true,               
                null: false
      t.boolean :public_keys,          
                default: false,              
                null: false
      t.boolean :instant_deposits_withdraws, 
                default: true,         
                null: false
      t.boolean :lazy_picker,          
                default: false,              
                null: false
      t.boolean :margin_trading,       
                default: false,              
                null: false
      t.timestamps
    end
  end
end
