class AddFiscalYearStartToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :fiscal_year_start, :string, default: "1"
  end
end
