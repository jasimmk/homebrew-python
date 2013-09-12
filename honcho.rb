require 'formula'

class Jinja < Formula
  url 'https://github.com/mitsuhiko/jinja2/archive/2.7.1.zip'
  sha1 '470da2e98fbc50417f6f1246e3bdfc4f01da7265'
end

class Honcho < Formula
  homepage 'https://pypi.python.org/pypi/honcho'
  url 'https://github.com/nickstenning/honcho/archive/v0.4.2.zip'
  sha1 'bf663b7425c06a0b803dd294a9be190805a7e70d'

  head 'https://github.com/nickstenning/honcho.git', :branch => :master

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
      Jinja.new.brew { system python, *install_args }

      system python, "setup.py", "install", "--prefix=#{prefix}",
                                            "--single-version-externally-managed",
                                            "--record=installed.txt"
    end

    Dir["#{bin}/*"].each do |bin_file|
      wrap bin_file, python.site_packages
    end
  end
end
