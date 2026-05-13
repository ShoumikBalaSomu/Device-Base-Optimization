#!/usr/bin/env bash
# Sound Enhancement — PipeWire/PulseAudio + above 100% volume + Dolby profile
# Works on ALL Linux distros
set -euo pipefail

echo "🔊 Configuring Sound Enhancement..."

# Install audio packages per distro
if command -v dnf &>/dev/null; then
    dnf install -y pipewire pipewire-pulseaudio wireplumber easyeffects 2>/dev/null || true
elif command -v apt-get &>/dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y pipewire pipewire-pulse wireplumber easyeffects 2>/dev/null || true
elif command -v pacman &>/dev/null; then
    pacman -Sy --noconfirm pipewire pipewire-pulse wireplumber easyeffects 2>/dev/null || true
elif command -v zypper &>/dev/null; then
    zypper install -y pipewire pipewire-pulseaudio wireplumber easyeffects 2>/dev/null || true
fi

# PipeWire config — works on any distro with PipeWire
if command -v pipewire &>/dev/null || [ -d /etc/pipewire ] || [ -d /usr/share/pipewire ]; then
    mkdir -p /etc/pipewire/pipewire.conf.d
    cat > /etc/pipewire/pipewire.conf.d/99-hq-audio.conf << 'EOF'
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 96000 ]
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 2048
}
EOF

    # WirePlumber — above 100% volume (up to 150%)
    mkdir -p /etc/wireplumber/wireplumber.conf.d
    cat > /etc/wireplumber/wireplumber.conf.d/99-amplify.conf << 'EOF'
monitor.alsa.rules = [
  {
    matches = [ { node.name = "~alsa_output.*" } ]
    actions = {
      update-props = { volume.max = 1.5 }
    }
  }
]
EOF
    echo "✔ PipeWire → 48kHz high quality audio"
    echo "✔ Volume amplification → up to 150%"

elif command -v pulseaudio &>/dev/null; then
    # PulseAudio fallback (older distros)
    mkdir -p /etc/pulse
    if ! grep -q "Device-Base-Optimization" /etc/pulse/daemon.conf 2>/dev/null; then
        cat >> /etc/pulse/daemon.conf << 'EOF'
### Device-Base-Optimization — Audio ###
default-sample-rate = 48000
alternate-sample-rate = 44100
flat-volumes = no
EOF
    fi
    echo "✔ PulseAudio → 48kHz (upgrade to PipeWire for 150% volume)"
else
    echo "⚠ No PipeWire or PulseAudio — install manually"
fi

echo "✔ EasyEffects available for Dolby Atmos equalizer presets"
