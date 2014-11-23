Sequel.migration do

	change do
		create_table :builds do
			primary_key :id
			String :package_id
			String :time
			String :result
		end
	end

end
