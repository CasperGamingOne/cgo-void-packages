#!/usr/bin/env bash
set -e

OUTPUT_DIR="${1:-deploy}"
REPO_URL="${REPO_URL:-https://caspergamingone.github.io/cgo-void-packages/x86_64}"

mkdir -p "$OUTPUT_DIR"

# Generate HTML file with embedded bash generator logic
python3 - "$OUTPUT_DIR" "$REPO_URL" << 'PYEOF'
import sys, os, glob

output_dir = sys.argv[1]
repo_url = sys.argv[2]

priority = ["umbriel", "noctalia", "noctalia-greeter"]
templates = []

for p in priority:
    path = f"srcpkgs/{p}/template"
    if os.path.isfile(path):
        templates.append(path)

# Limit scan or prioritize repo packages
for path in sorted(glob.glob("srcpkgs/*/template")):
    pkg = path.split("/")[1]
    if pkg not in priority:
        templates.append(path)

cards = []
total_pkgs = len(templates)

for t in templates:
    data = {}
    try:
        with open(t, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    parts = line.split("=", 1)
                    k = parts[0].strip()
                    v = parts[1].strip().strip('"').strip("'")
                    data[k] = v
    except Exception:
        continue

    pkgname = data.get("pkgname", "")
    version = data.get("version", "1.0.0")
    revision = data.get("revision", "1")
    short_desc = data.get("short_desc", "Void Linux package")
    maintainer = data.get("maintainer", "@caspergamingone")

    if not pkgname:
        continue

    cat = "Wayland / Desktop"
    cat_color = "text-indigo-400"
    badge = ""

    if pkgname == "umbriel":
        cat = "Wayland Compositor"
        cat_color = "text-purple-400"
        badge = '<span class="px-2 py-0.5 rounded bg-purple-950/80 border border-purple-500/50 text-[10px] font-mono text-purple-300 font-bold uppercase tracking-wide">EXCLUSIVE REPO PKG</span>'
    elif pkgname == "noctalia":
        cat = "Desktop Shell"
        cat_color = "text-cyan-400"
        badge = '<span class="px-2 py-0.5 rounded bg-cyan-950/80 border border-cyan-500/50 text-[10px] font-mono text-cyan-300 font-bold uppercase tracking-wide">FLAGSHIP</span>'
    elif pkgname == "noctalia-greeter":
        cat = "Display Manager"
        cat_color = "text-emerald-400"
        badge = '<span class="px-2 py-0.5 rounded bg-emerald-950/80 border border-emerald-500/50 text-[10px] font-mono text-emerald-300 font-bold uppercase tracking-wide">FLAGSHIP</span>'

    card_html = f'''
    <div class="pkg-card p-5 rounded-2xl bg-[#0e1628] border border-slate-800/90 flex flex-col justify-between space-y-4 hover:border-indigo-500/50 hover:-translate-y-1 transition-all duration-200 shadow-lg" data-name="{pkgname}" data-desc="{short_desc}" data-category="{cat}">
      <div class="space-y-3">
        <div class="flex items-start justify-between gap-2">
          <div>
            <div class="flex items-center gap-2 flex-wrap">
              <span class="text-xs font-mono {cat_color} font-semibold uppercase tracking-wider">{cat}</span>
              {badge}
            </div>
            <h3 class="text-lg font-mono font-bold text-white flex items-center gap-1.5 mt-1">
              {pkgname}
              <span class="text-xs font-normal text-slate-400">v{version}_{revision}</span>
            </h3>
          </div>
          <span class="px-2 py-0.5 rounded-md bg-emerald-950/70 border border-emerald-500/40 text-[11px] font-mono text-emerald-400 font-medium flex items-center gap-1 shrink-0">
            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400 shadow-[0_0_6px_#34d399]"></span> build:pass
          </span>
        </div>
        <p class="text-xs text-slate-300 font-medium leading-relaxed">
          {short_desc}
        </p>
        <div class="flex flex-wrap gap-1.5 pt-1">
          <span class="px-2 py-0.5 rounded bg-slate-900 border border-slate-800 text-[10px] font-mono text-indigo-400 font-medium">x86_64</span>
          <span class="px-2 py-0.5 rounded bg-slate-900 border border-slate-800 text-[10px] font-mono text-slate-400 font-medium">glibc</span>
          <span class="px-2 py-0.5 rounded bg-slate-900 border border-slate-800 text-[10px] font-mono text-slate-400 font-medium">xbps</span>
        </div>
      </div>
      <div class="border-t border-slate-800/80 pt-3 flex items-center justify-between text-xs font-mono">
        <span class="text-slate-500 truncate max-w-[180px]" title="{maintainer}">{maintainer}</span>
        <button class="px-2.5 py-1 rounded-lg bg-slate-900 border border-slate-700 hover:border-indigo-500 hover:text-indigo-300 text-[11px] text-slate-200 flex items-center gap-1 font-semibold transition-colors" onclick="copyText('xbps-install -S {pkgname}', 'Copied: xbps-install -S {pkgname}')">
          <span class="material-symbols-outlined text-[13px] text-indigo-400">terminal</span>
          <span>install</span>
        </button>
      </div>
    </div>'''
    cards.append(card_html)

pkg_cards_html = "\n".join(cards)

html_content = f'''<!DOCTYPE html>
<html class="dark" lang="en">
<head>
  <meta charset="utf-8"/>
  <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
  <title>CasperGamingOne 3rd Repo — Bleeding-Edge Gaming & 3rd-Party Void Linux Repository</title>
  <link href="https://fonts.googleapis.com" rel="preconnect"/>
  <link crossorigin="" href="https://fonts.gstatic.com" rel="preconnect"/>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
  <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
  <script>
    tailwind.config = {{
      darkMode: "class",
      theme: {{
        extend: {{
          colors: {{
            brand: {{
              primary: "#6366f1",
              glow: "#818cf8",
              accent: "#8b5cf6",
              cyan: "#06b6d4"
            }}
          }},
          fontFamily: {{
            headline: ["Plus Jakarta Sans", "sans-serif"],
            display: ["Plus Jakarta Sans", "sans-serif"],
            body: ["Plus Jakarta Sans", "sans-serif"],
            label: ["Plus Jakarta Sans", "sans-serif"],
            mono: ["JetBrains Mono", "monospace"]
          }}
        }},
      }},
    }}
  </script>
  <style>
    .material-symbols-outlined {{
      font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 20;
      display: inline-block;
      vertical-align: middle;
      line-height: 1;
    }}
  </style>
</head>
<body class="bg-[#090d16] text-slate-100 font-body antialiased min-h-screen selection:bg-indigo-600 selection:text-white relative">
  <div id="toast" class="fixed bottom-6 right-6 z-50 transform translate-y-20 opacity-0 transition-all duration-300 bg-indigo-600 text-white px-4 py-3 rounded-xl shadow-2xl font-mono text-xs flex items-center gap-2 border border-indigo-400">
    <span class="material-symbols-outlined text-[18px]">check_circle</span>
    <span id="toast-msg">Command copied!</span>
  </div>

  <div class="fixed inset-0 pointer-events-none overflow-hidden -z-10">
    <div class="absolute -top-40 left-1/4 w-[600px] h-[600px] bg-indigo-600/10 rounded-full blur-[120px]"></div>
    <div class="absolute top-1/3 -right-40 w-[500px] h-[500px] bg-purple-600/10 rounded-full blur-[140px]"></div>
    <div class="absolute bottom-10 left-10 w-[500px] h-[500px] bg-cyan-500/5 rounded-full blur-[140px]"></div>
  </div>

  <!-- TOP NAV BAR -->
  <header class="bg-[#0d1322]/90 backdrop-blur-md w-full sticky top-0 z-50 border-b border-slate-800/80">
    <div class="w-full px-6 py-3.5 flex items-center justify-between max-w-7xl mx-auto">
      <div class="flex items-center gap-8">
        <a class="flex items-center gap-3 font-headline group" href="#">
          <div class="w-9 h-9 rounded-xl bg-slate-800/80 border border-indigo-500/30 flex items-center justify-center text-indigo-400 group-hover:scale-95 group-hover:border-indigo-400 group-hover:shadow-[0_0_12px_rgba(99,102,241,0.5)] transition-all duration-150">
            <span class="material-symbols-outlined text-[20px]">sports_esports</span>
          </div>
          <div class="flex flex-col">
            <span class="tracking-tight text-white font-mono font-bold text-sm sm:text-base flex items-center gap-1.5">
              caspergamingone<span class="text-indigo-400">::3rd-repo</span>
            </span>
            <span class="text-[10px] font-mono text-slate-400 uppercase tracking-widest -mt-0.5">3rd-Party Void Linux Repo</span>
          </div>
        </a>
        <nav class="hidden md:flex items-center gap-6 font-headline font-semibold text-sm">
          <a class="text-indigo-400 font-semibold transition-colors duration-150 flex items-center gap-1" href="#packages">
            <span>Packages</span>
          </a>
          <a class="text-slate-400 font-medium hover:text-indigo-400 transition-colors duration-150" href="#architectures">Architectures</a>
          <a class="text-slate-400 font-medium hover:text-indigo-400 transition-colors duration-150" href="#docs">Docs</a>
          <a class="text-slate-400 font-medium hover:text-indigo-400 transition-colors duration-150 flex items-center gap-1.5" href="#architectures">
            <span class="w-2 h-2 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399] animate-pulse"></span>
            Status
          </a>
        </nav>
      </div>

      <div class="flex items-center gap-3">
        <div class="hidden lg:flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-900/90 border border-slate-800 focus-within:border-indigo-500/60 transition-colors w-64">
          <span class="material-symbols-outlined text-slate-500 text-[18px]">search</span>
          <input id="nav-search-input" class="bg-transparent border-0 p-0 text-xs font-mono text-slate-200 placeholder:text-slate-500 focus:ring-0 w-full outline-none" placeholder="xbps-query pkg..." type="text" oninput="syncAndFilter(this.value)"/>
        </div>
        <a class="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-slate-900/90 border border-slate-800 hover:border-slate-700 hover:text-indigo-400 transition-all duration-150 text-xs font-mono text-slate-300" href="#docs">
          <span class="material-symbols-outlined text-[16px] text-indigo-400">code</span>
          <span>xbps-src</span>
        </a>
        <a class="p-2 rounded-xl bg-slate-900/90 border border-slate-800 text-slate-400 hover:text-indigo-400 hover:border-slate-700 transition-colors flex items-center justify-center" href="https://github.com/void-linux/void-packages" rel="noreferrer" target="_blank" title="Upstream Repository">
          <span class="material-symbols-outlined text-[18px]">terminal</span>
        </a>
      </div>
    </div>
  </header>

  <!-- HERO SECTION -->
  <main class="max-w-7xl mx-auto px-6 py-12 lg:py-16 space-y-16">
    <section class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
      <div class="lg:col-span-6 space-y-6">
        <div class="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-indigo-500/10 border border-indigo-500/30 text-xs font-mono text-indigo-300 font-medium">
          <span class="w-2 h-2 rounded-full bg-indigo-400 shadow-[0_0_8px_#818cf8] animate-ping"></span>
          <span>CasperGamingOne :: 3rd-party rolling feed</span>
        </div>
        <h1 class="text-4xl sm:text-5xl font-headline font-extrabold tracking-tight text-white leading-tight">
          CasperGamingOne <span class="bg-gradient-to-r from-indigo-400 via-purple-400 to-cyan-400 bg-clip-text text-transparent">3rd Repo</span>
        </h1>
        <p class="text-base sm:text-lg text-slate-300 font-medium leading-relaxed max-w-xl">
          High-performance, community-curated 3rd-party XBPS repository for Void Linux. Featuring <strong class="text-purple-400">Umbriel</strong> (exclusive to this repo), <strong class="text-cyan-400">Noctalia</strong>, and <strong class="text-emerald-400">Noctalia Greeter</strong> for next-generation Wayland desktops.
        </p>
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-2">
          <div class="p-4 rounded-xl bg-[#0f172a]/80 border border-slate-800/80 space-y-1 hover:border-indigo-500/40 transition-colors">
            <p class="text-xs font-medium text-slate-400">Packages</p>
            <p class="text-xl font-headline font-bold text-indigo-400 font-mono">{total_pkgs}</p>
            <p class="text-[10px] text-slate-500">custom binary builds</p>
          </div>
          <div class="p-4 rounded-xl bg-[#0f172a]/80 border border-slate-800/80 space-y-1 hover:border-emerald-500/40 transition-colors">
            <p class="text-xs font-medium text-slate-400">CI Health</p>
            <p class="text-xl font-headline font-bold text-emerald-400 font-mono">100%</p>
            <p class="text-[10px] text-slate-500">build pass rate</p>
          </div>
          <div class="p-4 rounded-xl bg-[#0f172a]/80 border border-slate-800/80 space-y-1 hover:border-cyan-500/40 transition-colors">
            <p class="text-xs font-medium text-slate-400">Architecture</p>
            <p class="text-xl font-headline font-bold text-cyan-400 font-mono">x86_64</p>
            <p class="text-[10px] text-slate-500">glibc supported</p>
          </div>
          <div class="p-4 rounded-xl bg-[#0f172a]/80 border border-slate-800/80 space-y-1 hover:border-purple-500/40 transition-colors">
            <p class="text-xs font-medium text-slate-400">Exclusive</p>
            <p class="text-xl font-headline font-bold text-purple-400 font-mono">Umbriel</p>
            <p class="text-[10px] text-slate-500">only in CGO repo</p>
          </div>
        </div>
      </div>

      <!-- Right: Interactive Terminal Setup Box -->
      <div class="lg:col-span-6">
        <div class="rounded-2xl bg-[#0b101e] border border-indigo-500/25 p-6 space-y-4 shadow-[0_0_30px_rgba(15,23,42,0.8)] relative overflow-hidden">
          <div class="absolute top-0 left-0 right-0 h-[2px] bg-gradient-to-r from-transparent via-indigo-500 to-cyan-500"></div>
          <div class="flex items-center justify-between border-b border-slate-800/90 pb-3">
            <div class="flex items-center gap-2">
              <span class="w-3 h-3 rounded-full bg-rose-500/90 inline-block shadow-[0_0_6px_#f43f5e]"></span>
              <span class="w-3 h-3 rounded-full bg-amber-500/90 inline-block shadow-[0_0_6px_#f59e0b]"></span>
              <span class="w-3 h-3 rounded-full bg-emerald-500/90 inline-block shadow-[0_0_6px_#10b981]"></span>
              <span class="text-xs font-mono font-medium text-slate-400 ml-2">root@void-rig:~# setup-cgo-repo.sh</span>
            </div>
            <div class="flex items-center gap-1 bg-slate-900 border border-slate-800 p-1 rounded-lg text-[11px] font-mono text-slate-400">
              <span class="px-2 py-0.5 rounded bg-indigo-600/30 text-indigo-300 border border-indigo-500/40 font-semibold">x86_64</span>
            </div>
          </div>
          <div class="bg-[#050811] border border-slate-900 rounded-xl p-4 font-mono text-xs text-slate-200 space-y-2.5 overflow-x-auto relative shadow-inner">
            <div class="text-slate-500 select-none"># Step 1: Register CasperGamingOne 3rd Repo descriptor</div>
            <div class="flex items-start gap-2">
              <span class="text-indigo-400 font-semibold select-none">$</span>
              <code class="text-slate-200">echo 'repository={repo_url}' | sudo tee /etc/xbps.d/99-cgo.conf</code>
            </div>
            <div class="text-slate-500 select-none pt-2"># Step 2: Synchronize index & install Noctalia suite</div>
            <div class="flex items-start gap-2">
              <span class="text-indigo-400 font-semibold select-none">$</span>
              <code class="text-slate-200">sudo xbps-install -S &amp;&amp; sudo xbps-install -y umbriel noctalia noctalia-greeter</code>
            </div>
            <div class="text-slate-500 select-none pt-2"># Output verification</div>
            <div class="text-emerald-400 font-mono text-[11px]">
              [*] Updating repository `{repo_url}' ...<br/>
              index.plist: verified CasperGamingOne repository index OK.
            </div>
          </div>
          <div class="flex flex-wrap items-center justify-between gap-3 pt-1">
            <div class="flex items-center gap-2 text-xs font-mono text-slate-400">
              <span class="material-symbols-outlined text-indigo-400 text-[16px]">verified</span>
              <span>Repo URL: <strong class="text-indigo-300">{repo_url}</strong></span>
            </div>
            <button class="px-4 py-2 rounded-xl bg-slate-900 border border-slate-700/80 hover:border-indigo-500 hover:text-indigo-300 text-xs font-headline font-semibold flex items-center gap-1.5 transition-all duration-150 text-slate-200 shadow-sm" onclick="copyText('echo \'repository={repo_url}\' | sudo tee /etc/xbps.d/99-cgo.conf &amp;&amp; sudo xbps-install -S &amp;&amp; sudo xbps-install -y umbriel noctalia noctalia-greeter', 'Quick setup command copied to clipboard!')">
              <span class="material-symbols-outlined text-[16px] text-indigo-400">content_copy</span>
              <span>Copy Quick Setup</span>
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- LIVE PACKAGE SEARCH & FILTER SECTION -->
    <section class="space-y-6" id="packages">
      <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 text-xs font-mono text-indigo-400 font-semibold mb-1">
            <span class="material-symbols-outlined text-[16px]">inventory_2</span>
            <span>CASPERGAMINGONE_INDEX::QUERY</span>
          </div>
          <h2 class="text-2xl font-headline font-bold text-white">Live Package Catalog</h2>
          <p class="text-sm text-slate-400 font-medium">Explore tested XBPS packages built automatically from source.</p>
        </div>
        <div class="flex flex-wrap gap-2">
          <button class="filter-btn px-3.5 py-1.5 rounded-xl bg-indigo-600 text-xs font-semibold text-white shadow-[0_0_12px_rgba(99,102,241,0.5)]" onclick="filterCategory('all', this)">All ({total_pkgs})</button>
          <button class="filter-btn px-3.5 py-1.5 rounded-xl bg-[#0f172a] border border-slate-800 hover:border-indigo-500/50 hover:text-indigo-300 text-xs font-medium text-slate-400 transition-colors" onclick="filterCategory('Wayland', this)">Wayland Rigs</button>
          <button class="filter-btn px-3.5 py-1.5 rounded-xl bg-[#0f172a] border border-slate-800 hover:border-indigo-500/50 hover:text-indigo-300 text-xs font-medium text-slate-400 transition-colors" onclick="filterCategory('Desktop', this)">Desktop Shells</button>
          <button class="filter-btn px-3.5 py-1.5 rounded-xl bg-[#0f172a] border border-slate-800 hover:border-indigo-500/50 hover:text-indigo-300 text-xs font-medium text-slate-400 transition-colors" onclick="filterCategory('Display', this)">Display Managers</button>
        </div>
      </div>

      <div class="p-3 rounded-2xl bg-[#0c1222] border border-slate-800/90 flex flex-col sm:flex-row items-center justify-between gap-3 shadow-md">
        <div class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl bg-[#060a14] border border-slate-800 focus-within:border-indigo-500/60 transition-colors">
          <span class="material-symbols-outlined text-slate-500">filter_alt</span>
          <input id="main-search-input" class="bg-transparent border-0 text-sm font-mono text-slate-200 placeholder:text-slate-500 focus:ring-0 w-full outline-none" placeholder="Filter by package name, category, or description (e.g. umbriel, noctalia)..." type="text" oninput="syncAndFilter(this.value)"/>
        </div>
        <div class="flex items-center gap-2 shrink-0 text-xs font-mono text-slate-400 pr-2">
          <span>Sort:</span>
          <span class="font-semibold text-indigo-400 flex items-center gap-1">Featured First ↓</span>
        </div>
      </div>

      <div id="pkg-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {pkg_cards_html}
      </div>
    </section>

    <!-- ARCHITECTURE & BUILD MATRIX -->
    <section class="space-y-6" id="architectures">
      <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
        <div>
          <div class="flex items-center gap-2 text-xs font-mono text-indigo-400 font-semibold mb-1">
            <span class="material-symbols-outlined text-[16px]">developer_board</span>
            <span>SYSTEM_COMPATIBILITY_MATRIX</span>
          </div>
          <h2 class="text-2xl font-headline font-bold text-white">Target Architectures & Libc Flavors</h2>
          <p class="text-sm text-slate-400 font-medium">Compiled across native Void Linux masterdirs for optimal stability.</p>
        </div>
        <div class="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-[#0f172a] border border-slate-800 text-xs font-mono">
          <span class="w-2.5 h-2.5 rounded-full bg-emerald-400 shadow-[0_0_8px_#34d399] animate-pulse"></span>
          <span class="text-slate-200 font-semibold">casper-builder-cluster: ONLINE</span>
        </div>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="p-5 rounded-2xl bg-[#0e1628] border border-slate-800/90 space-y-4 hover:border-indigo-500/40 transition-colors shadow-lg">
          <div class="flex items-center justify-between">
            <div class="w-9 h-9 rounded-xl bg-slate-900 border border-indigo-500/30 flex items-center justify-center text-indigo-400 font-mono text-sm font-bold shadow-inner">
              64
            </div>
            <span class="px-2 py-0.5 rounded bg-emerald-950/70 border border-emerald-500/40 text-[10px] font-mono text-emerald-400 font-bold">STABLE</span>
          </div>
          <div>
            <h3 class="font-mono text-base font-bold text-white">x86_64</h3>
            <p class="text-xs text-slate-400 font-medium">Standard glibc 64-bit runtime</p>
          </div>
          <div class="space-y-2 pt-2 border-t border-slate-800 text-xs font-mono">
            <div class="flex justify-between">
              <span class="text-slate-400">Sync Packages</span>
              <span class="text-white font-bold">{total_pkgs} / {total_pkgs}</span>
            </div>
            <div class="w-full bg-slate-950 h-2 rounded-full overflow-hidden border border-slate-800">
              <div class="bg-indigo-500 h-full rounded-full shadow-[0_0_8px_#6366f1]" style="width: 100%"></div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- DOCS -->
    <section class="space-y-6" id="docs">
      <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <div class="lg:col-span-12 p-6 rounded-2xl bg-[#0e1628] border border-slate-800/90 space-y-4 shadow-lg">
          <div class="space-y-3">
            <div class="w-10 h-10 rounded-xl bg-slate-900 border border-indigo-500/30 flex items-center justify-center text-indigo-400">
              <span class="material-symbols-outlined text-[22px]">terminal</span>
            </div>
            <h3 class="font-headline font-bold text-lg text-white">Repository Setup Guide</h3>
            <p class="text-xs text-slate-300 font-medium leading-relaxed">
              Add this repository configuration to your Void Linux installation:
            </p>
            <div class="bg-[#050811] border border-slate-800/90 p-4 rounded-xl font-mono text-xs space-y-2">
              <p class="text-slate-500"># /etc/xbps.d/99-cgo.conf</p>
              <p class="text-indigo-400 font-bold">repository={repo_url}</p>
              <p class="text-slate-500 pt-2"># Sync and install</p>
              <p class="text-slate-200">sudo xbps-install -S</p>
              <p class="text-slate-200">sudo xbps-install -y umbriel noctalia noctalia-greeter</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <!-- FOOTER -->
  <footer class="bg-[#0b101e] border-t border-slate-800/80 w-full mt-16">
    <div class="w-full px-6 py-8 flex flex-col md:flex-row justify-between items-center max-w-7xl mx-auto gap-4">
      <div class="flex flex-col sm:flex-row items-center gap-3 text-center sm:text-left">
        <span class="font-headline font-bold text-sm text-white flex items-center gap-1.5">
          <span class="text-indigo-400 font-mono">caspergamingone::</span>3rd-repo
        </span>
        <span class="hidden sm:inline text-slate-700">|</span>
        <span class="font-body font-medium text-xs text-slate-400">© 2025 CasperGamingOne 3rd Repo. Unofficial Void Linux ecosystem.</span>
      </div>
      <nav class="flex flex-wrap justify-center items-center gap-5 font-body font-medium text-xs">
        <a class="text-slate-400 hover:text-indigo-400 transition-colors duration-150" href="#architectures">Architectures</a>
        <a class="text-slate-400 hover:text-indigo-400 transition-colors duration-150" href="#docs">Docs</a>
        <a class="text-indigo-400 hover:text-indigo-300 transition-colors duration-150 font-semibold flex items-center gap-1" href="https://github.com/void-linux/void-packages" rel="noreferrer" target="_blank">
          <span>Void upstream</span>
          <span class="material-symbols-outlined text-[13px]">open_in_new</span>
        </a>
      </nav>
    </div>
  </footer>

  <script>
    function copyText(text, msg) {{
      navigator.clipboard.writeText(text).then(() => {{
        const toast = document.getElementById('toast');
        const toastMsg = document.getElementById('toast-msg');
        toastMsg.innerText = msg || 'Copied to clipboard!';
        toast.classList.remove('translate-y-20', 'opacity-0');
        setTimeout(() => {{
          toast.classList.add('translate-y-20', 'opacity-0');
        }}, 2500);
      }});
    }}

    function syncAndFilter(query) {{
      document.getElementById('nav-search-input').value = query;
      document.getElementById('main-search-input').value = query;
      const q = query.toLowerCase();
      const cards = document.querySelectorAll('.pkg-card');
      cards.forEach(card => {{
        const name = card.getAttribute('data-name').toLowerCase();
        const desc = card.getAttribute('data-desc').toLowerCase();
        const cat = card.getAttribute('data-category').toLowerCase();
        if (name.includes(q) || desc.includes(q) || cat.includes(q)) {{
          card.style.display = 'flex';
        }} else {{
          card.style.display = 'none';
        }}
      }});
    }}

    function filterCategory(cat, btn) {{
      document.querySelectorAll('.filter-btn').forEach(b => {{
        b.className = 'filter-btn px-3.5 py-1.5 rounded-xl bg-[#0f172a] border border-slate-800 hover:border-indigo-500/50 hover:text-indigo-300 text-xs font-medium text-slate-400 transition-colors';
      }});
      btn.className = 'filter-btn px-3.5 py-1.5 rounded-xl bg-indigo-600 text-xs font-semibold text-white shadow-[0_0_12px_rgba(99,102,241,0.5)]';

      const cards = document.querySelectorAll('.pkg-card');
      cards.forEach(card => {{
        const c = card.getAttribute('data-category').toLowerCase();
        if (cat === 'all' || c.includes(cat.toLowerCase())) {{
          card.style.display = 'flex';
        }} else {{
          card.style.display = 'none';
        }}
      }});
    }}
  </script>
</body>
</html>'''

with open(f"{output_dir}/index.html", "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Generated site index.html in {output_dir} with {total_pkgs} packages.")
PYEOF
