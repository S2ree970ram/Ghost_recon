#!/bin/bash

# GhostRecon Installation Script
# Author: GhostOperator
# Version: 1.0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Please run this script as root${NC}"
    exit 1
fi

# Banner
echo -e "${BLUE}"
echo " @@@@@@@@  @@@  @@@   @@@@@@    @@@@@@   @@@@@@@      @@@@@@   @@@@@@@   @@@@@@   @@@@@@   "
echo "@@@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@   @@@@@@@     @@@@@@@   @@@@@@@@  @@@@@@@  @@@@@@@  "
echo "!@@        @@!  @@@  @@!  @@@  !@@         @@!       !@@       @@!  @@@      @@@      @@@  "
echo "!@!        !@!  @!@  !@!  @!@  !@!         !@!       !@!       !@!  @!@      @!@      @!@  "
echo "!@! @!@!@  @!@!@!@!  @!@  !@!  !!@@!!      @!!       !!@@!!    @!@!!@!   @!@!!@   @!@!!@   "
echo "!!! !!@!!  !!!@!!!!  !@!  !!!   !!@!!!     !!!        !!@!!!   !!@!@!    !!@!@!   !!@!@!   "
echo ":!!   !!:  !!:  !!!  !!:  !!!       !:!    !!:            !:!  !!: :!!       !!:      !!:  "
echo ":!:   !::  :!:  !:!  :!:  !:!      !:!     :!:           !:!   :!:  !:!      :!:      :!:  "
echo " ::: ::::  ::   :::  ::::: ::  :::: ::      ::       :::: ::   ::   :::  :: ::::  :: ::::  "
echo " :: :: :    :   : :   : :  :   :: : :       :        :: : :     :   : :   : : :    : : :   "
echo -e "${NC}"
echo -e "${GREEN}GHOST_RECON Installation Script${NC}"
echo -e "${YELLOW}Author: GhostOperator | Twitter: @ghostrecon${NC}"
echo -e "===================================================\n"

# Function to install packages
install_package() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${YELLOW}[~] Installing $1...${NC}"
        if [ -f /etc/debian_version ]; then
            apt-get install -y $1
        elif [ -f /etc/redhat-release ]; then
            yum install -y $1
        elif [ -f /etc/arch-release ]; then
            pacman -S --noconfirm $1
        else
            echo -e "${RED}[!] Unsupported Linux distribution${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}[✓] $1 is already installed${NC}"
    fi
}

# Install system dependencies
echo -e "${BLUE}[+] Installing system dependencies...${NC}"
install_package git
install_package python3
install_package python3-pip
install_package wget
install_package unzip

# Install Python dependencies
echo -e "\n${BLUE}[+] Installing Python dependencies...${NC}"
pip3 install argparse requests beautifulsoup4 colorama

# Install Go if not installed (required for some tools)
if ! command -v go &> /dev/null; then
    echo -e "\n${YELLOW}[~] Installing Go...${NC}"
    wget https://golang.org/dl/go1.17.linux-amd64.tar.gz
    tar -C /usr/local -xzf go1.17.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    rm go1.17.linux-amd64.tar.gz
    echo -e "${GREEN}[✓] Go installed successfully${NC}"
else
    echo -e "${GREEN}[✓] Go is already installed${NC}"
fi

# Install required tools
echo -e "\n${BLUE}[+] Installing required tools...${NC}"

# Install Subfinder
if ! command -v subfinder &> /dev/null; then
    echo -e "${YELLOW}[~] Installing Subfinder...${NC}"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    ln -s ~/go/bin/subfinder /usr/local/bin/subfinder
    echo -e "${GREEN}[✓] Subfinder installed successfully${NC}"
else
    echo -e "${GREEN}[✓] Subfinder is already installed${NC}"
fi

# Install httpx
if ! command -v httpx &> /dev/null; then
    echo -e "${YELLOW}[~] Installing httpx...${NC}"
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    ln -s ~/go/bin/httpx /usr/local/bin/httpx
    echo -e "${GREEN}[✓] httpx installed successfully${NC}"
else
    echo -e "${GREEN}[✓] httpx is already installed${NC}"
fi

# Install gau
if ! command -v gau &> /dev/null; then
    echo -e "${YELLOW}[~] Installing gau...${NC}"
    go install -v github.com/lc/gau/v2/cmd/gau@latest
    ln -s ~/go/bin/gau /usr/local/bin/gau
    echo -e "${GREEN}[✓] gau installed successfully${NC}"
else
    echo -e "${GREEN}[✓] gau is already installed${NC}"
