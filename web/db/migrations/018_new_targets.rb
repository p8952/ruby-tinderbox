Sequel.migration do
	change do
		add_column :packages, :sha1, String
		add_column :builds, :target, String
		add_column :repomans, :target, String
		rename_column :builds, :time, :timestamp
		rename_column :repomans, :time, :timestamp
		rename_column :repomans, :current_result, :result
		rename_column :repomans, :current_log, :log
		drop_column :repomans, :next_result
		drop_column :repomans, :next_log
		drop_column :builds, :package_id
		drop_column :repomans, :package_id
		alter_table(:builds) do
			add_foreign_key :package_id, :packages
		end
		alter_table(:repomans) do
			add_foreign_key :package_id, :packages
		end
	end

end
