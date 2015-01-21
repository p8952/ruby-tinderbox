Sequel.migration do
	change do
		create_table :packages do
			primary_key :id
			String :category
			String :name
			String :version
			String :slot
			String :r19_target
			String :r20_target
			String :r21_target
		end
	end
end
