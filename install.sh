#!/bin/bash

# DCP Installation Script
# Supports multiple architectures and distributions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/usr/local/bin"
COMPLETION_DIR="/etc/bash_completion.d"
ZSH_COMPLETION_DIR="/usr/local/share/zsh/site-functions"

# Check if running as root for system-wide installation
check_root() {
    if [[ $EUID -eq 0 ]]; then
        echo -e "${BLUE}Installing system-wide...${NC}"
        SYSTEM_INSTALL=true
    else
        echo -e "${YELLOW}Installing for current user...${NC}"
        INSTALL_DIR="$HOME/.local/bin"
        COMPLETION_DIR="$HOME/.bash_completion.d"
        ZSH_COMPLETION_DIR="$HOME/.local/share/zsh/site-functions"
        SYSTEM_INSTALL=false
    fi
}

# Create directories if they don't exist
create_directories() {
    echo -e "${BLUE}Creating directories...${NC}"

    mkdir -p "$INSTALL_DIR"
    mkdir -p "$COMPLETION_DIR"

    if command -v zsh >/dev/null 2>&1; then
        mkdir -p "$ZSH_COMPLETION_DIR"
    fi

    # Create user cache directory
    mkdir -p "$HOME/.cache/dcp"
}

# Install the main dcp script
install_dcp() {
    echo -e "${BLUE}Installing dcp command...${NC}"

    if [[ ! -f "dcp" ]]; then
        echo -e "${RED}Error: dcp script not found in current directory${NC}"
        exit 1
    fi

    cp dcp "$INSTALL_DIR/dcp"
    chmod +x "$INSTALL_DIR/dcp"

    echo -e "${GREEN}✓ dcp installed to $INSTALL_DIR/dcp${NC}"
}

# Install bash completion
install_bash_completion() {
    echo -e "${BLUE}Installing bash completion...${NC}"

    if [[ ! -f "dcp-completion.bash" ]]; then
        echo -e "${YELLOW}Warning: dcp-completion.bash not found${NC}"
        return 1
    fi

    cp dcp-completion.bash "$COMPLETION_DIR/dcp"

    echo -e "${GREEN}✓ Bash completion installed to $COMPLETION_DIR/dcp${NC}"

    # Add to .bashrc if user installation
    if [[ "$SYSTEM_INSTALL" == false ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            if ! grep -q "source.*dcp-completion.bash" "$HOME/.bashrc"; then
                echo "" >> "$HOME/.bashrc"
                echo "# DCP completion" >> "$HOME/.bashrc"
                echo "if [[ -f \"$COMPLETION_DIR/dcp\" ]]; then" >> "$HOME/.bashrc"
                echo "    source \"$COMPLETION_DIR/dcp\"" >> "$HOME/.bashrc"
                echo "fi" >> "$HOME/.bashrc"
                echo -e "${GREEN}✓ Added completion to .bashrc${NC}"
            fi
        fi
    fi
}

# Install zsh completion
install_zsh_completion() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo -e "${YELLOW}Zsh not found, skipping zsh completion${NC}"
        return 0
    fi

    echo -e "${BLUE}Installing zsh completion...${NC}"

    if [[ ! -f "dcp-completion.zsh" ]]; then
        echo -e "${YELLOW}Warning: dcp-completion.zsh not found${NC}"
        return 1
    fi

    cp dcp-completion.zsh "$ZSH_COMPLETION_DIR/_dcp"

    echo -e "${GREEN}✓ Zsh completion installed to $ZSH_COMPLETION_DIR/_dcp${NC}"
}

# Add to PATH if needed
update_path() {
    if [[ "$SYSTEM_INSTALL" == false ]]; then
        # Check if ~/.local/bin is in PATH
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo -e "${YELLOW}Adding $HOME/.local/bin to PATH...${NC}"

            # Add to .bashrc
            if [[ -f "$HOME/.bashrc" ]]; then
                if ! grep -q 'export PATH.*\.local/bin' "$HOME/.bashrc"; then
                    echo "" >> "$HOME/.bashrc"
                    echo "# Add ~/.local/bin to PATH" >> "$HOME/.bashrc"
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                fi
            fi

            # Add to .zshrc if it exists
            if [[ -f "$HOME/.zshrc" ]]; then
                if ! grep -q 'export PATH.*\.local/bin' "$HOME/.zshrc"; then
                    echo "" >> "$HOME/.zshrc"
                    echo "# Add ~/.local/bin to PATH" >> "$HOME/.zshrc"
                    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
                fi
            fi

            echo -e "${GREEN}✓ Added to shell profiles${NC}"
            echo -e "${YELLOW}Please restart your shell or run: source ~/.bashrc${NC}"
        fi
    fi
}

# Detect system information
detect_system() {
    echo -e "${BLUE}System Information:${NC}"
    echo "  OS: $(uname -s)"
    echo "  Architecture: $(uname -m)"
    echo "  Distribution: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")"
    echo "  Shell: $SHELL"
    echo
}

