require 'formula'

class Virtualenv < Formula
  homepage 'http://www.virtualenv.org/'
  url 'https://github.com/pypa/virtualenv/archive/1.10.1.tar.gz'
  sha1 'f41b3ed5eafedf717457e140a018b1e6b59d7cc0'

  head 'https://github.com/django/django.git', :branch => :develop

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
    python do
      system python, "setup.py", "install", "--prefix=#{prefix}",
                                            "--single-version-externally-managed",
                                            "--record=installed.txt"
    end

    Dir["#{bin}/*"].each do |bin_file|
      wrap bin_file, python.site_packages
    end
  end
end
