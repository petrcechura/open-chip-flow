from .vf_task import *
from yaml import *

class VerifTask(Task):
    name = "verif"
    help = "Run verification using Verilator"

    @classmethod
    def add_arguments(cls, parser):
        parser.add_argument("yaml", action="store")
        parser.add_argument("--jobs", type=int, default=1)
        parser.add_argument("--uvm-version", type=str, default="2020")

    def run(self):
        
        if not cls.yaml:
            print('Cannot proceed without YAML file defined!')
            exit(1)