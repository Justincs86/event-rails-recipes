class AddRowOrderToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :row_order, :integer

    # because using row_order for orderize, events default is nil in database
    # so set row_order, and ":last" is ranked-model
    Event.find_each do |e|
      e.update( :row_order_position => :last )
    end

    add_index :events, :row_order
    
  end
end
