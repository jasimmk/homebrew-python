require 'formula'

class Django < Formula
  homepage 'https://www.djangoproject.com/'
  url 'https://github.com/django/django/archive/1.6.tar.gz'
  sha1 '9686e54a37de83755d76cbfeeacdc3e20c88b608'

  head 'https://github.com/django/django.git', :branch => :master

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
      system python, "setup.py", "install", "--prefix=#{prefix}"
    end

    Dir["#{bin}/*"].each do |bin_file|
      wrap bin_file, python.site_packages
    end
  end
end
