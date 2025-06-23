#!/bin/bash

# Update package lists
apt-get update

# Install basic system dependencies
apt-get install -y \
    wget \
    curl \
    build-essential \
    ca-certificates \
    vim \
    nano \
    htop \
    tree \
    neofetch

# Install Nextflow
curl -s https://get.nextflow.io | bash
chmod +x nextflow
mkdir -p $HOME/.local/bin/
mv nextflow $HOME/.local/bin/
# Add Nextflow to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Create a basic CLI prompt
cat >> ~/.bashrc << 'EOF'

# Basic CLI prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Useful aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Show current conda environment in prompt
conda_prompt() {
    if [ -n "$CONDA_DEFAULT_ENV" ]; then
        echo "($CONDA_DEFAULT_ENV) "
    fi
}
export PS1='$(conda_prompt)\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF

# Alias mamba to micromamba for convenience
echo "alias mamba='micromamba'" >> ~/.bashrc

echo "Minimal dev container setup complete!"
echo "You can now use 'micromamba' to install packages" 
