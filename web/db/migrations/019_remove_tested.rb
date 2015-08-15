Sequel.migration do
	change do
		drop_column :packages, :tested
	end
end
