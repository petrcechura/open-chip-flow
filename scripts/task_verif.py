from .Task import *
import yaml
import os
import subprocess

class VerifTask(Task):
    name = "verif"
    help = "Run verification using Verilator"

    @classmethod
    def add_arguments(cls, parser):
        parser.add_argument("yaml", action="store")
        parser.add_argument("--jobs", type=int, default=1)

    def run(self):
        ''' Verification task implementation '''
        
        # Sanity check
        if not self.args.yaml:
            print('Cannot proceed without YAML file defined!')
            exit(1)
        elif not os.path.isfile(self.args.yaml):
            prinnt('YAML file does not exist!')
            exit(1) 

        # Read YAML file into data structure
        files = []
        for path in ['design/rtl/files', 'design/verif/files']:
            try:
                files.extend(self.get_yaml_node(self.args.yaml, path))
            except Exception:
                print(f'Failed to read {path}')

        uvm_args = ""

        
        subprocess.run(['verilator', '--binary', '--trace', '--Wno-fatal', ' '.join(files)])

        