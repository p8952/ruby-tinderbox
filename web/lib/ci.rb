def run_ci(num_of_packages, provisioner)
	packages = []
	Package.order { [category, lower(name), version] }.each do |package|
		packages << package[:identifier]
	end

	if num_of_packages == :all
		packages = packages
	elsif num_of_packages == :daily
		packages_per_day = ((packages.length.to_f / 7).ceil)
		packages = packages[(Time.now.wday * packages_per_day)..((Time.now.wday * packages_per_day) + packages_per_day)]
	elsif num_of_packages == 0
		packages = packages.sample(5)
	elsif num_of_packages == :untested
		packages = []
		Package.exclude(tested: true).order { [category, lower(name), version] }.each do |package|
			packages << package[:identifier]
			Package.where(Sequel.like(
				:dependencies,
				"#{package[:category]}/#{package[:name]} %",
				"% #{package[:category]}/#{package[:name]} %",
				"% #{package[:category]}/#{package[:name]}",
			)).each do |rdep|
				packages << rdep[:identifier]
			end
		end
	else
		packages = packages.sample(num_of_packages)
	end

	exit if packages.empty?
	
	begin
		vagrant_path = File.dirname(File.dirname(File.expand_path(File.dirname(__FILE__))))
		vagrant = Vagrant_Rbapi.new(vagrant_path)
		vagrant.up(provisioner)
		sleep 5 while vagrant.status != 'running'
		vagrant.ssh('sudo /vagrant/tinder.sh ' + packages.join(' '))
		vagrant.scp(:download, true, '/vagrant/ci-logs', 'web')
	ensure
		vagrant.destroy
	end
end

def update_ci
	Dir.glob('ci-logs/*/*/*') do |build|
		build_array = build.split('/')
		package_id = "#{build_array[1]}/#{build_array[2]}"
		time = build_array[3]

		if File.exist?("#{build}/succeeded")
			result = 'succeeded'
		elsif File.exist?("#{build}/failed")
			result = 'failed'
		elsif File.exist?("#{build}/timedout")
			result = 'timed out'
		end

		emerge_info = File.read("#{build}/emerge-info") if File.exist?("#{build}/emerge-info")
		emerge_pqv = File.read("#{build}/emerge-pqv") if File.exist?("#{build}/emerge-pqv")
		build_log = File.read("#{build}/build.log") if File.exist?("#{build}/build.log")
		environment = File.read("#{build}/environment") if File.exist?("#{build}/environment")

		Build.find_or_create(
			package_id: package_id,
			time: time,
			result: result,
			emerge_info: emerge_info,
			emerge_pqv: emerge_pqv,
			build_log: build_log,
			environment: environment
		)
	end
	Build.each do |build|
		Package.where(identifier: build[:package_id]).update(tested: true)
	end
end

def clear_ci
	Build.map(&:delete)
end
