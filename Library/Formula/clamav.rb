require 'formula'

class Clamav < Formula
  homepage 'http://www.clamav.net/'
  url 'http://downloads.sourceforge.net/clamav/clamav-0.97.6.tar.gz'
  sha1 '528f774b14b95fdfb8b377f8b41859c48b165e34'

  def patches
    # Patches to fix runtime abort bug in clamd on PowerPC.
    # See: https://wwws.clamav.net/bugzilla/show_bug.cgi?id=1921
    "https://wwws.clamav.net/bugzilla/attachment.cgi?id=1243"
  end

  def install
    args = %W{--disable-dependency-tracking
              --prefix=#{prefix}
              --disable-zlib-vcheck
              --libdir=#{lib}}
    args << "--with-zlib=#{MacOS.sdk_path}/usr" unless MacOS::CLT.installed?

    system "./configure", *args
    system "make install"
  end
end
