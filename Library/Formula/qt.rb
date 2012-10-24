require 'formula'

class Qt < Formula
  homepage 'http://qt.nokia.com/'
  url 'http://releases.qt-project.org/qt4/source/qt-everywhere-opensource-src-4.8.3.tar.gz'
  sha1 'bc352a283610e0cd2fe0dbedbc45613844090fcb'

  bottle do
    sha1 'ff488747325cd6771fbf0b79156fd3833ff3af63' => :mountainlion
    sha1 '5b8d6d3c47f3992465de3a750a35407eef128c94' => :lion
    sha1 'bb0b7e58d743e7b9147ae0d03cebc83134b8f68c' => :snowleopard
  end

  head 'git://gitorious.org/qt/qt.git', :branch => 'master'

  env :std # Otherwise fails on SSE intrinsics

  option :universal
  option 'with-qtdbus', 'Enable QtDBus module'
  option 'with-qt3support', 'Enable deprecated Qt3Support module'
  option 'with-demos-examples', 'Enable Qt demos and examples'
  option 'with-debug-and-release', 'Compile Qt in debug and release mode'
  option 'with-mysql', 'Enable MySQL plugin'
  option 'developer', 'Compile and link Qt with developer options'

  depends_on :libpng

  depends_on "d-bus" if build.include? 'with-qtdbus'
  depends_on "mysql" if build.include? 'with-mysql'
  depends_on 'sqlite' if MacOS.version == :leopard

  fails_with :clang do
    build 421
  end

  def options
    [
      ['--with-qtdbus', "Enable QtDBus module."],
      ['--with-qt3support', "Enable deprecated Qt3Support module."],
      ['--with-demos-examples', "Enable Qt demos and examples."],
      ['--with-debug-and-release', "Compile Qt in debug and release mode."],
      ['--developer', 'Compile and link Qt with Qt developer options']
    ]
  end

  depends_on "d-bus" if ARGV.include? '--with-qtdbus'
  depends_on 'sqlite' if MacOS.leopard?

  def patches
    if MacOS.leopard?
      [
    # fixes conflict on osx 10.5. See qt bug:
    # https://bugreports.qt-project.org/browse/QTBUG-23258
        "http://bugreports.qt-project.org/secure/attachment/26712/Patch-Qt-4.8-for-10.5",
       # Make it build on PPC:
       # https://bugs.webkit.org/show_bug.cgi?id=93397
        "https://gist.github.com/raw/3289864/a0fb5425092cc2505d8ae31159e6bd484c209cc7/qt-webkit-ppc32.diff",
      ]

    # add support for Mountain Lion
    # should be unneeded for 4.8.3
    elsif MacOS.version >= :mountain_lion
      [ "https://qt.gitorious.org/qt/qt/commit/422f1b?format=patch",
        "https://qt.gitorious.org/qt/qt/commit/665355?format=patch",
        "https://raw.github.com/gist/3187034/893252db0ae3bb9bb5fa3ff7c530c7978399b101/0001-Fix-WebKit-on-OS-X-Mountain-Lion.patch" ]
    end
  end

  def install
    ENV.append "CXXFLAGS", "-fvisibility=hidden"
    args = ["-prefix", prefix,
            "-system-libpng", "-system-zlib",
            "-confirm-license", "-opensource",
            "-cocoa", "-fast",
            "-platform", "macx-g++42"]

    args << "-L#{MacOS.x11_prefix}/lib" << "-I#{MacOS.x11_prefix}/include" if MacOS::X11.installed?

    args << "-platform" << "unsupported/macx-clang" if ENV.compiler == :clang

    # See: https://github.com/mxcl/homebrew/issues/issue/744
    args << "-system-sqlite" if MacOS.version == :leopard

    args << "-plugin-sql-mysql" if build.include? 'with-mysql'

    if build.include? 'with-qtdbus'
      args << "-I#{Formula.factory('d-bus').lib}/dbus-1.0/include"
      args << "-I#{Formula.factory('d-bus').include}/dbus-1.0"
    end

    if build.include? 'with-qt3support'
      args << "-qt3support"
    else
      args << "-no-qt3support"
    end

    unless build.include? 'with-demos-examples'
      args << "-nomake" << "demos" << "-nomake" << "examples"
    end

    args << '-arch' << 'ppc'

    if build.include? 'with-debug-and-release'
      args << "-debug-and-release"
      # Debug symbols need to find the source so build in the prefix
      mv "../qt-everywhere-opensource-src-#{version}", "#{prefix}/src"
      cd "#{prefix}/src"
    else
      args << "-release"
    end

    args << '-developer-build' if build.include? 'developer'

    # Needed for Qt 4.8.3 due to attempting to link moc with gcc.
    ENV['LD'] = ENV.cxx

    system "./configure", *args
    system "make"
    ENV.j1
    system "make install"

    # stop crazy disk usage
    (prefix+'doc/html').rmtree
    (prefix+'doc/src').rmtree
    # what are these anyway?
    (bin+'pixeltool.app').rmtree
    (bin+'qhelpconverter.app').rmtree
    # remove porting file for non-humans
    (prefix+'q3porting.xml').unlink

    # Some config scripts will only find Qt in a "Frameworks" folder
    # VirtualBox is an example of where this is needed
    # See: https://github.com/mxcl/homebrew/issues/issue/745
    cd prefix do
      ln_s lib, prefix + "Frameworks"
    end

    # The pkg-config files installed suggest that headers can be found in the
    # `include` directory. Make this so by creating symlinks from `include` to
    # the Frameworks' Headers folders.
    Pathname.glob(lib + '*.framework/Headers').each do |path|
      framework_name = File.basename(File.dirname(path), '.framework')
      ln_s path.realpath, include+framework_name
    end

    Pathname.glob(bin + '*.app').each do |path|
      mv path, prefix
    end
  end

  def test
    system "#{bin}/qmake", "--version"
  end

  def caveats; <<-EOS.undent
    We agreed to the Qt opensource license for you.
    If this is unacceptable you should uninstall.
    EOS
  end
end
