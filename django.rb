require 'formula'

class Django < Formula
  homepage 'https://www.djangoproject.com/'
  url 'https://github.com/django/django/archive/1.6.3.tar.gz'
  sha1 '7786fadfd28bdb55b7a13aeb23562b756959b1ce'

  head 'https://github.com/django/django.git', :branch => :master

  depends_on :python

  def install
    ENV.prepend_create_path 'PYTHONPATH', libexec+'lib/python2.7/site-packages'
    system "python", "setup.py", "install", "--prefix=#{prefix}"

    bin.env_script_all_files(libexec+'bin', :PYTHONPATH => ENV['PYTHONPATH'])
  end

  test do
    system "#{bin}/django-admin.py", "--version"
  end
end
