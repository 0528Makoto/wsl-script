#!/bin/bash

# --- Actualizar sistema ---
sudo apt update && sudo apt upgrade -y

# --- Instalar dependencias ---
echo "📦 Instalando dependencias del sistema..."
sudo apt install -y \
    zip unzip \
    build-essential \
    curl git \
    ca-certificates \
    libssl-dev \
    pkg-config \
    libgtk-3-0 \
    libgbm1 \
    libnss3 \
    libasound2 \
    libnotify4 \       # <-- Nuevo: Soporte para notificaciones
    wget \
    fontconfig

# --- Instalar Rust y herramientas ---
echo "🦀 Instalando Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
cargo install git-cliff

# --- Configurar Node.js con NVM ---
echo "⬢ Instalando Node.js..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm alias default 'lts/*'

# --- Oh My Posh ---
echo "🎨 Configurando terminal..."
curl -s https://ohmyposh.dev/install.sh | bash -s

echo "🔠 Instalando fuentes..."
eval "$(oh-my-posh init bash)"  # Carga temporal para el comando font install
oh-my-posh font install JetBrainsMono

# Configurar tema iTerm2
mkdir -p ~/.poshthemes
wget -q -O ~/.poshthemes/iterm2.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/iTerm2.omp.json
echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/iterm2.omp.json)"' >> ~/.bashrc

# --- Instalar SDKMAN (Java/Kotlin) ---
echo "☕ Configurando SDKMAN..."
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java 21.0.2-tem

# --- Instalar GitKraken ---
echo "🦑 Instalando GitKraken..."
cat >> ~/.bashrc << 'EOF'

# Actualizar GitKraken
gitkraken-update() {
    local URL="https://api.gitkraken.com/releases/production/linux/x64/active/gitkraken-amd64.deb"
    local FILE="/tmp/gitkraken-amd64.deb"
    echo "⬇️ Descargando última versión..."
    wget "$URL" -O "$FILE" && sudo dpkg -i "$FILE" && rm "$FILE"
    echo "✅ GitKraken actualizado"
}
EOF
gitkraken-update  # Instalación inicial

# --- Post-instalación ---
echo -e "\n\u001b[32m✅ ¡Configuración completada!\u001b[0m"
echo "Versiones instaladas:"
echo " - Oh My Posh: $(oh-my-posh --version)"
echo " - Rust: $(rustc --version | cut -d' ' -f2)"
echo " - Node.js: $(node -v)"
echo " - Java: $(java --version | head -n1 | awk '{print $2}')"
echo " - GitKraken: $(dpkg -s gitkraken | grep Version | cut -d' ' -f2)"

echo -e "\n🔧 Pasos finales:"
echo "1. Configura tu terminal para usar 'JetBrainsMono Nerd Font'"
echo "2. Reinicia la terminal o ejecuta: source ~/.bashrc"
echo "3. Comandos útiles:"
echo "   - gitkraken-update  # Actualizar GitKraken"
echo "   - oh-my-posh font install  # Instalar más fuentes"