require 'formula'

class Fftw < Formula
  homepage 'http://www.fftw.org'
  url 'http://www.fftw.org/fftw-3.3.2.tar.gz'
  sha1 '11a8c31186ff5a7d686a79a3f21b2530888e0dc2'

  def install
    args = ["--enable-shared",
            "--disable-debug",
            "--prefix=#{prefix}",
            "--enable-threads",
            "--disable-dependency-tracking"]

    # check for gfortran
    args << "--disable-fortran" unless which 'gfortran'

    # enable-altivec
    system "./configure", "--enable-single",
                          "--enable-altivec",
                          "--enable-fma",
                          *args
    system "make install"

    #wtf file?
    (info+'dir').unlink
  end
end
