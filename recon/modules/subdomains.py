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
