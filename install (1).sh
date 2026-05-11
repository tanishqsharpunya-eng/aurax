#!/usr/bin/env bash
# ============================================================
#  AURAX PRIME v3.0 — One-Line Installer
#  by tanishk sharpunya
#  Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/aurax-prime/main/install.sh | bash
# ============================================================

set -e

# ── Colors ──────────────────────────────────────────────────
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Banner ──────────────────────────────────────────────────
clear
echo -e "${CYAN}${BOLD}"
cat << 'BANNER'
    ___  __  ______  ___  _  __   ____  ____  _____   _______
   / _ |/ / / / _ \/ _ || |/ /  / __ \/ __ \/  _/ | / / __/
  / __ / /_/ / , _/ __ |    /  / /_/ / /_/ // //  |/ / _/  
 /_/ |_\____/_/|_/_/ |_/_/|_/   \____/\____/___/_/|___/___/  
BANNER
echo -e "${RESET}"
echo -e "${CYAN}         ⚕  AURAX PRIME v3.0 — Terminal Edition  ⚕${RESET}"
echo -e "${YELLOW}               by tanishk sharpunya${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── Detect OS ───────────────────────────────────────────────
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS="windows"
else
    OS="unknown"
fi

echo -e "${CYAN}[*]${RESET} Detected OS: ${BOLD}$OS${RESET}"

# ── Check Python ─────────────────────────────────────────────
echo -e "${CYAN}[*]${RESET} Checking Python..."

PYTHON=""
for cmd in python3 python python3.11 python3.10 python3.9; do
    if command -v "$cmd" &>/dev/null; then
        VERSION=$("$cmd" --version 2>&1 | awk '{print $2}')
        MAJOR=$(echo "$VERSION" | cut -d. -f1)
        MINOR=$(echo "$VERSION" | cut -d. -f2)
        if [[ "$MAJOR" -ge 3 && "$MINOR" -ge 8 ]]; then
            PYTHON="$cmd"
            echo -e "${GREEN}[✓]${RESET} Found Python $VERSION at $(which $cmd)"
            break
        fi
    fi
done

if [[ -z "$PYTHON" ]]; then
    echo -e "${RED}[✗]${RESET} Python 3.8+ not found!"
    echo ""
    if [[ "$OS" == "linux" ]]; then
        echo -e "${YELLOW}    Install with:${RESET} sudo apt install python3 python3-pip"
    elif [[ "$OS" == "macos" ]]; then
        echo -e "${YELLOW}    Install with:${RESET} brew install python3"
    else
        echo -e "${YELLOW}    Download from:${RESET} https://www.python.org/downloads/"
    fi
    exit 1
fi

# ── Install Directory ────────────────────────────────────────
INSTALL_DIR="$HOME/.aurax-prime"
echo -e "${CYAN}[*]${RESET} Install directory: ${BOLD}$INSTALL_DIR${RESET}"
mkdir -p "$INSTALL_DIR"

# ── Download Files ───────────────────────────────────────────
BASE_URL="https://github.com/tanishqsharpunya-eng/aurax.git"

echo ""
echo -e "${CYAN}[*]${RESET} Downloading AURAX PRIME..."

# Download main script
if command -v curl &>/dev/null; then
    curl -fsSL "$BASE_URL/aurax_prime.py" -o "$INSTALL_DIR/aurax_prime.py"
    curl -fsSL "$BASE_URL/logo.png"       -o "$INSTALL_DIR/logo.png" 2>/dev/null || true
elif command -v wget &>/dev/null; then
    wget -q "$BASE_URL/aurax_prime.py" -O "$INSTALL_DIR/aurax_prime.py"
    wget -q "$BASE_URL/logo.png"       -O "$INSTALL_DIR/logo.png" 2>/dev/null || true
else
    echo -e "${RED}[✗]${RESET} Neither curl nor wget found. Please install one and retry."
    exit 1
fi

echo -e "${GREEN}[✓]${RESET} Downloaded aurax_prime.py"

# ── Install Python Dependencies ──────────────────────────────
echo ""
echo -e "${CYAN}[*]${RESET} Installing Python dependencies..."

DEPS="rich requests beautifulsoup4 pyfiglet pillow"

$PYTHON -m pip install --quiet --upgrade pip 2>/dev/null || true
$PYTHON -m pip install --quiet $DEPS

echo -e "${GREEN}[✓]${RESET} Dependencies installed"

# ── Create Launcher ──────────────────────────────────────────
LAUNCHER="$HOME/.local/bin/aurax-prime"
mkdir -p "$HOME/.local/bin"

cat > "$LAUNCHER" << LAUNCHER_SCRIPT
#!/usr/bin/env bash
exec $PYTHON "$INSTALL_DIR/aurax_prime.py" "\$@"
LAUNCHER_SCRIPT

chmod +x "$LAUNCHER"

# ── Add to PATH if needed ────────────────────────────────────
SHELL_RC=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

PATH_LINE='export PATH="$HOME/.local/bin:$PATH"'
if [[ -n "$SHELL_RC" ]] && ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo "$PATH_LINE" >> "$SHELL_RC"
    echo -e "${GREEN}[✓]${RESET} Added ~/.local/bin to PATH in $SHELL_RC"
fi

export PATH="$HOME/.local/bin:$PATH"

# ── Done ─────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  ✓ AURAX PRIME installed successfully!${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  ${BOLD}Run it:${RESET}       ${CYAN}aurax-prime${RESET}"
echo -e "  ${BOLD}Or directly:${RESET}  ${CYAN}$PYTHON $INSTALL_DIR/aurax_prime.py${RESET}"
echo ""
echo -e "  ${YELLOW}Note: Open a new terminal if 'aurax-prime' command is not found.${RESET}"
echo ""
echo -e "${CYAN}  ⚕ Stay secure. Stay vigilant.  — by tanishk sharpunya${RESET}"
echo ""

# ── Auto-launch ──────────────────────────────────────────────
read -rp "  Launch AURAX PRIME now? [Y/n]: " LAUNCH
LAUNCH="${LAUNCH:-Y}"
if [[ "$LAUNCH" =~ ^[Yy]$ ]]; then
    echo ""
    $PYTHON "$INSTALL_DIR/aurax_prime.py"
fi
