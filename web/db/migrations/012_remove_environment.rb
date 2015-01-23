Sequel.migration do
	change do
		drop_column :builds, :environment
	end
end
