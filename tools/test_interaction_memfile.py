"""Independent integer/X/Z planes, token decoding and guarded memory addressing."""

from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_memfile as cases


def interpret(row):
    width, source_state, kind, value, encoding, span, declaration, target_state, order = row
    width, result = int(width), []
    mask = (1 << width) - 1
    source_addresses = {"all": [2, 3, 4, 5, 6], "middle": [3, 4, 5], "single": [4]}[span]
    destinations = [11 + i for i in range(len(source_addresses))]
    if order == "reverse":
        destinations.reverse()

    def word(code, phase):
        return sum(((code >> ((width - 1 - bit + phase) % 3)) & 1) << bit for bit in range(width))

    def show(data):
        v, x, z = data
        return "".join("x" if x & (1 << i) else "z" if z & (1 << i) else str((v >> i) & 1)
                       for i in range(width - 1, -1, -1))

    for unknown in ([False] if value == "known" else [False, True]):
        for phase in range(3):
            label = ("u" if unknown else "k") + str(phase)
            raw, source = {}, {}
            for address, code in zip(range(2, 7), range(1, 6)):
                v, x, z = word(code, phase), 0, 0
                if unknown:
                    groups = (width + 3) // 4
                    positions = {0, groups - 1, (groups // 2 + code + phase) % groups}
                    bad = sum(15 << (4 * i) for i in positions) & mask
                    v &= ~bad
                    if value == "x":
                        x = bad
                    else:
                        z = bad
                raw[address] = (v, x, z)
                source[address] = (v, 0, 0) if source_state == "bit" else (v, x, z)
            result.append(f"{label} count={len(source_addresses)} "
                          f"write={source_addresses[0]}:{source_addresses[-1]} "
                          f"read={destinations[0]}:{destinations[-1]}")
            result += [f"{label} before idx={i} raw={show(raw[i])} source={show(source[i])}"
                       for i in range(2, 7)]
            result += [f"{label} after idx={i} source={show((mask ^ source[i][0], 0, 0))}"
                       for i in range(2, 7)]
            memory = {i: (word(6 if i == 10 else 7 if i == 16 else 0, phase), 0, 0)
                      for i in range(10, 17)}
            for address, destination in zip(source_addresses, destinations):
                v, x, z = source[address]
                memory[destination] = (v, 0, 0) if target_state == "bit" else (v, x, z)
            result += [f"{label} dest idx={i} written={show(memory[i])} canonical={show(memory[i])}"
                       for i in range(10, 17)]
            result.append(f"{label} addresses written=0 canonical=0")
    return "\n".join(result) + "\n"


def decode(text, encoding, width):
    if encoding == "bin":
        bits = text
    else:
        bits = "".join(ch.lower() * 4 if ch.lower() in "xz" else f"{int(ch, 16):04b}" for ch in text)
    return bits.rjust(width, "0")[-width:]


class TypedMemoryFileOracle(unittest.TestCase):
    def test_all_2880_rows_match_independent_integer_unknown_planes_and_address_map(self):
        self.assertEqual(len(cases.MODEL.rows()), 2880)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), interpret(row), row)

    def test_selection_keeps_all_targets_and_represents_single_element_reverse_once(self):
        selected = cases.MODEL.select()
        self.assertEqual(len(selected), 36)
        targets = {t for row in selected for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 248)
        self.assertEqual(sum(len(t) == 3 for t in targets), 82)
        self.assertTrue(set(cases.MODEL.anchors) <= set(selected))
        self.assertFalse(any(row[5] == "single" and row[8] == "reverse" for row in cases.MODEL.rows()))

    def test_canonical_hex_and_binary_tokens_preserve_every_stored_word(self):
        for row in cases.MODEL.rows():
            for label, phase, words in cases.phases(row):
                for raw in words:
                    stored = cases.stored(row[1], raw)
                    self.assertEqual(decode(cases.token(row, stored), row[4], int(row[0])), stored, row)

    def test_three_known_phases_identify_each_location_even_at_one_bit(self):
        row = cases.MODEL.anchors[0]
        frames = cases.phases(row)
        signatures = [tuple(words[i] for _, _, words in frames) for i in range(5)]
        self.assertEqual(len(set(signatures)), 5)
        self.assertNotIn(("0", "0", "0"), signatures)
        for i, signature in enumerate(signatures):
            if i != 2:
                self.assertNotEqual(signature, signatures[4-i])

    def test_reverse_reading_changes_addresses_but_declaration_direction_does_not(self):
        row = ("1", "logic", "plain", "known", "bin", "all", "up", "logic", "forward")
        down = (*row[:6], "down", *row[7:])
        reverse = (*row[:-1], "reverse")
        self.assertEqual(cases.reference(row), cases.reference(down))
        self.assertNotEqual(cases.reference(row), cases.reference(reverse))
        for direction in (row, reverse):
            text = cases.reference(direction)
            self.assertIn("k1 dest idx=10 written=1 canonical=1", text)
            self.assertIn("k2 dest idx=16 written=1 canonical=1", text)

    def test_source_conversion_precedes_file_and_target_conversion_occurs_on_loading(self):
        row = cases.MODEL.anchors[1]
        label, phase, raw = cases.phases(row)[3]
        stored = cases.stored("logic", raw[1])
        self.assertIn("z", stored)
        text = cases.reference(row)
        self.assertIn(f"{label} before idx=3 raw={raw[1]} source={stored}", text)
        loaded = stored.replace("z", "0")
        self.assertIn(f"{label} dest idx=13 written={loaded} canonical={loaded}", text)
        two_state = (row[0], "bit", *row[2:])
        self.assertIn(f"{label} before idx=3 raw={raw[1]} source={loaded}", cases.reference(two_state))

    def test_independent_input_exposes_compensating_write_and_read_reversal(self):
        frames = cases.phases(cases.MODEL.anchors[0])
        original = [words for _, _, words in frames]
        roundtrip = [words[::-1][::-1] for words in original]
        independent_input = [words[::-1] for words in original]
        self.assertEqual(original, roundtrip)
        self.assertNotEqual(original, independent_input)

    def test_rendered_sources_keep_enum_casts_independent_tokens_guards_and_comment_scan(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertIn("source[i] = source_t'(raw[i]);", case.body)
            self.assertIn('"written.mem", loaded', case.body)
            self.assertIn('"canonical.mem", canonical', case.body)
            self.assertIn("// @ inside a line comment", case.body)
            self.assertIn("/* @ inside a block comment */", case.body)
            self.assertNotIn("$fdisplay(fd, source", case.body)
            self.assertIn("for (int i = 10; i <= 16; i++)", case.body)
            self.assertIn("function automatic int addresses", case.body)


if __name__ == "__main__":
    unittest.main()