fi

# Install waybackurls
if ! command -v waybackurls &> /dev/null; then
    echo -e "${YELLOW}[~] Installing waybackurls...${NC}"
    go install -v github.com/tomnomnom/waybackurls@latest
    ln -s ~/go/bin/waybackurls /usr/local/bin/waybackurls
    echo -e "${GREEN}[✓] waybackurls installed successfully${NC}"
else
    echo -e "${GREEN}[✓] waybackurls is already installed${NC}"
fi

# Install Subdominator (if available)
if ! command -v subdominator &> /dev/null; then
    echo -e "${YELLOW}[~] Installing Subdominator...${NC}"
    git clone https://github.com/sanjai-AK47/Subdominator.git /tmp/subdominator
    cd /tmp/subdominator
    pip3 install -r requirements.txt
    chmod +x subdominator.py
    ln -s /tmp/subdominator/subdominator.py /usr/local/bin/subdominator
    cd -
    echo -e "${GREEN}[✓] Subdominator installed successfully${NC}"
else
    echo -e "${GREEN}[✓] Subdominator is already installed${NC}"
fi

# Create GhostRecon directory structure
echo -e "\n${BLUE}[+] Setting up GhostRecon...${NC}"
INSTALL_DIR="/opt/ghostrecon"
if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p "$INSTALL_DIR"
    echo -e "${GREEN}[✓] Created installation directory at $INSTALL_DIR${NC}"
else
    echo -e "${YELLOW}[!] Installation directory already exists at $INSTALL_DIR${NC}"
fi

# Create the modules directory
MODULES_DIR="$INSTALL_DIR/modules"
if [ ! -d "$MODULES_DIR" ]; then
    mkdir -p "$MODULES_DIR"
    echo -e "${GREEN}[✓] Created modules directory${NC}"
fi

# Download the GhostRecon files
echo -e "\n${BLUE}[+] Downloading GhostRecon files...${NC}"

# Create the main script
cat > "$INSTALL_DIR/ghost_recon.py" << 'EOF'
#!/usr/bin/env python3

import os
import sys
import json
import time
import argparse

# Import your actual modules
from modules.subdomains import SubdomainEnumerator
from modules.http_probe import HTTPProber
from modules.url_gather import URLGatherer

