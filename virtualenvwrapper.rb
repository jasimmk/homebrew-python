require 'formula'

class Pbr < Formula
  url 'https://pypi.python.org/packages/source/p/pbr/pbr-0.5.21.tar.gz'
  sha1 'ff569c2f062b97f81f50db89a43720d656fc8142'
end

class Virtualenvwrapper < Formula
  homepage 'http://www.doughellmann.com/docs/virtualenvwrapper/'
  url 'https://pypi.python.org/packages/source/v/virtualenvwrapper/virtualenvwrapper-4.1.1.tar.gz'
  sha1 '7ada69293fbc28a8bd7e911031c9de991624e12f'

  head 'https://bitbucket.org/dhellmann/virtualenvwrapper.git', :branch => :master

  depends_on :python
  depends_on 'virtualenv'

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
      Pbr.new.brew { system python, *install_args }
      system python, "setup.py", "install", "--prefix=#{prefix}"
    end
  end

  def caveats; <<-EOS.undent
    You will need to add the following to your shell startup file:

        source #{bin}/virtualenvwrapper.sh
    EOS
  end
end
