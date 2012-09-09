require 'formula'

class Mpfr < Formula
  homepage 'http://www.mpfr.org/'
  url 'http://www.mpfr.org/mpfr-3.1.1/mpfr-3.1.1.tar.bz2'
  version '3.1.1-p2'
  sha256 '7b66c3f13dc8385f08264c805853f3e1a8eedab8071d582f3e661971c9acd5fd'

  depends_on 'gmp'

  def patches
    "http://www.mpfr.org/mpfr-3.1.0/allpatches"
  end

  def options
    [["--32-bit", "Build 32-bit only."]]
  end

  def patches
    "http://www.mpfr.org/mpfr-current/allpatches"
  end

  def install
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]

    system "./configure", *args
    system "make"
    system "make check"
    system "make install"
  end
end