# Check dependencies
check_dependencies() {
    echo -e "${BLUE}Checking dependencies...${NC}"

    # Check for scp
    if ! command -v scp >/dev/null 2>&1; then
        echo -e "${RED}Error: scp command not found${NC}"
        echo "Please install openssh-client package"
        exit 1
    fi

    echo -e "${GREEN}✓ scp found${NC}"

    # Check for bash
    if ! command -v bash >/dev/null 2>&1; then
        echo -e "${RED}Error: bash not found${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ bash found${NC}"
}

# Uninstall function
uninstall() {
    echo -e "${YELLOW}Uninstalling dcp...${NC}"

    # Remove main script
    if [[ -f "$INSTALL_DIR/dcp" ]]; then
        rm -f "$INSTALL_DIR/dcp"
        echo -e "${GREEN}✓ Removed $INSTALL_DIR/dcp${NC}"
    fi

    # Remove bash completion
    if [[ -f "$COMPLETION_DIR/dcp" ]]; then
        rm -f "$COMPLETION_DIR/dcp"
        echo -e "${GREEN}✓ Removed bash completion${NC}"
    fi

    # Remove zsh completion
    if [[ -f "$ZSH_COMPLETION_DIR/_dcp" ]]; then
        rm -f "$ZSH_COMPLETION_DIR/_dcp"
        echo -e "${GREEN}✓ Removed zsh completion${NC}"
    fi

    echo -e "${GREEN}Uninstallation complete${NC}"
    echo -e "${YELLOW}Note: Cache directory ~/.cache/dcp was preserved${NC}"
}

# Main installation function
main() {
    echo -e "${BLUE}DCP Installation Script${NC}"
    echo "======================="
    echo

    # Parse command line arguments
    case "$1" in
        --uninstall)
            check_root
            uninstall
            exit 0
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --uninstall    Remove dcp from system"
            echo "  --help, -h     Show this help"
            echo
            echo "Installation locations:"
            echo "  System-wide (as root):"
            echo "    Binary: /usr/local/bin/dcp"
            echo "    Bash completion: /etc/bash_completion.d/dcp"
            echo "    Zsh completion: /usr/local/share/zsh/site-functions/_dcp"
            echo
            echo "  User installation:"
            echo "    Binary: ~/.local/bin/dcp"
            echo "    Bash completion: ~/.bash_completion.d/dcp"
            echo "    Zsh completion: ~/.local/share/zsh/site-functions/_dcp"
            exit 0
            ;;
    esac

    detect_system
    check_dependencies
    check_root
    create_directories

    echo -e "${BLUE}Installing components...${NC}"
    install_dcp
    install_bash_completion
    install_zsh_completion
    update_path

    echo
    echo -e "${GREEN}🎉 Installation complete!${NC}"
    echo
    echo "Quick start:"
    echo "  dcp --help                    # Show help"
    echo "  dcp file.txt user@host:/tmp/  # Copy file to remote"
    echo "  dcp --list-hosts              # List cached hosts"
    echo
    echo "To enable tab completion, restart your shell or run:"
    if [[ "$SYSTEM_INSTALL" == false ]]; then
        echo "  source ~/.bashrc"
    else
        echo "  source /etc/bash_completion"
    fi
    echo
}

# Run main function
main "$@"
