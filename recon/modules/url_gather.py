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
