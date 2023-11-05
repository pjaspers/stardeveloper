Sequel.migration do
  up do
    create_table?(:tweets) do
      primary_key :id
      String :name
      String :text
      Time :posted_at
      String :tweet_id
    end
  end

  down do
    drop_table(:tweets)
  end
end
