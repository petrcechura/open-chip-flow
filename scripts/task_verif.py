from .Task import *
import yaml
import os
import subprocess

class VerifTask(Task):
    name = "verif"
    help = "Run verification using Verilator"

    # Path to default UVM directory, where the implementations are expected
    UVM_DEFAULT_DIR = os.path.join('verif', 'lib', 'UVM')
    UVM_DEFAULT_VERSION = '1.2'
    UVM_AVAILABLE_VERSIONS = ['1.1d', '1.2', '1800.2-2017', '1800.2-2020']
    MAX_JOBS = 8

    @classmethod
    def add_arguments(cls, parser):
        parser.add_argument("yaml", action="store")
        parser.add_argument("--jobs", type=int, default=1)
        parser.add_argument("--work-dir", type=str, default='work')
        parser.add_argument("--uvm-version", type=str, default=cls.UVM_DEFAULT_VERSION)

    def run(self):
        ''' Verification task implementation '''
        
        # Sanity check
        if not self.args.yaml:
            self.report_error('Cannot proceed without YAML file defined!')

        elif not os.path.isfile(self.args.yaml):
            self.report_error('YAML file does not exist!')

        if not self.args.uvm_version in self.UVM_AVAILABLE_VERSIONS:
            self.report_error(f'Unsupported UVM version {self.args.uvm_version}! Choose from {self.UVM_AVAILABLE_VERSIONS}...')

        # Define a working directory for temporary files
        work_dir = self.args.work_dir
        if not os.path.exists(work_dir):
            self.report_info(f'Creating {work_dir} directory...')
            os.mkdir(work_dir)
        
        # Read YAML file into data structure
        files = []
        for path in ['design/rtl/files', 'design/verif/files']:
            try:
                files.extend(self.get_yaml_node(self.args.yaml, path))
            except Exception:
                self.report_info(f'Failed to read {path}')

        top_module = self.get_yaml_node(self.args.yaml, 'design/verif/top_module')

        # Get path to directory where UVM library is located
        # and include the UVM in files for Verilator
        uvm_dir = os.path.join(self.UVM_DEFAULT_DIR, self.args.uvm_version, 'src')
        uvm_file = os.path.join(uvm_dir, 'uvm.sv')
        files.append(uvm_file)

        # Run the simulation
        bin_file = f'V{top_module}'

        ## compile design
        self.report_info('Compiling SystemVerilog files using Verilator tool...', 1)
        subprocess.run(['verilator', 
                        '--binary', 
                        '--Mdir',
                        work_dir,
                        '--trace',
                        '--top-module',
                        top_module,
                        '--Wno-fatal',
                        '--j',
                        str(self.args.jobs),
                        f'--I{uvm_dir}',
                        *files])

        ## run object file
        self.report_info('Running simulation...', 1)
        subprocess.run([str(os.path.join(work_dir, bin_file))])



        