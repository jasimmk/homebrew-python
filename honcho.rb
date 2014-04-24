require 'formula'

class Honcho < Formula
  homepage 'https://pypi.python.org/pypi/honcho'
  url 'https://github.com/nickstenning/honcho/archive/v0.5.0.tar.gz'
  sha1 '28f9baf0d529748ae2555115a938f15dbd3c1184'

  head 'https://github.com/nickstenning/honcho.git', :branch => :master

  depends_on :python

  resource 'jinja' do
    url 'https://github.com/mitsuhiko/jinja2/archive/2.7.2.tar.gz'
    sha1 'fc41fbc9270420514fae4d099c7e0e11cd9c64ad'
  end


  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'

    install_args = [ "setup.py", "install", "--prefix=#{libexec}" ]

    resource('jinja').stage { system "python", *install_args }

    system "python", "setup.py", "install"
    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/honcho", "--version"
  end
end
