#!/bin/bash

# --- Funciones de verificación ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

dir_exists() {
  [ -d "$1" ]
}

# --- Verificar e instalar dependencias del sistema ---
echo "🔍 Verificando dependencias del sistema..."
DEPENDENCIES=(
  zip unzip build-essential
  curl git ca-certificates
  libssl-dev pkg-config
  libgtk-3-0 libgbm1 libnss3 libnotify4
  wget fontconfig gcc
)

TO_INSTALL=()
for dep in "${DEPENDENCIES[@]}"; do
  if ! dpkg -l | grep -q "^ii  $dep "; then
    TO_INSTALL+=("$dep")
  fi
done

if [ ${#TO_INSTALL[@]} -gt 0 ]; then
  echo "📦 Instalando: ${TO_INSTALL[*]}"
  sudo apt update && sudo apt install -y "${TO_INSTALL[@]}"
else
  echo "✅ Todas las dependencias ya están instaladas"
fi

# --- Verificar e instalar Rust ---
if ! command_exists rustc; then
  echo "🦀 Instalando Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "✅ Rust ya instalado: $(rustc --version)"
fi

# --- Verificar e instalar git-cliff ---
if ! command_exists git-cliff; then
  echo "📜 Instalando git-cliff..."
  cargo install git-cliff
else
  echo "✅ git-cliff ya instalado: $(git-cliff --version)"
fi

# --- Verificar e instalar NVM ---
if ! dir_exists "$HOME/.nvm"; then
  echo "⬢ Instalando NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  echo "⬢ Instalando Node.js LTS..."
  nvm install --lts
  nvm alias default 'lts/*'
else
  echo "✅ NVM ya instalado"
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  echo "  - Node.js: $(node -v)"
  echo "  - npm: $(npm -v)"
fi

# --- Verificar e instalar Oh My Posh ---
if ! command_exists oh-my-posh; then
  echo "🎨 Instalando Oh My Posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s

  echo "🔠 Instalando fuentes..."
  eval "$(oh-my-posh init bash)"
  oh-my-posh font install JetBrainsMono

  mkdir -p ~/.poshthemes
  wget -q -O ~/.poshthemes/iterm2.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/iterm2.omp.json
  echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
  echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/iterm2.omp.json)"' >> ~/.bashrc

else
  echo "✅ Oh My Posh ya instalado: $(oh-my-posh --version)"
fi

# --- Verificar e instalar SDKMAN ---
if ! dir_exists "$HOME/.sdkman"; then
  echo "☕ Instalando SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  sdk install java 21.0.2-tem
else
  echo "✅ SDKMAN ya instalado"
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  echo "  - Java: $(java --version | head -n1)"
fi

# --- Verificar e instalar GitKraken ---
if ! command_exists gitkraken; then
  echo "🦑 Instalando GitKraken..."
  GITKRAKEN_DEB_URL="https://api.gitkraken.com/releases/production/linux/x64/active/gitkraken-amd64.deb"
  GITKRAKEN_DEB_FILE="/tmp/gitkraken-amd64.deb"

  wget "$GITKRAKEN_DEB_URL" -O "$GITKRAKEN_DEB_FILE"
  sudo dpkg -i "$GITKRAKEN_DEB_FILE" || sudo apt --fix-broken install -y
  rm "$GITKRAKEN_DEB_FILE"

  # Configurar actualizador
  cat >> ~/.bashrc << 'EOF'
gitkraken-update() {
    local URL="https://api.gitkraken.com/releases/production/linux/x64/active/gitkraken-amd64.deb"
    local FILE="/tmp/gitkraken-amd64.deb"
    echo "⬇️ Descargando última versión..."
    wget "$URL" -O "$FILE" && sudo dpkg -i "$FILE" && rm "$FILE"
    echo "✅ GitKraken actualizado"
}
EOF

  source ~/.bashrc  # <-- Esto activa el alias inmediatamente
else
  echo "✅ GitKraken ya instalado: $(dpkg -s gitkraken | grep Version | cut -d' ' -f2)"
fi

# --- Configurar Aliases para Laravel Sail ---
cat >> ~/.bashrc << 'EOF'

# Laravel Sail Shortcuts
alias sail='[ -f sail ] && sh sail || sh vendor/bin/sail'
alias art='sail php artisan'
alias vapor='sail bin vapor'
alias fresh='sail php artisan migrate:fresh'

# Git Hard Reset
nah() {
    echo -n "⚠️ Are you sure you want to HARD RESET git? (yes/no): "
    read response
    if [ "$response" = "yes" ]; then
        echo "🧹 Nuclear cleanup initiated..."
        git reset --hard HEAD
        git clean -fd
        if [ -d ".git/rebase-apply" ] || [ -d ".git/rebase-merge" ]; then
          git rebase --abort
        fi
        echo "✅ Repository sterilized"
    else
        echo "🚫 Mission aborted"
    fi
}
EOF

# --- Post-instalación ---
echo -e "\n\u001b[32m✅ ¡Configuración completada!\u001b[0m"
echo "Recarga la configuración con:"
echo "  source ~/.bashrc"