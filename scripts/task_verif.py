# ----------------------------------------------------------------------
# Example task
# ----------------------------------------------------------------------

from vf_task import *
from yaml import *

class VerifTask(Task):
    name = "build"
    help = "Build the project"

    @classmethod
    def add_arguments(cls, parser):
        parser.add_argument("yaml", action="store")
        parser.add_argument("--jobs", type=int, default=1)

    def run(self):
        
        if not cls.yaml:
            print('Cannot proceed without YAML file defined!')
            exit(1)