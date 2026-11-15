"""Checks that incorrect or incomplete measurements cannot produce a speed ratio."""

from pathlib import Path
import unittest

import benchmark_compare as bench


class FakeAdapter:
    def __init__(self, failure=None):
        self.calls = []
        self.failure = failure

    def prepare(self, tool, executable, design, work):
        return None, lambda count: [tool, str(count)]

    def run(self, command, work):
        tool, count = command
        count = int(count)
        self.calls.append((tool, count))
        line = f"example n={count} answer=7"
        if self.failure == (tool, count):
            line = f"example n={count} answer=8"
        return {"seconds": (1 if count == 1 else 11) * (2 if tool == "kirimasim" else 1),
                "max_rss_mib": 16, "rss_source": "fake", "exit_code": 0,
                "timed_out": False, "stdout": line, "stderr": "explanation"}

    def sample(self, name, result):
        return {**{key: result[key] for key in ("seconds", "max_rss_mib", "rss_source",
                                               "exit_code", "timed_out")},
                "result_line": result["stdout"]}


class BenchmarkComparisonTests(unittest.TestCase):
    def measure(self, adapter, index=0):
        case = {"name": "example", "path": Path("example.sv"), "count": 10,
                "expected": "example n=10 answer=7", "expected_small": None,
                "source": "example.sv", "sha256": "test"}
        return bench.collect_case(case, adapter, {name: name for name in bench.TOOLS},
                                  5, index, lambda value, work: value)

    def test_serial_alternating_schedule_and_complete_samples(self):
        adapter = FakeAdapter()
        result = self.measure(adapter)
        self.assertEqual(len(adapter.calls), 22)
        self.assertEqual(adapter.calls[:6], [("kirimasim", 1), ("icarus", 1),
                                            ("kirimasim", 1), ("kirimasim", 10),
                                            ("icarus", 1), ("icarus", 10)])
        self.assertEqual(adapter.calls[6:10], [("icarus", 10), ("icarus", 1),
                                              ("kirimasim", 10), ("kirimasim", 1)])
        self.assertEqual(result["comparison"]["ratio"], 2)
        for record in result["tools"].values():
            self.assertEqual(len(record["samples"]["large"]), 5)
            self.assertEqual(len(record["samples"]["small"]), 5)
        other = FakeAdapter()
        self.measure(other, 1)
        self.assertEqual(other.calls[2][0], "icarus")

    def test_incorrect_full_output_suppresses_ratio_and_retains_diagnostics(self):
        result = self.measure(FakeAdapter(("kirimasim", 10)))
        self.assertIsNone(result["comparison"]["ratio"])
        error = result["tools"]["kirimasim"]["error"]
        self.assertEqual(error["stage"], "large")
        self.assertIn("answer=8", error["diagnostics"]["stdout"])
        self.assertEqual(error["diagnostics"]["stderr"], "explanation")

    def test_disagreeing_baseline_suppresses_ratio(self):
        result = self.measure(FakeAdapter(("icarus", 1)))
        self.assertIsNone(result["comparison"]["ratio"])
        self.assertEqual(result["tools"]["icarus"]["error"]["stage"], "baseline correctness")

    def test_timeout_exit_and_wrong_count_are_rejected(self):
        sample = {"timed_out": False, "exit_code": 0, "result_line": "example n=10 answer=7"}
        for change in ({"timed_out": True}, {"exit_code": 1},
                       {"result_line": "example n=100 answer=7"}):
            self.assertIsNotNone(bench.check_sample({**sample, **change}, "example", 10, None))

    def test_nonpositive_delta_and_incomplete_repetitions(self):
        records = {name: {"incremental_seconds": value} for name, value in
                   (("kirimasim", 0), ("icarus", 1))}
        self.assertIsNone(bench.comparison(records)["ratio"])
        record = {"samples": {"small": [], "large": []}}
        bench.aggregate(record, 5)
        self.assertEqual(record["error"]["stage"], "aggregation")


if __name__ == "__main__":
    unittest.main()
