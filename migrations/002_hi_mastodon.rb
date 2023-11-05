Sequel.migration do
  change do
    add_column :tweets, :kind, :string
    add_column :tweets, :host, :string
    from(:tweets).update(kind: 'twitter')
    from(:tweets).update(host: "twitter.com")
  end
end
