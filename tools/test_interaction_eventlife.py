"""Automatic-frame identity, event registration and aggregate copy observations."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent/'generators'))
import interaction_eventlife as generator
import qualify_eventlife as qualification


class AggregateEventLifetime(unittest.TestCase):
    def test_all_rows_match_independent_emitted_source_interpretation(self):
        for row in generator.MODEL.rows():
            with self.subTest(row=row):
                self.assertEqual(generator.reference(row), qualification.independent(row))

    def test_primary_release_does_not_change_armed_object_or_automatic_payload(self):
        row = generator.MODEL.anchors[2]
        expected = generator.reference(row)
        self.assertIn('armed tag=0 pnull=1 bnull=0 same=0', expected)
        self.assertIn('third tag=0 slot=1 hits=1 at=10 value=100 stamp=100', expected)
        self.assertIn('first tag=2 slot=0 hits=1 at=6 value=102 stamp=60', expected)

    def test_nba_wakeup_reads_queued_static_payload_and_retained_copy(self):
        expected = generator.reference(generator.MODEL.anchors[3])
        self.assertIn('first tag=0 slot=0 hits=1 at=6 value=100 stamp=61', expected)
        self.assertIn('first tag=1 slot=0 hits=0 at=-1 value=0 stamp=0', expected)

    def test_inactive_calls_and_listener_slots_remain_untouched(self):
        expected = generator.reference(generator.MODEL.anchors[0])
        self.assertIn('final tag=1 pnull=1 bnull=1 same=1', expected)
        self.assertIn('final tag=0 slot=1 hits=0 at=-1 value=0 stamp=0', expected)

    def test_fresh_call_survives_old_alias_release_without_restarting_old_children(self):
        expected = generator.reference(generator.MODEL.anchors[1])
        self.assertIn('released tag=0 pnull=1 bnull=1 same=1', expected)
        self.assertIn('fresh_woke tag=3 slot=1 hits=1 at=24 value=103 stamp=241', expected)
        self.assertIn('final tag=2 slot=1 hits=1 at=6 value=102 stamp=61', expected)

    def test_source_faults_are_detected_by_interpreter_without_runtime_claim(self):
        faults = qualification.source_faults()
        self.assertEqual(len(faults), 8)
        self.assertEqual({r['source_check'] for r in faults.values()},
                         {'output differs', 'stranded registration'})


if __name__ == '__main__':
    unittest.main()
