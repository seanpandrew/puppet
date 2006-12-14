# Manage debian services.  Start/stop is the same as InitSvc, but enable/disable
# is special.
Puppet::Type.type(:service).provide :redhat, :parent => :init do
    desc "Red Hat's (and probably many others) form of ``init``-style service
        management; uses ``chkconfig`` for service enabling and disabling."

    commands :chkconfig => "/sbin/chkconfig"

    defaultfor :operatingsystem => [:redhat, :fedora, :suse]

    def self.defpath
        superclass.defpath
    end

    if self.suitable?
        Puppet.type(:service).newpath(:redhat, defpath())
    end

    # Remove the symlinks
    def disable
        begin
            output = util_execute("#{command(:chkconfig)} #{@model[:name]} off 2>&1")
            output += util_execute("#{command(:chkconfig)} --del #{@model[:name]} 2>&1")
        rescue Puppet::ExecutionFailure
            raise Puppet::Error, "Could not disable %s: %s" %
                [self.name, output]
        end
    end

    def enabled?
        begin
            output = util_execute("#{command(:chkconfig)} #{@model[:name]} 2>&1").chomp
        rescue Puppet::ExecutionFailure
            return :false
        end

        # If it's disabled on SuSE, then it will print output showing "off"
        # at the end
        if output =~ /.* off$/
            return :false
        end
	
        return :true
    end

    # Don't support them specifying runlevels; always use the runlevels
    # in the init scripts.
    def enable
        begin
            output = util_execute("#{command(:chkconfig)} --add #{@model[:name]} 2>&1")
            output += util_execute("#{command(:chkconfig)} #{@model[:name]} on 2>&1")
        rescue Puppet::ExecutionFailure
            raise Puppet::Error, "Could not enable %s: %s" %
                [self.name, output]
        end
    end
end

# $Id$
