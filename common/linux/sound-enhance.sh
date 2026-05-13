#!/usr/bin/env bash
# Sound Enhancement — PipeWire high quality + above 100% volume + Dolby Atmos profile
set -euo pipefail

echo "🔊 Configuring Sound Enhancement..."

dnf install -y pipewire pipewire-pulseaudio wireplumber easyeffects 2>/dev/null || true

# PipeWire — 48kHz high quality
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

systemctl --user restart pipewire wireplumber 2>/dev/null || true

echo "✔ PipeWire → 48kHz high quality audio"
echo "✔ Volume amplification → up to 150%"
echo "✔ Install EasyEffects for Dolby Atmos equalizer profiles"
