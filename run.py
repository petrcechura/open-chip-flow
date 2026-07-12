#!/usr/bin/env python3

from __future__ import annotations

import argparse
from abc import ABC, abstractmethod

from tasks_py.task_verif import *

class Task(ABC):
    """Base class for all tasks."""

    #: Name used on the command line.
    name: str = ""

    #: Help shown in `--help`.
    help: str = ""

    @classmethod
    def register(cls, subparsers: argparse._SubParsersAction):
        """Register this task and its arguments."""
        parser = subparsers.add_parser(
            cls.name,
            help=cls.help,
            description=cls.help,
        )

        cls.add_arguments(parser)
        parser.set_defaults(task_cls=cls)

    @classmethod
    @abstractmethod
    def add_arguments(cls, parser: argparse.ArgumentParser):
        """Define task-specific arguments."""

    @abstractmethod
    def run(self):
        """Execute the task."""

    def __init__(self, args: argparse.Namespace):
        self.args = args


TASKS = [
    VerifTask
]


def create_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="run.py",
    )

    subparsers = parser.add_subparsers(
        dest="task",
        required=True,
    )

    for task in TASKS:
        task.register(subparsers)

    return parser


def main():
    parser = create_parser()
    args = parser.parse_args()

    task = args.task_cls(args)
    task.run()


if __name__ == "__main__":
    main()