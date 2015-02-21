Sequel.migration do
	change do
		drop_column :builds, :update_timestamp
		drop_column :repomans, :update_timestamp
	end
end
