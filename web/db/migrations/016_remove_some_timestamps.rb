Sequel.migration do
	change do
		drop_column :builds, :portage_timestamp
		drop_column :repomans, :portage_timestamp
	end
end
