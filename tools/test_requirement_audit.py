"""Extraction must account for the complete source, not only modal-word hits."""

import contextlib
import hashlib
import io
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import behavior_coverage as coverage
import requirement_audit as audit
import requirement_source as source


class SourceAuditTests(unittest.TestCase):
    def setUp(self):
        self.sections = {"5.3": {"review": "complete"}}
        self.index = {"schema": 1, "pdf_sha256": "pdf", "text_sha256": "text",
                      "sections": {"5.3": {"sha256": "section", "blocks": [
                          {"id": "B001"}, {"id": "B002"}]}}}
        self.review = {"schema": 1, "pdf_sha256": "pdf", "text_sha256": "text", "sections": {
            "5.3": {"state": "complete", "source_sha256": "section", "reviewer": "AI",
                    "reviewed_on": "2026-10-22", "scope_note": "Complete own-body review",
                    "visual_review": "No non-text table or figure",
                    "blocks": {"B001": {"disposition": "heading", "rationale": "Heading"},
                               "B002": {"disposition": "requirements", "rationale": "All rules",
                                        "requirements": ["R1"]}}}}}
        self.rules = [{"id": "R1", "source_spans": [{"section": "5.3", "blocks": ["B002"]}]}]

    def validate(self):
        return audit.validate(self.index, self.review, self.sections, self.rules)

    def test_complete_source_block_audit(self):
        self.assertEqual(self.validate(), {"audited": 1, "classified_blocks": 2})

    def test_unaccounted_block_cannot_be_hidden(self):
        del self.review["sections"]["5.3"]["blocks"]["B002"]
        with self.assertRaisesRegex(coverage.InvalidCoverage, "unaccounted"):
            self.validate()

    def test_keyword_candidate_is_not_a_review_disposition(self):
        self.review["sections"]["5.3"]["blocks"]["B002"]["disposition"] = "contains-shall"
        with self.assertRaisesRegex(coverage.InvalidCoverage, "unresolved source block"):
            self.validate()

    def test_completed_section_needs_source_evidence(self):
        self.review["sections"].clear()
        with self.assertRaisesRegex(coverage.InvalidCoverage, "lacks source-block audit"):
            self.validate()

    def test_same_pdf_with_different_text_is_not_the_same_source(self):
        self.review["text_sha256"] = "other text"
        with self.assertRaisesRegex(coverage.InvalidCoverage, "text extraction identity"):
            self.validate()

    def test_source_edit_invalidates_review(self):
        self.index["sections"]["5.3"]["sha256"] = "new section"
        with self.assertRaisesRegex(coverage.InvalidCoverage, "stale section audit"):
            self.validate()

    def test_block_must_name_real_extracted_rules(self):
        self.rules.clear()
        with self.assertRaisesRegex(coverage.InvalidCoverage, "unknown extracted rule"):
            self.validate()

    def test_rule_and_block_associations_are_bidirectional(self):
        self.rules[0]["source_spans"][0]["blocks"] = ["B001", "B002"]
        with self.assertRaisesRegex(coverage.InvalidCoverage, "orphaned rule"):
            self.validate()

    def test_rule_must_acknowledge_the_claimed_source(self):
        self.rules[0]["source_spans"] = []
        with self.assertRaisesRegex(coverage.InvalidCoverage, "does not acknowledge"):
            self.validate()

    def test_no_behavior_cannot_hide_rules(self):
        self.sections["5.3"]["review"] = "no_behavior"
        with self.assertRaisesRegex(coverage.InvalidCoverage, "has extracted obligations"):
            self.validate()

    def test_reference_target_must_exist(self):
        self.review["sections"]["5.3"]["blocks"]["B001"] = {
            "disposition": "reference", "rationale": "Delegation", "sections": ["999"]}
        with self.assertRaisesRegex(coverage.InvalidCoverage, "reference targets"):
            self.validate()

    def test_unknown_review_state_does_not_mean_in_progress(self):
        self.review["sections"]["5.3"]["state"] = "machine-generated"
        self.sections["5.3"]["review"] = "in_progress"
        with self.assertRaisesRegex(coverage.InvalidCoverage, "unknown audit state"):
            self.validate()

    def test_unresolved_interpretation_cannot_close_section(self):
        self.rules[0].update(clause="5.3", interpretation_issue="OPEN-QUESTION")
        with self.assertRaisesRegex(coverage.InvalidCoverage, "cannot close"):
            self.validate()

    def test_unresolved_interpretation_cannot_be_mapped(self):
        self.sections["5.3"]["review"] = "in_progress"
        self.review["sections"]["5.3"]["state"] = "in_progress"
        self.rules[0].update(clause="5.3", interpretation_issue="OPEN-QUESTION", checks=[{}])
        with self.assertRaisesRegex(coverage.InvalidCoverage, "approved test mappings"):
            self.validate()

    def test_in_progress_is_not_a_completed_audit(self):
        self.sections["5.3"]["review"] = "in_progress"
        self.review["sections"]["5.3"]["state"] = "in_progress"
        self.rules[0].update(clause="5.3", interpretation_issue="OPEN-QUESTION", checks=[])
        self.validate()
        stats = coverage.summarize(
            {"5.3": {"kind": "normative", "review": "in_progress"}},
            [{"mapped": False}], {"executed": []})
        self.assertEqual(stats["extraction_progress_percent"], 0)
        self.assertIsNone(stats["whole_standard_percent"])

    def test_source_can_be_fully_reviewed_with_interpretation_held(self):
        self.sections["5.3"].update(kind="normative", review="in_progress")
        self.review["sections"]["5.3"]["state"] = "in_progress"
        self.rules[0].update(clause="5.3", interpretation_issue="OPEN: conflict", checks=[])
        self.validate()
        stats = audit.progress(self.index, self.review, self.sections, self.rules)
        self.assertTrue(stats["source_review_complete"])
        self.assertEqual(stats["source_review_percent"], 100)
        self.assertEqual(stats["interpretation_issues"], 1)

    def test_informative_review_does_not_fill_missing_normative_source(self):
        self.sections["5.3"].update(kind="normative", review="unreviewed")
        self.sections["P"] = {"kind": "informative", "review": "no_behavior"}
        self.index["sections"]["P"] = {"sha256": "glossary", "blocks": []}
        self.review["sections"] = {"P": {
            "state": "complete", "source_sha256": "glossary", "reviewer": "AI",
            "reviewed_on": "2026-10-22", "scope_note": "Informative glossary",
            "visual_review": "No normative figures", "blocks": {}}}
        self.rules.clear()
        self.validate()
        stats = audit.progress(self.index, self.review, self.sections, self.rules)
        self.assertFalse(stats["source_review_complete"])
        self.assertEqual(stats["source_review_percent"], 50)
        self.assertEqual(stats["normative_source_review_percent"], 0)


