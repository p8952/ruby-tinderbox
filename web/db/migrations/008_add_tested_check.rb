Sequel.migration do

	change do
		add_column :packages, :tested, TrueClass
	end

end
