Sequel.migration do

	change do
		add_column :packages, :gem_version, String
	end

end
