class CreateEmotions < ActiveRecord::Migration
  def change
    create_table :emotions do |t|
      t.string :name

      t.timestamps
    end

    create_table :dreamemotions do |t|
    	t.belongs_to :dream 
    	t.belongs_to :emotion
    	t.timestamps
    end

    add_index :dreamemotions, :dream_id
    add_index :dreamemotions, :emotion_id
    add_index :dreamemotions, [:dream_id, :emotion_id], unique: true

    add_column :emotions, :dreams_count, :integer, default: 0
    add_index :emotions, :dreams_count

    add_column :users, :emotion_freq, :text
    add_column :users, :emotion_freq_public, :text
  end
end
