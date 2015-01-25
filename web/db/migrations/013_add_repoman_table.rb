Sequel.migration do
	change do
		create_table :repomans do
			primary_key :id
			String :package_id
			String :time
			String :current_result
			String :current_log
			String :next_result
			String :next_log
		end
	end
end
