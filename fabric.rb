require 'formula'

class Fabric < Formula
  homepage 'http://fabfile.org/'
  url 'https://github.com/fabric/fabric/archive/1.8.3.tar.gz'
  sha1 '2f571496966b28940131079c9ed003efe4f990d8'

  head 'https://github.com/fabric/fabric.git', :branch => :master

  depends_on :python

  resource 'paramiko' do
    url 'https://pypi.python.org/packages/source/p/paramiko/paramiko-1.12.3.tar.gz'
    sha1 'b385e3e5153199e1af2aea972db2c4c81b3c94b7'
  end

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'

    install_args = [ "setup.py", "install", "--prefix=#{libexec}" ]

    resource('paramiko').stage { system "python", *install_args }

    system "python", "setup.py", "install"
    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/fab", "--version"
  end
end
