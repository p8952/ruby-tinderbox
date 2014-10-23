class String
	def camelcase(delimiter=" ")
		self.split(delimiter).map(&:capitalize).join(delimiter)
	end
end
