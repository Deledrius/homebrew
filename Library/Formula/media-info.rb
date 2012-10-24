require 'formula'

class MediaInfo < Formula
  homepage 'http://mediainfo.sourceforge.net'
  url 'http://downloads.sourceforge.net/mediainfo/MediaInfo_CLI_0.7.61_GNU_FromSource.tar.bz2'
  version '0.7.61'
  sha1 'd05788f284f3e9de5bda98456ed788999b244198'

  depends_on 'pkg-config' => :build

  def install
    system "./CLI_Compile.sh --prefix=#{prefix}"
    system "cd MediaInfo/Project/GNU/CLI && make install"
  end
end
