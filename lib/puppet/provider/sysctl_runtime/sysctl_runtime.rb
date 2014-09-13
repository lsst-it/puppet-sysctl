Puppet::Type.type(:sysctl_runtime).provide(:sysctl_runtime,
                                    :parent => Puppet::Provider
                                   ) do
  desc "This provider changes the runtime values of kernel parameters"

  [ "/sbin/sysctl",
  "/bin/sysctl",
  "/usr/sbin/sysctl",
  "/usr/bin/sysctl"].each do |sysctl_command|
    if File.exists?(sysctl_command)
      commands :sysctl => sysctl_command
      @sysctl_exec_command = sysctl_command
      break
    end
  end

  mk_resource_methods

  def self.instances
    #we don't use here the sysctl command to be able 
    #to disable combining of stderr/stdout output. 
    #Sysctl produces mixed output in case of error, 
    #and it can't be parsed.
    #https://ask.puppetlabs.com/question/6299/combine-false-for-provider-commands/
    output = Puppet::Util.execute(@sysctl_exec_command+" -a", {
      :failonfail         => true,
      :combine            => false,
      :custom_environment => {}
    })
    output.split("\n").collect do |line|
      name, val = line.split(' = ')
      new( 
        :name => name,
        :val  => val
      )
    end
  end

  def self.prefetch(resources)
    sysctl_flags = instances
    resources.keys.each do |res|
      if provider = sysctl_flags.find{ |sres| sres.name == res }
        resources[res].provider = provider
      else
        raise(Puppet::ParseError, "sysctl parameter #{res} wasn't found on this system")
      end
    end
  end

  def val=(value)
    sysctl("#{resource[:name]}=#{value}")
  end

end
