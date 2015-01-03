Sequel.migration do

	change do
		add_column :packages, :dependencies, String
	end

end
