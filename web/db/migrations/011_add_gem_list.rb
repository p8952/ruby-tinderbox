Sequel.migration do
	change do
		add_column :builds, :gem_list, String
	end
end
