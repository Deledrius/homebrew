require 'formula'

class MediaInfo < Formula
  homepage 'http://mediainfo.sourceforge.net'
  url 'http://downloads.sourceforge.net/mediainfo/MediaInfo_CLI_0.7.60_GNU_FromSource.tar.bz2'
  version '0.7.60'
  sha1 '07d996efcd76fbfcc0787aa2940f5c4971c4537a'

  depends_on 'pkg-config' => :build

  def install
    system "./CLI_Compile.sh --prefix=#{prefix}"
    system "cd MediaInfo/Project/GNU/CLI && make install"
  end
end
