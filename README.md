# ScanTailor Advanced for macOS

macOS packaging, Homebrew tap, and native App bundler for [ScanTailor Advanced](https://github.com/ScanTailor-Advanced/scantailor-advanced) (v1.2.1).

Built natively for **Apple Silicon (ARM64)** with the **Qt 6** framework. No Rosetta required.

The formula builds the [`macos-arm64` branch](https://github.com/AthanasiusOfAlex/scantailor-advanced/tree/macos-arm64) of a fork of upstream 1.2.1. That branch adds:

- **Old projects open again.** 1.2.0 raised the project-file version without a format change, so projects saved by 1.0.x and 1.1.x were rejected. They are readable again.
- **A batch-processing hang is fixed.** A data structure shared between worker threads and the main thread had no locking.
- **Faster batch runs.** Colour pages load about 40% faster, and work that was only needed for on-screen display is no longer done for every page in a batch. Re-running a stage over an already processed 532-page project takes about a third of the time. Output files are byte-identical.
- **Thumbnails for projects in OneDrive, Dropbox, Google Drive or iCloud Drive are cached locally** (`~/Library/Caches/scantailor-advanced`), so reopening a project does not download one thumbnail at a time.
- **Settings live in `~/.config/scantailor-advanced/`**, not next to the executable, so they survive upgrades and the app bundle's signature stays valid.

### Projects in cloud-synced folders

If a project lives in OneDrive (or a similar service) and its files show a cloud icon in Finder, every page ScanTailor touches is downloaded first, at roughly a second per file regardless of size. That, not processing speed, is what makes a large project crawl. Before working on a project, right-click its folder in Finder and choose **Always Keep on This Device**, and wait for the download to finish.

---

## What is ScanTailor Advanced?

ScanTailor Advanced merges the best features of ScanTailor Featured and ScanTailor Enhanced versions, bringing performance improvements, high-DPI / Retina display support, modern Qt 6 integration, enhanced dewarping, and numerous bug fixes.

---

## Quick Installation

### Option 1: Homebrew (Recommended)

1. Make sure you have [Homebrew](https://brew.sh) installed.
2. Tap this repository and install `scantailor-advanced`:

```bash
brew tap AthanasiusOfAlex/scantailor-advanced-osx
brew install scantailor-advanced
```

3. Launch ScanTailor:

```bash
scantailor-advanced &

# Or using the 'scantailor' alias:
scantailor &
```

---

### Option 2: Automated Install Script

Run this single command in your Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/AthanasiusOfAlex/scantailor-advanced-osx/HEAD/install.sh)"
```

The script verifies prerequisites, sets up Homebrew environment paths if needed, taps the repository, and installs the latest version.

---

### Option 3: Pre-built App Bundle (.dmg)

Download the `.dmg` installer from the [Releases](https://github.com/AthanasiusOfAlex/scantailor-advanced-osx/releases) page and drag **ScanTailor (Advanced)** to your `/Applications` folder.

> [!NOTE]
> **macOS Gatekeeper Note for Downloaded Apps:**
> If macOS warns that the app "cannot be opened because Apple cannot check it for malicious software" or "is damaged", remove the quarantine attribute in Terminal:
> ```bash
> xattr -cr "/Applications/ScanTailor (Advanced).app"
> ```
> (or right-click the app in Finder and choose **Open**).

---

## Building a Standalone App Bundle & DMG

This repository includes a standalone bundler that creates a self-contained `.app` bundle and a compressed `.dmg` disk image.

The bundler:
- Automatically locates the installed `scantailor-advanced` binary.
- Deploys Qt 6 frameworks and plugins via `macdeployqt`.
- Automatically copies and relocates all third-party dynamic libraries (`boost`, `libtiff`, `libpng`, `jpeg-turbo`, etc.) into `Contents/Frameworks`.
- Applies mandatory ad-hoc code signing (`codesign`) required for Apple Silicon AMFI security, and verifies it.
- Sets the bundle's minimum macOS version to what the bundled libraries require. Homebrew libraries are built for the macOS version they were installed on, so the bundle runs on that version or newer.
- Packages a compressed `.dmg` installer with an `/Applications` shortcut.

### Steps to Bundle:

1. Install prerequisites:
   ```bash
   brew tap AthanasiusOfAlex/scantailor-advanced-osx
   brew install scantailor-advanced
   ```

2. Run the bundler:
   ```bash
   cd bundler
   ./bundle.sh
   ```
   *(Or double-click `scantailor_bundler.command` in Finder.)*

3. Verify the bundle integrity:
   ```bash
   ./sanity_check.command
   ```

The output bundle `ScanTailor (Advanced).app` and disk image `ScanTailor-Advanced-1.2.1-arm64.dmg` will be ready in the `bundler/` directory.

---

## Manual Build from Source

If you prefer building directly with CMake without Homebrew's formula runner:

```bash
# 1. Install dependencies
brew install cmake boost qt libpng libtiff jpeg-turbo

# 2. Clone the fork with the macOS fixes
git clone --branch macos-arm64 https://github.com/AthanasiusOfAlex/scantailor-advanced.git
cd scantailor-advanced

# 3. Configure and build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DPORTABLE_VERSION=OFF
cmake --build build -j$(sysctl -n hw.ncpu)

# 4. Install
sudo cmake --install build
```

---

## Measuring Performance

`bench/` holds the scripts used to compare builds. They drive the application through a developer-only hook (`SCANTAILOR_PERF_SCRIPT`, see `src/app/PerfDriver.h` in the fork) that creates or opens a project, switches stages, runs batches and reports wall time, CPU time and main-thread stalls.

```bash
bench/make-corpus.sh                    # render the PDFs in testdata/pdf to page images
bench/build-ref.sh v1.2.1               # build any revision of the fork into build-v1.2.1/
bench/scenario-full.sh v1.2.1 large     # full batch, then reopen; results in bench-results/
```

`testdata/`, `bench-results/` and `build-*/` are not tracked.

---

## Credits & Upstream

- Upstream Project: [ScanTailor-Advanced/scantailor-advanced](https://github.com/ScanTailor-Advanced/scantailor-advanced)
- Original ScanTailor by Joseph Artsimovich.
- macOS Packaging and App Bundler by [AthanasiusOfAlex](https://github.com/AthanasiusOfAlex/scantailor-advanced-osx) (originally maintained by [yb85](https://github.com/yb85/scantailor-advanced-osx)).
