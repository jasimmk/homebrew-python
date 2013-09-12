require 'formula'

class Setuptools < Formula
  url 'https://bitbucket.org/pypa/setuptools/get/1.1.4.tar.gz'
  sha1 'f5b306920869637bacdd04d01c2622dc34c7f68a'
end

class Meld3 < Formula
  url 'https://github.com/Supervisor/meld3/archive/0.6.10.tar.gz'
  sha1 '4cf8d608dec33d18c4faa584cb2d69af8ea887d7'
end

class Supervisor < Formula
  homepage 'http://supervisord.org/'
  url 'https://github.com/Supervisor/supervisor/archive/3.0.tar.gz'
  sha1 '5b0976d699d6a2b1ca32f8f07e1257c1e8af42e2'

  head 'https://github.com/Supervisor/supervisor.git', :branch => :master

  depends_on :python

  def patches
    # adds MANIFEST.in file to include needed files.
    DATA
  end

  def supervisord_conf; <<-EOS.undent
    ; Sample supervisor config file.
    ;
    ; For more information on the config file, please see:
    ; http://supervisord.org/configuration.html
    ;
    ; Note: shell expansion ("~" or "$HOME") is not supported.  Environment
    ; variables can be expanded using this syntax: "%(ENV_HOME)s".

    [unix_http_server]
    file=/tmp/supervisor.sock   ; (the path to the socket file)
    ;chmod=0700                 ; socket file mode (default 0700)
    ;chown=nobody:nogroup       ; socket file uid:gid owner
    ;username=user              ; (default is no username (open server))
    ;password=123               ; (default is no password (open server))

    [inet_http_server]         ; inet (TCP) server disabled by default
    port=127.0.0.1:9001        ; (ip_address:port specifier, *:port for all iface)
    ;username=user              ; (default is no username (open server))
    ;password=123               ; (default is no password (open server))

    [supervisord]
    logfile=~/Library/Logs/supervisord.log ; (main log file;default $CWD/supervisord.log)
    logfile_maxbytes=50MB        ; (max main logfile bytes b4 rotation;default 50MB)
    logfile_backups=10           ; (num of main logfile rotation backups;default 10)
    loglevel=info                ; (log level;default info; others: debug,warn,trace)
    pidfile=/tmp/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
    nodaemon=false               ; (start in foreground if true;default false)
    minfds=1024                  ; (min. avail startup file descriptors;default 1024)
    minprocs=200                 ; (min. avail process descriptors;default 200)
    ;umask=022                   ; (process file creation umask;default 022)
    ;user=chrism                 ; (default is current user, required if root)
    ;identifier=supervisor       ; (supervisord identifier, default is 'supervisor')
    ;directory=/tmp              ; (default is not to cd during start)
    ;nocleanup=true              ; (don't clean up tempfiles at start;default false)
    ;childlogdir=/tmp            ; ('AUTO' child log dir, default $TEMP)
    ;environment=KEY=value       ; (key value pairs to add to environment)
    ;strip_ansi=false            ; (strip ansi escape codes in logs; def. false)

    ; the below section must remain in the config file for RPC
    ; (supervisorctl/web interface) to work, additional interfaces may be
    ; added by defining them in separate rpcinterface: sections
    [rpcinterface:supervisor]
    supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

    [supervisorctl]
    serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
    ;serverurl=http://127.0.0.1:9001 ; use an http:// url to specify an inet socket
    ;username=chris              ; should be same as http_username if set
    ;password=123                ; should be same as http_password if set
    ;prompt=mysupervisor         ; cmd line prompt (default "supervisor")
    ;history_file=~/.sc_history  ; use readline history if available

    [include]
    files = supervisor/conf.d/*.conf
    EOS
  end

  plist_options :manual => "supervisord"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{bin}/supervisord</string>
        <string>-n</string>
        <string>-c</string>
        <string>#{etc}/supervisord.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <dict>
          <key>SuccessfulExit</key>
          <false/>
      </dict>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  def wrap bin_file, pythonpath
    bin_file = Pathname.new bin_file
    libexec_bin = Pathname.new libexec/'bin'
    libexec_bin.mkpath
    mv bin_file, libexec_bin
    bin_file.write <<-EOS.undent
      #!/bin/sh
      PYTHONPATH="#{pythonpath}:$PYTHONPATH" "#{libexec_bin}/#{bin_file.basename}" "$@"
    EOS
  end

  def install
    install_args = [ "setup.py", "install", "--prefix=#{libexec}" ]

    python do
      Setuptools.new.brew { system python, *install_args }
      Meld3.new.brew { system python, *install_args }

      system python, "setup.py", "install", "--prefix=#{prefix}",
      "--single-version-externally-managed",
        "--record=installed.txt"
    end

    (prefix+'supervisord.conf').write supervisord_conf

    Dir["#{bin}/*"].each do |bin_file|
      wrap bin_file, python.site_packages
    end

    mv bin.join('supervisord'), prefix
    bin.join('supervisord').write <<-EOS.undent
      #!/usr/bin/env ruby
      ARGV << '-n' unless ARGV.find { |arg|
        arg =~ /\s*\-n$/
      }

      ARGV << '-c' << '#{etc}/supervisord.conf' unless ARGV.find { |arg|
        arg =~ /^\s*\-\-configuration$/ or arg =~ /^\s*\-c$/
      }
      exec "#{prefix}/supervisord", *ARGV
    EOS

    prefix.join("supervisord").chmod(0755)
  end

  def post_install
    (etc+'supervisor/conf.d').mkpath unless File.directory? etc+"supervisor/conf.d"
    cp prefix+'supervisord.conf', etc unless File.exists? etc+"supervisord.conf"
  end
end

__END__
diff --git a/MANIFEST.in b/MANIFEST.in
index e69de29..fc34935 100644
--- a/MANIFEST.in
+++ b/MANIFEST.in
@@ -0,0 +1 @@
+recursive-include supervisor *.txt *.html *.css *.gif
