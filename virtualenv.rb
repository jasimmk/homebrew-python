require 'formula'

class Virtualenv < Formula
  homepage 'http://www.virtualenv.org/'
  url 'https://github.com/pypa/virtualenv/archive/1.11.4.tar.gz'
  sha1 '123c425bf6bf8f8e9320e5fe0c544b33b48c50c0'

  head 'https://github.com/pypa/virtualenv.git', :branch => :develop

  depends_on :python

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'

    system "python", "setup.py", "install"
    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/virtualenv", "--version"
  end
end
