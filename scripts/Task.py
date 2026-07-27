import argparse
from abc import ABC, abstractmethod
import yaml
import os

class Task(ABC):
    """Base class for all tasks."""

    #: Name used on the command line.
    name: str = ""

    #: Help shown in `--help`.
    help: str = ""

    YAML_PATH_DELIMITER = "/"

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
    def get_yaml_node(
        cls,
        # path to yaml file (abs or rel)
        yaml_file: str,
        # path inside the yaml file to extract the node into python structure
        path: str = "",
        # if true, !include tags are resolved
        expand_nested: bool = True,
    ):
        """
        Read YAML file and return python data structure below node defined
        by the 'path' argument.

        Optionally, !include tags can be used to nest additional yaml files,
        recursively reading and extending final structure.
        """

        # Aux. class definition for the !include tag
        class _Include:
            """Represents a !include YAML tag."""

            def __init__(self, file: str, path: str = ""):
                self.file = file
                self.path = path

        def include_constructor(loader, node):
            if isinstance(node, yaml.ScalarNode):
                return _Include(loader.construct_scalar(node))

            mapping = loader.construct_mapping(node)

            return _Include(
                mapping["file"],
                mapping.get("path", ""),
            )

        yaml.SafeLoader.add_constructor("!include", include_constructor)

        # Cache of already-loaded files (by absolute path) to avoid
        # re-parsing the same include multiple times.
        _cache: dict = {}

        def load_yaml(filename, _include_chain=()):
            filename = os.path.abspath(filename)

            # Guard against circular !include references.
            if filename in _include_chain:
                chain = " -> ".join(list(_include_chain) + [filename])
                raise Exception(f"Circular !include detected: {chain}")

            if filename in _cache:
                return _cache[filename]

            if not os.path.isfile(filename):
                referrer = (
                    f" (included from '{_include_chain[-1]}')"
                    if _include_chain
                    else ""
                )
                raise Exception(
                    f"YAML file not found: '{filename}'{referrer}"
                )

            with open(filename, "r", encoding="utf-8") as f:
                try:
                    data = yaml.load(f, yaml.SafeLoader)
                except yaml.YAMLError as e:
                    raise Exception(
                        f"Failed to parse YAML file '{filename}': {e}"
                    ) from e

            if expand_nested:
                data = expand(
                    data,
                    os.path.dirname(filename),
                    _include_chain + (filename,),
                )

            _cache[filename] = data
            return data

        def expand(node, base_dir, include_chain):
            if isinstance(node, dict):
                return {
                    k: expand(v, base_dir, include_chain)
                    for k, v in node.items()
                }

            if isinstance(node, list):
                return [
                    expand(v, base_dir, include_chain)
                    for v in node
                ]

            if isinstance(node, _Include):
                filename = os.path.join(base_dir, node.file)
                data = load_yaml(filename, include_chain)

                if node.path:
                    data = lookup(data, node.path, source=filename)

                return data

            return node

        def lookup(data, path, source=yaml_file):
            if not path:
                return data

            node = data
            traversed = []

            for part in path.strip(cls.YAML_PATH_DELIMITER).split(
                cls.YAML_PATH_DELIMITER
            ):
                traversed.append(part)
                where = cls.YAML_PATH_DELIMITER.join(traversed)

                if isinstance(node, dict):
                    if part not in node:
                        available = ", ".join(map(str, node.keys())) or "<empty>"
                        raise Exception(
                            f"Key '{part}' not found at '{where}' in "
                            f"'{source}'. Available keys: {available}"
                        )
                    node = node[part]

                elif isinstance(node, list):
                    if not part.lstrip("-").isdigit():
                        raise Exception(
                            f"Expected a list index at '{where}' in "
                            f"'{source}', got '{part}'"
                        )
                    idx = int(part)
                    if idx < -len(node) or idx >= len(node):
                        raise Exception(
                            f"Index {idx} out of range (0..{len(node) - 1}) "
                            f"at '{where}' in '{source}'"
                        )
                    node = node[idx]

                else:
                    raise Exception(
                        f"Cannot descend into '{part}' at '{where}' in "
                        f"'{source}': parent is of type "
                        f"'{type(node).__name__}', not a mapping or list"
                    )

            return node

        data = load_yaml(yaml_file)

        return lookup(data, path)

    @classmethod
    @abstractmethod
    def add_arguments(cls, parser: argparse.ArgumentParser):
        """Define task-specific arguments."""

    @classmethod
    @abstractmethod
    def run(self):
        """Execute the task."""

    def __init__(self, args: argparse.Namespace):
        self.args = args