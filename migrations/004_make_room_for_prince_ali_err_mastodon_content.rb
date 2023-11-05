Sequel.migration do
  change do
    add_column :updates, :raw, :string # Store the whole response
    add_column :updates, :html, :string # Store the html from mastodon
  end
end
