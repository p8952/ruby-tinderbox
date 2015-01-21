Sequel.migration do
	change do
		add_column :packages, :amd64_keyword, String
	end
end
