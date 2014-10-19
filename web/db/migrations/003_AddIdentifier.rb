Sequel.migration do

	change do
		add_column :packages, :identifier, String
	end

end
