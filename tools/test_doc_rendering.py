"""Documentation must show array syntax without inventing Markdown links."""

import re
import unittest

import behavior_coverage
import suite_catalog


class DocumentationRenderingTests(unittest.TestCase):
    def test_catalog_description_keeps_only_the_generated_test_link(self):
        entry = {"name": "test_resize", "path": "tests/ch7/test_resize.sv",
                 "what": "new[n](old), new[](init), and a[2](element)",
                 "clauses": ["7.5.1"], "oracle": "standard only", "notes": ""}
        output = "\n".join(suite_catalog.table([entry]))
        links = re.findall(r"(?<!\\)\[[^\]\n]*\]\(([^)]+)\)", output)
        self.assertEqual(links, ["../../tests/ch7/test_resize.sv"])
        self.assertIn("new[n](old)", output.replace("\\[", "[").replace("\\]", "]"))

    def test_coverage_prose_preserves_code_and_escapes_literal_arrays(self):
        source = r"new[4](d), `a[2](d)`, `` `define A[n](x) ``, and existing \[3\]"
        output = behavior_coverage.markdown_prose(source)
        self.assertIn("`a[2](d)`", output)
        self.assertIn("`` `define A[n](x) ``", output)
        self.assertIn(r"existing \[3\]", output)
        outside_code = re.sub(r"(`+).*?\1", "", output)
        self.assertNotRegex(outside_code, r"(?<!\\)\[[^\]]*\]\(")


    def test_sva_terms_preserve_literal_output_and_random_sequence_terms(self):
        source = '系列と性質、非空成功と空成功。`$display("空成功")`'
        output = behavior_coverage.markdown_prose(source, "16.12")
        self.assertIn("シーケンスとプロパティ、nonvacuous passとvacuous pass", output)
        self.assertIn('`$display("空成功")`', output)
        random_text = "乱数系列と時系列、生成器の性質"
        self.assertEqual(behavior_coverage.markdown_prose(random_text, "18.14"), random_text)


if __name__ == "__main__":
    unittest.main()
