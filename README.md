# CGO Void Linux Repository

Standalone third-party XBPS package repository for Void Linux, providing pre-built packages for **Noctalia**, **Umbriel**, and **Noctalia Greeter**.

---

## 🚀 Quick Start for Void Linux Users

You do **not** need to build these packages locally. Pre-built binary packages are generated automatically by GitHub Actions and hosted on GitHub Pages.

### 1. Add Repository Configuration
Create a repository configuration file at `/etc/xbps.d/cgo.conf`:

```sh
sudo mkdir -p /etc/xbps.d
echo "repository=https://caspergamingone.github.io/cgo-void-packages/x86_64" | sudo tee /etc/xbps.d/cgo.conf
```

### 2. Synchronize and Install
Sync package repositories and install Noctalia desktop environment packages:

```sh
sudo xbps-install -S
sudo xbps-install noctalia umbriel noctalia-greeter
```

---

## 📦 Packaged Components

| Package | Version | Description |
|---|---|---|
| [`noctalia`](srcpkgs/noctalia/template) | **5.3.0** | Sleek, customizable desktop shell crafted for Wayland |
| [`umbriel`](srcpkgs/umbriel/template) | **0.1.0** | Wayland compositor designed for the Noctalia desktop environment |
| [`noctalia-greeter`](srcpkgs/noctalia-greeter/template) | **1.6.0** | Display manager and greeter for Noctalia and Wayland compositors |

---

## 🔨 Building Locally with `xbps-src` (Optional)

If you prefer to build packages manually from source using `xbps-src`:

1. **Bootstrap `xbps-src`**:
   ```sh
   ./xbps-src binary-bootstrap
   ```

2. **Build a package**:
   ```sh
   ./xbps-src pkg noctalia
   ./xbps-src pkg umbriel
   ./xbps-src pkg noctalia-greeter
   ```

3. **Install built packages**:
   ```sh
   sudo xbps-install -R hostdir/binpkgs noctalia umbriel noctalia-greeter
   ```

---

## 📜 Maintenance and Issues

Maintainer: **CasperGamingOne** `<caspergamingone@outlook.dk>`
Repository: [CasperGamingOne/cgo-void-packages](https://github.com/CasperGamingOne/cgo-void-packages)
