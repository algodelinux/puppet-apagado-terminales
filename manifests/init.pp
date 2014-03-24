class puppet-apagado-terminales {

   file { 
      "/usr/sbin/apagaterminales.sh" :
      source => "puppet://puppetinstituto/puppet-apagado-terminales/apagaterminales.sh",
      owner => root, group => root, mode => 750
   }

   file {
      "/opt/ltsp/i386/root/.ssh" :
      ensure => directory, owner => root,  group => root, mode => 700,
   }

   file { "/root/.ssh/id_rsa.pub":
           ensure => file, owner => "root", group => "root", mode => "644",
   }

   file {
      "/root/.ssh/known_hosts" :
      ensure => file, owner => root,  group => root, mode => 644,
   }

   exec { "/usr/bin/ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa":
        unless => "/usr/bin/test -f /root/.ssh/id_rsa",
        notify => Exec["copy-publickey"]
   }

   exec { "copy-publickey":
        command => "/bin/cat /root/.ssh/id_rsa.pub >> /opt/ltsp/i386/root/.ssh/authorized_keys",
	require => [File["/root/.ssh/id_rsa.pub"], File["/opt/ltsp/i386/root/.ssh"]],
        unless => '/bin/grep "$fqdn" /opt/ltsp/i386/root/.ssh/authorized_keys 2>/dev/null',
        notify => Exec["update-image"]
   }

   exec { "update-image":
        command => "/usr/sbin/ltsp-update-image --arch i386",
        path => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
        refreshonly => true
       }

   exec { '/bin/sed -i -e "s/exit 0/\/usr\/sbin\/apagaterminales.sh \&\n\nexit 0/g" /etc/gdm3/PostSession/Default':
        unless => '/bin/grep "apagaterminales" /etc/gdm3/PostSession/Default 2>/dev/null'
   }

   file {
      "/etc/init.d/halt-terminales" :
      source => "puppet://puppetinstituto/puppet-apagado-terminales/halt-terminales",
      owner => root, group => root, mode => 750
   }

   exec { "/bin/ln -sf /etc/init.d/halt-terminales /etc/rc0.d/K01aapaga-terminales":
      unless => "/usr/bin/test -L /etc/rc0.d/K01aapaga-terminales"
   }

   exec { "/bin/ln -sf /etc/init.d/halt-terminales /etc/rc6.d/K01aapaga-terminales":
      unless => "/usr/bin/test -L /etc/rc6.d/K01aapaga-terminales"
   }

}
