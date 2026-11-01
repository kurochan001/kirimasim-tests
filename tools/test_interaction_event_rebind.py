"""Independent event-object heap, task frames and a two-region discrete timeline."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_event_rebind as cases


def interpret(row, fault=None):
    """Bind immutable synchronization objects, then register task-frame event controls."""
    home, passing, timing, trigger, aliases, order, count = row
    objects = {key: object() for key in ('original', 'replacement', 'noise')}
    names = dict(objects)
    names['bridge'] = names['original']
    names['selected'] = names['bridge' if aliases == 'chain' else 'original']
    names['copied'] = names['selected']
    names['second'] = names['replacement']
    if fault == 'copy_uses_new':
        names['copied'] = names['replacement']
    if fault == 'sources_merged':
        names['second'] = names['original']
    registers = [[0, -1, 0] for _ in range(6)]
    entries, pending = [], []
    changes = {'before_call': 1, 'before_arm': 3, 'after_arm': 5}
    pulse_order = ('copied', 'second') if order == 'old_new' else ('second', 'copied')
    pulses = dict(zip((9, 11, 13, 15, 17), ('noise', *pulse_order, *pulse_order)))
    snapshots = {0: 'initial', 6: 'rebound', 8: 'bridge_changed', 10: 'noise',
                 12: 'first', 14: 'pair', 18: 'repeated', 21: 'cleared'}
    result = []
    for tick in range(22):
        if tick == changes[timing] and fault != 'lose_rebind':
            names['selected'] = names['replacement']
        if tick == 7:
            names['bridge'] = names['noise']
            if fault == 'bridge_is_variable_link' and aliases == 'chain':
                names['selected'] = names['bridge']
        if tick == 20 and fault != 'lose_null_clear':
            names['selected'] = None
            if fault == 'null_clears_copy':
                names['copied'] = None
        if tick in snapshots:
            label = snapshots[tick]
            result.append(f'{label} time={tick} old={int(names["selected"] is objects["original"])} '
                          f'new={int(names["selected"] is objects["replacement"])} '
                          f'null={int(names["selected"] is None)} '
                          f'copy_old={int(names["copied"] is objects["original"])} '
                          f'bridge_noise={int(names["bridge"] is objects["noise"])} '
                          f'second_new={int(names["second"] is objects["replacement"])}')
            for slot, (hits, at, value) in enumerate(registers):
                result.append(f'{label} slot={slot} hits={hits} at={at} value={value}')
        if tick in (2, 6):
            slots = ([(3, 'selected')] if tick == 6 else
                     [(slot, 'selected') for slot in range(int(count))] + [(4, 'copied'), (5, 'noise')])
            for slot, variable in slots:
                copy = passing == 'input'
                if fault == 'input_becomes_ref': copy = False
                if fault == 'ref_becomes_input': copy = True
                frame = {'slot': slot, 'variable': variable,
                         'copied': names[variable], 'copy': copy}
                entries.append((tick + 2, frame))
        for arm, frame in entries:
            if arm == tick:
                target = frame['copied'] if frame['copy'] else names[frame['variable']]
                if fault == 'all_wait_on_old': target = objects['original']
                pending.append({**frame, 'target': target})
        if tick in pulses:
            object_fired = names[pulses[tick]]
            # The producer writes stamp, schedules stamp+1, then triggers the event.
            stamp = 10 * tick
            if (trigger == 'nba') != (fault == 'swap_trigger_region'):
                stamp += 1
            remaining = []
            for waiter in pending:
                target = (names[waiter['variable']] if fault == 'retarget_armed'
                          else waiter['target'])
                if object_fired is not None and target is object_fired:
                    slot = waiter['slot']
                    if fault != 'drop_fanout' or slot not in (1, 2):
                        registers[slot] = [registers[slot][0]+1, tick, stamp]
                    if fault == 'listener_repeats': remaining.append(waiter)
                else:
                    remaining.append(waiter)
            pending = remaining
    return '\n'.join(result) + '\n'


class EventRebinding(unittest.TestCase):
    def test_all_648_legal_rows_match_independent_object_frames(self):
        self.assertEqual(len(cases.MODEL.rows()), 648)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_all_pairs_focused_triples_and_anchors_survive_selection(self):
        selected = cases.MODEL.select()
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertLess(len(selected), len(cases.MODEL.rows())//10)
        self.assertTrue(all(len(t) in (2, 3) for t in targets))

    def test_input_and_ref_differ_only_when_binding_changes_between_entry_and_arm(self):
        for timing in ('before_call', 'before_arm', 'after_arm'):
            prefix = ('module', 'direct', timing, 'blocking', 'single', 'old_new', '3')
            variants = {mode: interpret((prefix[0], mode, *prefix[2:]))
                        for mode in ('direct', 'input', 'ref')}
            self.assertEqual(variants['direct'], variants['ref'])
            self.assertEqual(variants['input'] == variants['ref'], timing != 'before_arm')
            line = next(line for line in variants['input'].splitlines() if line.startswith('pair slot=0'))
            self.assertIn('at=13' if timing == 'before_call' else 'at=11', line)

    def test_late_copy_noise_and_unused_slots_are_independently_observed(self):
        row = ('package', 'ref', 'after_arm', 'nba', 'chain', 'new_old', '1')
        lines = interpret(row).splitlines()
        for exact in ('pair slot=0 hits=1 at=13 value=131',
                      'pair slot=1 hits=0 at=-1 value=0',
                      'pair slot=2 hits=0 at=-1 value=0',
                      'pair slot=3 hits=1 at=11 value=111',
                      'pair slot=4 hits=1 at=13 value=131',
                      'pair slot=5 hits=1 at=9 value=91'):
            self.assertIn(exact, lines)

    def test_registration_binding_and_observation_are_separated_in_emitted_sources(self):
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            source, expected = common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, 'spec')
            self.assertEqual(expected, interpret(row))
            self.assertNotIn('wait (', case.body)
            self.assertNotIn('.triggered', case.body)
            self.assertNotIn('@(null)', case.body)
            self.assertEqual(case.body.count(' = null;'), 1)
            if row[1] == 'direct':
                self.assertNotIn('task automatic observe(', source)
            else:
                self.assertIn(f'task automatic observe({row[1]} event ev', source)
                self.assertIn('    #2;\n    @(ev);', source)
            self.assertIn('second_new=%0d', source)

    def test_thirteen_abstract_semantic_faults_have_selected_trace_witnesses(self):
        # These are stimulus/observation sensitivity checks of the independent model,
        # not executable SV mutation qualification on an unsupported simulator.
        faults = ('copy_uses_new', 'sources_merged', 'lose_rebind', 'bridge_is_variable_link',
                  'lose_null_clear', 'null_clears_copy', 'input_becomes_ref', 'ref_becomes_input',
                  'all_wait_on_old', 'swap_trigger_region', 'retarget_armed', 'drop_fanout',
                  'listener_repeats')
        for fault in faults:
            with self.subTest(fault=fault):
                self.assertTrue(any(interpret(row, fault) != cases.reference(row)
                                    for row in cases.MODEL.select()))


if __name__ == '__main__':
    unittest.main()
