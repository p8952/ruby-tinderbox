Sequel.migration do
	change do
		add_column :packages, :update_timestamp, String
		add_column :packages, :portage_timestamp, String
	end
end