class GhostRecon:
    def __init__(self, domain, output_dir="ghost_recon_results", threads=10):
        self.domain = domain
        self.output_dir = output_dir
        self.threads = threads
        self.timestamp = time.strftime("%Y%m%d-%H%M%S")

        self.show_banner()
        self.create_dirs()

        self.subdomain_enum = SubdomainEnumerator(domain, output_dir)
        self.http_prober = HTTPProber(output_dir)
        self.url_gatherer = URLGatherer(output_dir)

    def show_banner(self):
        print("\n" * 3)
        time.sleep(0.3)

        banner_lines = [
            " @@@@@@@@  @@@  @@@   @@@@@@    @@@@@@   @@@@@@@      @@@@@@   @@@@@@@   @@@@@@   @@@@@@   ",
            "@@@@@@@@@  @@@  @@@  @@@@@@@@  @@@@@@@   @@@@@@@     @@@@@@@   @@@@@@@@  @@@@@@@  @@@@@@@  ",
            "!@@        @@!  @@@  @@!  @@@  !@@         @@!       !@@       @@!  @@@      @@@      @@@  ",
            "!@!        !@!  @!@  !@!  @!@  !@!         !@!       !@!       !@!  @!@      @!@      @!@  ",
            "!@! @!@!@  @!@!@!@!  @!@  !@!  !!@@!!      @!!       !!@@!!    @!@!!@!   @!@!!@   @!@!!@   ",
            "!!! !!@!!  !!!@!!!!  !@!  !!!   !!@!!!     !!!        !!@!!!   !!@!@!    !!@!@!   !!@!@!   ",
            ":!!   !!:  !!:  !!!  !!:  !!!       !:!    !!:            !:!  !!: :!!       !!:      !!:  ",
            ":!:   !::  :!:  !:!  :!:  !:!      !:!     :!:           !:!   :!:  !:!      :!:      :!:  ",
            " ::: ::::  ::   :::  ::::: ::  :::: ::      ::       :::: ::   ::   :::  :: ::::  :: ::::  ",
            " :: :: :    :   : :   : :  :   :: : :       :        :: : :     :   : :   : : :    : : :   "
        ]

        for line in banner_lines:
            for char in line:
                sys.stdout.write(f"\033[1;35m{char}\033[0m")
                sys.stdout.flush()
                time.sleep(0.0035)  # Slower for dramatic effect
            print()

        print()
        self.typing_effect("\033[1;36mGHOST_RECON v1.0 - Advanced Reconnaissance Tool\033[0m", speed=0.025)
        self.typing_effect("\033[1;33mAuthor: GhostOperator | Twitter: @ghostrecon\033[0m\n", speed=0.025)
        self.typing_effect(f"Initializing scan for: \033[1;31m{self.domain}\033[0m\n", speed=0.035)

    def typing_effect(self, text, speed=0.03):
        for char in text:
            sys.stdout.write(char)
            sys.stdout.flush()
            time.sleep(speed)
        print()

    def create_dirs(self):
        os.makedirs(self.output_dir, exist_ok=True)
        os.makedirs(f"{self.output_dir}/subdomains", exist_ok=True)
        os.makedirs(f"{self.output_dir}/urls", exist_ok=True)
        os.makedirs(f"{self.output_dir}/scans", exist_ok=True)

    def run_subdomain_enumeration(self):
        self.typing_effect(f"\n\033[1;32m[+] Starting subdomain enumeration for \033[1;33m{self.domain}\033[0m", speed=0.02)
        self.subdomain_enum.run_all()
        combined = self.subdomain_enum.combine_results()
        self.typing_effect(f"\033[1;32m[+] Found \033[1;33m{len(combined)}\033[1;32m unique subdomains\033[0m", speed=0.02)
        return combined

    def run_http_probing(self, subdomains):
        self.typing_effect(f"\n\033[1;32m[+] Probing \033[1;33m{len(subdomains)}\033[1;32m subdomains for live HTTP services\033[0m", speed=0.02)
        live_urls = self.http_prober.probe_subdomains(subdomains)
        self.typing_effect(f"\033[1;32m[+] Found \033[1;33m{len(live_urls)}\033[1;32m live HTTP services\033[0m", speed=0.02)
        return live_urls

    def run_url_gathering(self, live_urls):
        self.typing_effect(f"\n\033[1;32m[+] Gathering URLs from Gau and Waybackurls\033[0m", speed=0.02)
        all_urls = self.url_gatherer.gather_all(live_urls)
        self.typing_effect(f"\033[1;32m[+] Collected \033[1;33m{len(all_urls)}\033[1;32m unique URLs\033[0m", speed=0.02)
        return all_urls

    def run(self):
        self.typing_effect(f"\n\033[1;35m[~] GHOST_RECON started for \033[1;33m{self.domain}\033[1;35m at \033[1;36m{self.timestamp}\033[0m", speed=0.02)
        subdomains = self.run_subdomain_enumeration()
        live_urls = self.run_http_probing(subdomains)
        all_urls = self.run_url_gathering(live_urls)

        final_output = {
            "domain": self.domain,
            "subdomains": list(subdomains),
            "live_urls": live_urls,
            "all_urls": all_urls,
            "timestamp": self.timestamp
        }

        with open(f"{self.output_dir}/final_results.json", "w") as f:
            json.dump(final_output, f, indent=2)

        self.typing_effect(f"\n\033[1;32m[✓] GHOST_RECON completed! Results saved to \033[1;33m{self.output_dir}\033[0m", speed=0.02)
        print("\033[1;35m" + "="*80 + "\033[0m")

def main():
    parser = argparse.ArgumentParser(description="GHOST_RECON - Advanced Subdomain Enumeration and Reconnaissance Tool")
    parser.add_argument("-d", "--domain", required=True, help="Target domain to scan")
    parser.add_argument("-o", "--output", default="ghost_recon_results", help="Output directory")
    parser.add_argument("-t", "--threads", type=int, default=10, help="Number of threads to use")

    args = parser.parse_args()

    try:
        recon = GhostRecon(args.domain, args.output, args.threads)
        recon.run()
    except KeyboardInterrupt:
        print("\n\033[1;31m[-] Scan interrupted by user\033[0m")
        sys.exit(1)
    except Exception as e:
        print(f"\033[1;31m[-] Error: {e}\033[0m")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# Create the modules
cat > "$MODULES_DIR/subdomains.py" << 'EOF'
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor

