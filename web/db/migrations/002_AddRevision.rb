Sequel.migration do

	change do
		add_column :packages, :revision, String
	end

end