class SourceBoundaryTests(unittest.TestCase):
    def fixture(self, folder, duplicate=False, shortened=False):
        pdf = folder / "standard.pdf"
        pdf.write_bytes(b"unit-test file identity")
        first = "22.14.8 Prior keywords"
        second = "22.14.9 IEEE Std 1800-2017 and IEEE Std 1800-2023 keywords"
        pages = ["IEEE Std 1800-2023\n\n" + first + "\n\n"
                 "A normative paragraph mentions IEEE Std 1800-2023 without being a running header.\n\n"
                 "A footnote remains part of the body.\n\n"
                 + (first + "\n" if duplicate else "") + "0\nCopyright example footer\n",
                 "IEEE Std 1800-2023\n\n" + ("22.14.9 IEEE" if shortened else second)
                 + "\n\nLater normative content.\n\n1\nCopyright example footer\n"]
        pages.extend([""] * 1352)
        out = folder / "out"
        out.mkdir()
        (out / "lrm_pdftotext_layout.txt").write_text("\f".join(pages) + "\f")
        return {"source": {"pdf": pdf.name, "pdf_sha256": hashlib.sha256(pdf.read_bytes()).hexdigest()},
                "sections": [{"id": "22.14.8", "title": "Prior keywords", "pdf_page": 1},
                             {"id": "22.14.9", "title": second.split(" ", 1)[1], "pdf_page": 2}]}

    def test_running_header_filter_does_not_delete_real_headings_or_body(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            result = source.source_sections(folder, self.fixture(folder))
            body = "\n".join(b["text"] for b in result["22.14.8"]["blocks"])
            self.assertIn("normative paragraph mentions IEEE Std 1800-2023", body)
            self.assertIn("A footnote remains", body)
            self.assertNotIn("Copyright", body)
            self.assertIn("Later normative content", str(result["22.14.9"]["blocks"]))

    def test_partial_heading_match_cannot_silently_close_a_section(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            with self.assertRaisesRegex(ValueError, "unresolved_headings"):
                source.source_sections(folder, self.fixture(folder, shortened=True))

    def test_ambiguous_heading_is_not_guessed(self):
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory)
            with self.assertRaisesRegex(ValueError, "unresolved_headings"):
                source.source_sections(folder, self.fixture(folder, duplicate=True))

    def test_full_text_cache_cannot_be_written_inside_repository(self):
        target = coverage.ROOT / "must-not-create-standard-cache.json"
        with (mock.patch.object(source, "source_sections", return_value={}),
              mock.patch.object(sys, "argv", ["source", "--cache", str(target)]),
              contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as error):
            source.main()
        self.assertEqual(error.exception.code, 2)
        self.assertFalse(target.exists())


if __name__ == "__main__":
    unittest.main()
