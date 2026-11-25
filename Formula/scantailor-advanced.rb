class ScantailorAdvanced < Formula
  desc "Interactive post-processing tool for scanned pages (Advanced)"
  homepage "https://github.com/AthanasiusOfAlex/scantailor-advanced"
  # ScanTailor Advanced 1.2.1 plus the macOS fixes on the fork's macos-arm64 branch.
  url "https://github.com/AthanasiusOfAlex/scantailor-advanced.git",
      tag:      "v1.2.1-macos.2",
      revision: "b9d4614fb88315e16f5e9cb982bd81f86653b6bc"
  version "1.2.1-macos.2"
  license "GPL-3.0-or-later"
  head "https://github.com/AthanasiusOfAlex/scantailor-advanced.git", branch: "macos-arm64"

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "qt"

  def install
    # Homebrew's compiler shim replaces -O3 with -Os by default. This is an
    # image-processing application; -Os costs about 10% in the heavy stages.
    ENV.O3

    # PORTABLE_VERSION would keep settings next to the executable, i.e. inside the
    # versioned Cellar directory, where every upgrade or reinstall discards them.
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_TESTS=OFF",
                    "-DPORTABLE_VERSION=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Provide 'scantailor' symlink for convenience and compatibility
    bin.install_symlink "scantailor-advanced" => "scantailor"
  end

  test do
    assert_path_exists bin/"scantailor-advanced"
    assert_path_exists bin/"scantailor"
  end
end
