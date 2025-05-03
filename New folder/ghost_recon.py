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
