Sequel.migration do
	change do
		drop_column :packages, :r19_target
		add_column :packages, :r23_target, String
	end
end
