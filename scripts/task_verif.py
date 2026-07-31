from .Task import *
import yaml
import os
import subprocess

class VerifTask(Task):
    name = "verif"
    help = "Run verification using Verilator"

    # Path to default UVM directory, where the implementations are expected
    UVM_DEFAULT_DIR = os.path.join('verif', 'lib', 'UVM')
    UVM_DEFAULT_VERSION = '1.1d'
    UVM_AVAILABLE_VERSIONS = ['1.1d', '1.2', '1800.2-2017', '1800.2-2020']

    JOBS_MAX = 16
    JOBS_DEFAULT = 8

    @classmethod
    def add_arguments(cls, parser):
        parser.add_argument("yaml", action="store")
        parser.add_argument("--jobs", type=int, default=cls.JOBS_DEFAULT)
        parser.add_argument("--work-dir", type=str, default='work')
        parser.add_argument("--uvm-version", type=str, default=cls.UVM_DEFAULT_VERSION)
        parser.add_argument("--debug", action="store_true")
        parser.add_argument("--test", type=str, action="store")

    def run(self):
        ''' Verification task implementation '''
        
        # Sanity check
        if not self.args.yaml:
            self.report_error('Cannot proceed without YAML file defined!')

        elif not os.path.isfile(self.args.yaml):
            self.report_error('YAML file does not exist!')

        if not self.args.uvm_version in self.UVM_AVAILABLE_VERSIONS:
            self.report_error(f'Unsupported UVM version {self.args.uvm_version}! Choose from {self.UVM_AVAILABLE_VERSIONS}...')
        
        if not self.args.test:
            self.report_error(f'No test has been defined via --test argument!')

        # Define a working directory for temporary files
        work_dir = self.args.work_dir
        if not os.path.exists(work_dir):
            self.report_info(f'Creating {work_dir} directory...')
            os.mkdir(work_dir)
        
        # Read YAML file into data structure
        cwd = os.path.dirname(self.args.yaml)
        files = []
        includes = []
        for path in ['design/rtl/files', 'design/verif/files']:

            try:
                _f = [os.path.join(cwd, f) for f in self.get_yaml_node(self.args.yaml, path)]
                files.extend(_f)
                includes.extend([os.path.dirname(_i) for _i in _f])

            except Exception:
                self.report_info(f'Failed to read {path}')

        for path in ['design/rtl/includes', 'design/verif/includes']:
            try:
                includes.extend([os.path.join(cwd, f) for f in self.get_yaml_node(self.args.yaml, path)])
            except Exception:
                self.report_info(f'Failed to read {path}')

        try: 
            top_module = self.get_yaml_node(self.args.yaml, 'design/verif/top_module')
        except Exception:
            self.report_error(f'Failed to extract `top_module` from {self.args.yaml}')

        # Get path to directory where UVM library is located
        # and include the UVM in files for Verilator
        uvm_dir = os.path.join(self.UVM_DEFAULT_DIR, self.args.uvm_version, 'src')
        uvm_file = os.path.join(uvm_dir, 'uvm.sv')

        # Run the simulation
        bin_file = f'V{top_module}'

        ## compile design
        self.report_info('Compiling SystemVerilog files using Verilator tool...', 1)
        result = subprocess.run(['verilator', 
                                 '--binary', 
                                 '--Mdir',
                                 work_dir,
                                 '--trace',
                                 '--top-module',
                                 top_module,
                                 '--Wno-fatal',
                                 '--j',
                                 str(self.args.jobs),
                                 '--debug' if self.args.debug else '',
                                 '--gdbbt' if self.args.debug else '',
                                 f'--I{uvm_dir}',
                                 *[f'--I{i}' for i in includes],
                                 '-DUVM_NO_DPI',
                                 '-DUSING_VERILATOR',
                                 uvm_file,
                                 *files],
                                 text=True)

        if result.returncode != 0:
            self.report_error('Aborting simulation due to compilation errors...')

        ## run object file
        self.report_info('Running simulation...', 1)
        subprocess.run([str(os.path.join(work_dir, bin_file)),
                        f'+UVM_TESTNAME={self.args.test}']
                        )



        