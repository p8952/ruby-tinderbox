Sequel.migration do

	change do
		add_column :packages, :r22_target, String
	end

end
