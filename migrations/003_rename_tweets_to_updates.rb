Sequel.migration do
  up do
    rename_table(:tweets, :updates)
  end

  down do
    rename_table(:updates, :tweets)
  end
end
