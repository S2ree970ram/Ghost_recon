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
