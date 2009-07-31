# To demonstrate the ActiveRecordLoader, here is a migration and a subclass.
class CreateForestFires < ActiveRecord::Migration
  def self.up
    create_table :forest_fires do |t|
      t.integer :x
      t.integer :y
      t.string :month
      t.string :day
      t.decimal :ffmc
      t.decimal :dmc
      t.decimal :dc
      t.decimal :isi
      t.decimal :temp
      t.integer :rh
      t.decimal :wind
      t.decimal :rain
      t.decimal :area

      t.timestamps
    end
  end

  def self.down
    drop_table :forest_fires
  end
end

# Builds on the CSVET class to find and extract a CSV file from the Internet.
class ForestFireETL < ActiveRecordLoader
  
  protected
    def extract
      processor = CSVET.process(self.options)
      @raw = processor.data
    end
end

# To use this:
# ff = ForestFireETL.process(
#   :source => 'http://archive.ics.uci.edu/ml/machine-learning-databases/forest-fires/forestfires.csv',
#   :class => ForestFire
# )
