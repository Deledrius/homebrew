require 'formula'

class Liboil < Formula
  homepage 'http://liboil.freedesktop.org/'
  url 'http://liboil.freedesktop.org/download/liboil-0.3.17.tar.gz'
  sha1 'f9d7103a3a4a4089f56197f81871ae9129d229ed'

  depends_on 'pkg-config' => :build
  depends_on 'glib'

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make"
    system "make install"
  end
end
