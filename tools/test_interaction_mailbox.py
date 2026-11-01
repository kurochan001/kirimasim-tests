"""Independent object graph and mailbox queue interpreter with integer bit planes."""

from dataclasses import dataclass
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / 'generators'))
import common
import interaction_mailbox as model


def input_frames(row):
    width = int(row[0])
    limit = (1 << width) - 1
    for phase in range(12):
        values = []
        for bank in range(4):
            value = (sum(1 << i for i in range(width)
                         if (bank * width + i + 1) // (1 << phase) % 2)
                     if phase < 10 else limit * (phase - 10))
            values.append((value, 0, 0))
        yield f'k{phase}', values
    if row[2] != 'known':
        for phase, position in enumerate((0, width - 1, width // 2)):
            values = []
            unknown = 1 << position
            for bank in range(4):
                value = sum(1 << i for i in range(width)
                            if (bank * width + i + 1) // (1 << phase) % 2) & ~unknown
                values.append((value, unknown if row[2] == 'x' else 0,
                               unknown if row[2] == 'z' else 0))
            yield f'u{phase}', values


def convert(word, two_state):
    value, x, z = word
    return value, 0 if two_state else x, 0 if two_state else z


def complement(word, width):
    value, x, z = word
    unknown = x | z
    return ((1 << width) - 1) ^ (value | unknown), unknown, 0


def display(word, width):
    value, x, z = word
    return ''.join('x' if (x >> i) & 1 else 'z' if (z >> i) & 1
                   else str((value >> i) & 1) for i in range(width - 1, -1, -1))


@dataclass
class Packet:
    tag: int
    word: tuple[int, int, int]


class Mailbox:
    def __init__(self, bound=0):
        self.bound = bound
        self.queue = []

    def put(self, handle):
        if self.bound and len(self.queue) == self.bound:
            return 0
        self.queue.append(handle)
        return 1

    def receive(self, keep=False):
        if not self.queue:
            return 0, None
        return 1, self.queue[0] if keep else self.queue.pop(0)


def interpret(row):
    width = int(row[0])
    two_state = row[1] == 'bit'
    lines = []
    show = lambda packet: display(packet.word, width)
    for label, raw in input_frames(row):
        a, b, c, g = [Packet(tag, convert(word, two_state))
                      for tag, word in zip((11, 22, 33, 99), raw)]
        updates = [convert(complement(word, width), two_state) for word in raw]
        box = Mailbox(2 if row[6] == 'bounded' else 0)
        guard = Mailbox()
        box.put(a)
        box.put(b)
        guard.put(g)
        admitted = box.put(c if row[7] == 'object' else None)
        lines.append(f'{label} put ok={admitted} num={len(box.queue)} guard={len(guard.queue)}')
        if row[5] != 'after':
            a.word = updates[0]
        lines.append(f'{label} source a={show(a)} b={show(b)} c={show(c)} guard={show(g)}')
        success, received = box.receive(keep=row[4] in ('peek', 'try_peek'))
        lines.append(f'{label} fetch ok={success} same={int(received is a)} tag={received.tag} '
                     f'value={show(received)} num={len(box.queue)}')
        received.word = updates[1]
        lines.append(f'{label} through source={show(a)} received={show(received)} '
                     f'other={show(b)} guard={show(g)}')
        if row[5] != 'before':
            a.word = updates[2]
        lines.append(f'{label} after source={show(a)} received={show(received)} num={len(box.queue)}')
        index = 0
        while box.queue:
            success, item = box.receive()
            if item is None:
                lines.append(f'{label} drain{index} null=1 tag=0 value=-')
            else:
                lines.append(f'{label} drain{index} null=0 tag={item.tag} value={show(item)}')
            index += 1
        empty_get = box.receive()[0]
        empty_peek = box.receive(keep=True)[0]
        lines.append(f'{label} empty get={empty_get} peek={empty_peek} num={len(box.queue)}')
        success, held_guard = guard.receive()
        lines.append(f'{label} guard ok={success} same={int(held_guard is g)} '
                     f'tag={held_guard.tag} value={show(held_guard)} num={len(guard.queue)}')
        held_guard.word = updates[3]
        lines.append(f'{label} guard_update source={show(g)} received={show(held_guard)} other={show(b)}')
    return '\n'.join(lines) + '\n'


class MailboxClassAlias(unittest.TestCase):
    def test_all_3456_legal_rows_match_independent_object_graph(self):
        self.assertEqual(len(model.MODEL.rows()), 3456)
        for row in model.MODEL.rows():
            self.assertEqual(model.reference(row), interpret(row), row)

    def test_minimum_36_rows_cover_all_pairs_focused_triples_and_nine_anchors(self):
        selected = model.MODEL.select()
        targets = {t for row in selected for t in model.MODEL.targets(row)}
        self.assertEqual(len(selected), 36)
        self.assertEqual(targets, model.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 245)
        self.assertEqual(sum(len(t) == 3 for t in targets), 92)
        self.assertTrue(set(model.MODEL.anchors) <= set(selected))
        # width x storage x value alone needs 6 x 2 x 3 distinct complete rows.
        self.assertEqual(len({(r[0], r[1], r[2]) for r in selected}), 36)
        self.assertEqual(len(model.MODEL.anchors), 9)

    def test_516_input_positions_and_their_complements_have_unique_histories(self):
        row = ('129', 'logic', 'known', 'typed', 'peek', 'both', 'unbounded', 'null')
        frames = [words for _, words in model.stimuli(row)]
        histories = [tuple(words[bank][bit] for words in frames)
                     for bank in range(4) for bit in range(129)]
        inverted = [tuple('1' if value == '0' else '0' for value in history)
                    for history in histories]
        self.assertEqual(len(set(histories)), 516)
        self.assertEqual(len(set(histories + inverted)), 1032)
        independent = [(label, [display(word, 129) for word in words])
                       for label, words in input_frames(row)]
        self.assertEqual(list(model.stimuli(row)), independent)

    def test_mailboxes_copy_handles_and_peek_preserves_a_null_message(self):
        box = Mailbox(2)
        packet = Packet(11, (1, 0, 0))
        self.assertEqual(box.put(packet), 1)
        self.assertEqual(box.put(None), 1)
        self.assertEqual(box.put(packet), 0)
        packet.word = (7, 0, 0)
        success, copy = box.receive(keep=True)
        self.assertIs(copy, packet)
        copy.word = (9, 0, 0)
        self.assertEqual(packet.word, (9, 0, 0))
        self.assertIs(box.receive()[1], packet)
        self.assertEqual(box.receive(keep=True), (1, None))
        self.assertEqual(len(box.queue), 1)
        self.assertEqual(box.receive(), (1, None))
        self.assertEqual(box.receive(), (0, None))

    def test_bit_storage_converts_unknowns_without_hiding_known_alias_updates(self):
        row = ('65', 'logic', 'z', 'typed', 'try_get', 'both', 'unbounded', 'object')
        four = interpret(row)
        two = interpret((row[0], 'bit', *row[2:]))
        self.assertIn('z', four)
        self.assertIn('x', four)
        self.assertNotIn('z', two)
        self.assertNotIn('x', two)
        self.assertEqual(four.split('u0 ')[0], two.split('u0 ')[0])

    def test_typing_does_not_remove_legal_cases_or_change_expected_messages(self):
        for row in model.MODEL.anchors:
            other = (*row[:3], 'typeless' if row[3] == 'typed' else 'typed', *row[4:])
            self.assertIn(other, model.MODEL.rows())
            self.assertEqual(model.reference(row), model.reference(other))

    def test_generated_program_uses_safe_reads_and_normalized_success_returns(self):
        for row in model.MODEL.select():
            case = model.make_case(row)
            source, expected = common.render(case, model.NAME, model.VERSION, 15, 'spec')
            self.assertEqual(expected, interpret(row))
            self.assertIn('result > 0', source)
            self.assertIn('while (target_box.try_get(tail_item) > 0)', source)
            self.assertNotIn('empty_item.payload', source)
            self.assertNotIn('empty_item == b', source)
            self.assertEqual(case.fourstate, row[2] != 'known')


if __name__ == '__main__':
    unittest.main()