class SubdomainEnumerator:
    def __init__(self, domain, output_dir):
        self.domain = domain
        self.output_dir = output_dir
        self.tools = ["subfinder", "subdominator"]
        
    def typing_effect(self, text, speed=0.03):
        """Create typing effect for text output"""
        for char in text:
            sys.stdout.write(char)
            sys.stdout.flush()
            time.sleep(speed)
        print()
        
    def run_tool(self, tool):
        """Run a single subdomain enumeration tool"""
        output_file = f"{self.output_dir}/subdomains/{tool}.txt"
        
        self.typing_effect(f"\033[1;34m[~] Running \033[1;33m{tool}\033[1;34m on \033[1;36m{self.domain}\033[0m")
        
        if tool == "subfinder":
            cmd = f"subfinder -d {self.domain} -silent -o {output_file}"
        elif tool == "subdominator":
            cmd = f"subdominator -d {self.domain} -o {output_file}"
        else:
            return set()
            
        try:
            subprocess.run(cmd, shell=True, check=True)
            results = self.read_results(output_file)
            self.typing_effect(f"\033[1;32m[✓] {tool} found \033[1;33m{len(results)}\033[1;32m subdomains\033[0m")
            return results
        except:
            self.typing_effect(f"\033[1;31m[✗] {tool} failed to run\033[0m")
            return set()
            
    def read_results(self, file_path):
        """Read results from a file and return as set"""
        if not os.path.exists(file_path):
            return set()
            
        with open(file_path, "r") as f:
            return set(line.strip() for line in f if line.strip())
            
    def run_all(self):
        """Run all enumeration tools in parallel"""
        with ThreadPoolExecutor() as executor:
            results = list(executor.map(self.run_tool, self.tools))
            
        # Save combined results
        combined = set().union(*results)
        with open(f"{self.output_dir}/subdomains/combined.txt", "w") as f:
            f.write("\n".join(combined))
            
        return combined
        
    def combine_results(self):
        """Combine results from all tools"""
        combined = set()
        for tool in self.tools:
            tool_file = f"{self.output_dir}/subdomains/{tool}.txt"
            combined.update(self.read_results(tool_file))
            
        return combined
EOF

cat > "$MODULES_DIR/http_probe.py" << 'EOF'
import os
import subprocess
import sys
import time

class HTTPProber:
    def __init__(self, output_dir):
        self.output_dir = output_dir
        
    def typing_effect(self, text, speed=0.03):
        """Create typing effect for text output"""
        for char in text:
            sys.stdout.write(char)
            sys.stdout.flush()
            time.sleep(speed)
        print()
        
    def probe_subdomains(self, subdomains):
        """Probe subdomains for live HTTP services using httpx"""
        input_file = f"{self.output_dir}/subdomains/combined.txt"
        output_file = f"{self.output_dir}/subdomains/live_urls.txt"
        
        # Write subdomains to file
        with open(input_file, "w") as f:
            f.write("\n".join(subdomains))
            
        self.typing_effect("\033[1;34m[~] Probing for live HTTP services with \033[1;33mhttpx\033[0m")
        
        # Run httpx
        cmd = f"httpx -l {input_file} -silent -o {output_file}"
        try:
            subprocess.run(cmd, shell=True, check=True)
            if os.path.exists(output_file):
                with open(output_file, "r") as f:
                    results = [line.strip() for line in f if line.strip()]
                self.typing_effect(f"\033[1;32m[✓] Found \033[1;33m{len(results)}\033[1;32m live HTTP services\033[0m")
                return results
        except:
            self.typing_effect("\033[1;31m[✗] HTTP probing failed\033[0m")
            return []
EOF

cat > "$MODULES_DIR/url_gather.py" << 'EOF'
import os
import subprocess
import sys
import time
import re
from concurrent.futures import ThreadPoolExecutor

