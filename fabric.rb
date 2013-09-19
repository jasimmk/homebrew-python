require 'formula'

class Paramiko < Formula
  url 'https://pypi.python.org/packages/source/p/paramiko/paramiko-1.11.0.tar.gz'
  sha1 'fd925569b9f0b1bd32ce6575235d152616e64e46'
end

class Fabric < Formula
  homepage 'http://fabfile.org/'
  url 'https://github.com/fabric/fabric/archive/1.7.0.tar.gz'
  sha1 'c07421da74bf099497496ed3838eb9f6d46608e2'

  head 'https://github.com/fabric/fabric.git', :branch => :master

  depends_on :python

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
      Paramiko.new.brew { system python, *install_args }

      # The "main" fabric module is installed in the default location and
      # in order for it to be usable, we add the private_site_packages
      # to the __init__.py of fabric so the deps (Paramiko, etc) are found.
      inreplace 'fabric/__init__.py' do |s|
        s.gsub! /\.\n(""")/, "\"\"\"\nimport site; site.addsitedir('#{python.private_site_packages}')"
      end

      system python, "setup.py", "install", "--prefix=#{prefix}",
                                            "--single-version-externally-managed",
                                            "--record=installed.txt"
    end

    Dir["#{bin}/*"].each do |bin_file|
      wrap bin_file, python.private_site_packages
    end
  end
end
