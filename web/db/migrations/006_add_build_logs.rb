Sequel.migration do
	change do
		add_column :builds, :emerge_info, String
		add_column :builds, :emerge_pqv, String
		add_column :builds, :build_log, String
		add_column :builds, :environment, String
	end
end