class URLGatherer:
    def __init__(self, output_dir, timeout=300, threads=10):
        self.output_dir = output_dir
        self.timeout = timeout
        self.threads = threads
        self.blacklist = [
            '\.jpg', '\.jpeg', '\.png', '\.gif', '\.css', '\.js',
            '\.woff', '\.woff2', '\.svg', '\.ico', '\.ttf', '\.pdf',
            '\.mp3', '\.mp4', '\.webp', '\.eot'
        ]
        self.create_urls_dir()

    def create_urls_dir(self):
        """Ensure URLs directory exists"""
        os.makedirs(f"{self.output_dir}/urls", exist_ok=True)

    def sanitize_domain(self, domain):
        """Extract root domain from URL"""
        if '://' in domain:
            domain = domain.split('://')[1]
        domain = domain.split('/')[0]
        return domain.split(':')[0]

    def get_base_domain(self, domain):
        """Extract base domain (swiggy.com from api.swiggy.com)"""
        domain = self.sanitize_domain(domain)
        parts = domain.split('.')
        if len(parts) > 2:
            return '.'.join(parts[-2:])
        return domain

    def typing_effect(self, text, speed=0.03):
        """Improved typing effect without corruption"""
        for char in text:
            sys.stdout.write(char)
            sys.stdout.flush()
            time.sleep(speed)
        print()

    def run_command(self, cmd, tool_name, output_file):
        """Safe command execution with error handling"""
        try:
            # Create directory if it doesn't exist
            os.makedirs(os.path.dirname(output_file), exist_ok=True)
            
            # Run command with timeout
            result = subprocess.run(
                cmd,
                shell=True,
                check=True,
                timeout=self.timeout,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Write filtered output
            if result.stdout:
                filtered = self.filter_urls(result.stdout.splitlines())
                with open(output_file, 'w') as f:
                    f.write('\n'.join(filtered))
                return filtered
            
        except subprocess.TimeoutExpired:
            self.typing_effect(f"\033[1;33m[!] {tool_name} timed out after {self.timeout}s\033[0m")
        except subprocess.CalledProcessError as e:
            self.typing_effect(f"\033[1;31m[✗] {tool_name} failed: {e.stderr.strip()}\033[0m")
        except Exception as e:
            self.typing_effect(f"\033[1;31m[✗] {tool_name} error: {str(e)}\033[0m")
        return []

    def filter_urls(self, urls):
        """Filter URLs based on blacklist patterns"""
        pattern = '|'.join(self.blacklist)
        return [url for url in urls if url and not re.search(pattern, url, re.I)]

    def gather_gau(self, domain):
        """Optimized GAU URL gathering"""
        base_domain = self.get_base_domain(domain)
        output_file = f"{self.output_dir}/urls/gau_{base_domain}.txt"
        
        self.typing_effect(f"\033[1;34m[~] Running gau on {base_domain}\033[0m")
        
        cmd = (
            f"gau {base_domain} --subs --threads {self.threads} "
            f"--blacklist ttf,woff,svg,png,jpg,jpeg,gif,css,js,mp3,mp4"
        )
        
        results = self.run_command(cmd, "gau", output_file)
        if results:
            self.typing_effect(f"\033[1;32m[✓] gau found {len(results)} URLs\033[0m")
        return set(results)

    def gather_waybackurls(self, domain):
        """Optimized Waybackurls gathering"""
        base_domain = self.get_base_domain(domain)
        output_file = f"{self.output_dir}/urls/wayback_{base_domain}.txt"
        
        self.typing_effect(f"\033[1;34m[~] Running waybackurls on {base_domain}\033[0m")
        
        cmd = f"waybackurls {base_domain}"
        results = self.run_command(cmd, "waybackurls", output_file)
        if results:
            self.typing_effect(f"\033[1;32m[✓] waybackurls found {len(results)} URLs\033[0m")
        return set(results)

    def gather_all(self, domains):
        """Main URL gathering function with improved domain handling"""
        all_urls = set()
        processed_domains = set()
        
        for domain in domains:
            base_domain = self.get_base_domain(domain)
            if base_domain in processed_domains:
                continue
            processed_domains.add(base_domain)
            
            with ThreadPoolExecutor(max_workers=2) as executor:
                futures = {
                    executor.submit(self.gather_gau, base_domain),
                    executor.submit(self.gather_waybackurls, base_domain)
                }
                
                for future in futures:
                    try:
                        all_urls.update(future.result())
                    except Exception as e:
                        self.typing_effect(f"\033[1;31m[✗] Error: {str(e)}\033[0m")
        
        # Save final results
        combined_file = f"{self.output_dir}/urls/combined.txt"
        with open(combined_file, 'w') as f:
            f.write('\n'.join(all_urls))
            
        return list(all_urls)
EOF

# Make the main script executable
chmod +x "$INSTALL_DIR/ghost_recon.py"

# Create symlink in /usr/local/bin for easy access
if [ ! -f "/usr/local/bin/ghostrecon" ]; then
    ln -s "$INSTALL_DIR/ghost_recon.py" /usr/local/bin/ghostrecon
    echo -e "${GREEN}[✓] Created symlink in /usr/local/bin/ghostrecon${NC}"
else
    echo -e "${YELLOW}[!] Symlink already exists in /usr/local/bin/ghostrecon${NC}"
fi

# Final message
echo -e "\n${GREEN}[✓] GhostRecon installation completed successfully!${NC}"
echo -e "${BLUE}You can now run the tool using:${NC}"
echo -e "  ghostrecon -d example.com"
echo -e "\n${YELLOW}Note: You may need to restart your terminal or run 'source ~/.bashrc' for the changes to take effect.${NC}"
