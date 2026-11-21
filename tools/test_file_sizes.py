"""file_sizes.py fails on a tracked file over the limit."""

from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

import file_sizes


class Sizes(unittest.TestCase):
    def test_only_tracked_files_count_and_the_largest_come_first(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            (root / "small.txt").write_bytes(b"x" * 10)
            (root / "large.txt").write_bytes(b"x" * 3000)
            (root / "untracked.txt").write_bytes(b"x" * 9000)
            subprocess.run(["git", "-C", str(root), "add", "small.txt", "large.txt"], check=True)
            self.assertEqual(file_sizes.tracked(root), [(3000, "large.txt"), (10, "small.txt")])

    def test_check_fails_over_the_limit(self):
        with mock.patch.object(file_sizes, "tracked", return_value=[(41 << 20, "big.json"), (1, "a")]), \
                mock.patch("sys.argv", ["file_sizes.py", "--check"]), mock.patch("sys.stdout"), \
                mock.patch("sys.stderr"):
            self.assertEqual(file_sizes.main(), 1)
        with mock.patch.object(file_sizes, "tracked", return_value=[(39 << 20, "big.json")]), \
                mock.patch("sys.argv", ["file_sizes.py", "--check"]), mock.patch("sys.stdout"):
            self.assertEqual(file_sizes.main(), 0)


if __name__ == "__main__":
    unittest.main()
