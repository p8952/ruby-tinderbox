Sequel.migration do
	change do
		add_column :builds, :update_timestamp, String
		add_column :builds, :portage_timestamp, String
		add_column :repomans, :update_timestamp, String
		add_column :repomans, :portage_timestamp, String
	end
end
