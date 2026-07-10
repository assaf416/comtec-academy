class CreateBrandThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :brand_themes do |t|
      t.string :primary_color
      t.string :accent_color
      t.string :text_color
      t.string :background_color
      t.string :heading_font
      t.string :body_font

      t.timestamps
    end
  end
end
