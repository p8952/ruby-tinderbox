Sequel.migration do
	change do
		add_column :packages, :next_target, String
	end
end
