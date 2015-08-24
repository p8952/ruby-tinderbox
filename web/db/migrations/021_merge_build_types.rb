Sequel.migration do
	change do
		drop_column :builds, :target
		add_column :builds, :result_next_target, String
		add_column :builds, :emerge_info_next_target, String
		add_column :builds, :emerge_pqv_next_target, String
		add_column :builds, :build_log_next_target, String
		add_column :builds, :gem_list_next_target, String

		drop_column :repomans, :target
		add_column :repomans, :result_next_target, String
		add_column :repomans, :log_next_target, String
	end
end
