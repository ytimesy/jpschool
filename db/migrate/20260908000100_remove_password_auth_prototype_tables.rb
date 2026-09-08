class RemovePasswordAuthPrototypeTables < ActiveRecord::Migration[8.1]
  def up
    # This version previously existed only as an uncommitted local prototype.
    # Keep the migration ID so local databases do not show "NO FILE", but do
    # not drop generic table names in shared environments.
  end

  def down
    # Password authentication prototype tables are intentionally not recreated.
  end
end
