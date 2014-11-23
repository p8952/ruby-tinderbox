class String
	def camelcase(delimiter = ' ')
		split(delimiter).map(&:capitalize).join(delimiter)
	end
end
