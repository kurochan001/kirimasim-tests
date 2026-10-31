"""Independent Active/NBA/Reactive/Re-NBA queues and integer four-state planes."""

from collections import deque
from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "generators"))
import interaction_reactive as cases


def input_vectors(width, marker):
    mask, result = (1 << width)-1, []
    for phase in range(8):
        value = sum((((bit+1) // (2**phase)) % 2) << bit for bit in range(width))
        result += [(value, 0, 0), (value ^ mask, 0, 0)]
    if marker != "known":
        for phase in range(3):
            value = result[2*phase][0]
            bad = sum(1 << bit for bit in {0, width-1, (phase+1) % width})
            result += [(mask, 0, 0), (value & ~bad, bad if marker == "x" else 0,
                                    bad if marker == "z" else 0)]
    return result


def simulate(row, reverse_active=False):
    width, source_state, marker, depth, update, producer, operation = row
    width, depth = int(width), int(depth)
    mask = (1 << width)-1

    def show(word):
        v, x, z = word
        return "".join("x" if x >> i & 1 else "z" if z >> i & 1 else str(v >> i & 1)
                       for i in range(width-1, -1, -1))

    def xor(word, constant):
        v, x, z = word
        bad = x | z
        return ((v ^ constant) & mask & ~bad, bad, 0)

    def target(word):
        return xor(word, mask) if operation == "invert" else word

    source = (0, 0, 0)
    stages, prior = [], source
    for stage in range(depth):
        prior = xor(prior, stage+1)
        stages.append(prior)
    tap = output = target(source)
    ctx = {"captured": output, "sampled": source, "last": stages[-1], "steps": 0, "visits": 0}
    early = late = steps = 0
    lines = []
    for epoch, raw in enumerate(input_vectors(width, marker)):
        time = 10*(epoch+1)
        queues = {key: deque() for key in ("active", "nba", "reactive", "renba")}
        queues["nba" if update == "nba" else "active"].append(("source", raw))
        while any(queues.values()):
            region = next(key for key, q in queues.items() if q)
            q = queues[region]
            event, data = q.pop() if region == "active" and reverse_active else q.popleft()
            if event == "source":
                stored = (data[0], 0, 0) if source_state == "bit" else data
                if stored != source:
                    source = stored
                    queues["active"].extend((("eval_stage", 0), ("tap", None)))
                    queues["reactive"].append(("program", None))
            elif event == "eval_stage":
                previous = source if data == 0 else stages[data-1]
                queues["nba"].append(("stage_update", (data, xor(previous, data+1))))
                steps += 1
            elif event == "stage_update":
                index, word = data
                if stages[index] != word:
                    stages[index] = word
                    if index+1 < depth:
                        queues["active"].append(("eval_stage", index+1))
            elif event == "tap":
                word = target(source)
                if tap != word:
                    tap = word
                    queues["active"].append(("early", None))
            elif event == "early":
                early += 1
                lines.append(f"early t={time} value={show(tap)} last={show(stages[-1])}")
            elif event == "program":
                word = target(source)
                ctx.update(captured=output if producer == "nba" else word,
                           sampled=source, last=stages[-1], steps=steps, visits=ctx["visits"]+1)
                queues["renba" if producer == "nba" else "reactive"].append(("output", word))
            elif event == "output":
                if output != data:
                    output = data
                    queues["active"].append(("late", None))
            elif event == "late":
                late += 1
                lines.append(f"late t={time} value={show(output)} last={show(stages[-1])} steps={steps}")
        lines += [f"p{epoch} t={time+1} raw={show(raw)} source={show(source)} out={show(output)} "
                  f"early={early} late={late} steps={steps}",
                  f"p{epoch} stages " + " ".join(f"s{i}={show(word)}" for i, word in enumerate(stages)),
                  f"p{epoch} program captured={show(ctx['captured'])} sampled={show(ctx['sampled'])} "
                  f"last={show(ctx['last'])} steps={ctx['steps']} visits={ctx['visits']}"]
    return "\n".join(lines) + "\n"


class ProgramReactiveHandoff(unittest.TestCase):
    def test_all_1296_rows_match_independent_region_queues_and_integer_planes(self):
        self.assertEqual(len(cases.MODEL.rows()), 1296)
        for row in cases.MODEL.rows():
            self.assertEqual(cases.reference(row), simulate(row), row)

    def test_selection_preserves_every_target_and_six_mandatory_controls(self):
        chosen = cases.MODEL.select()
        self.assertEqual(len(chosen), 36)
        targets = {t for row in chosen for t in cases.MODEL.targets(row)}
        self.assertEqual(targets, cases.MODEL.universe())
        self.assertEqual(sum(len(t) == 2 for t in targets), 183)
        self.assertEqual(sum(len(t) == 3 for t in targets), 84)
        self.assertTrue(set(cases.MODEL.anchors) <= set(chosen))

    def test_active_event_order_does_not_change_any_selected_trace(self):
        for row in cases.MODEL.select():
            self.assertEqual(simulate(row), simulate(row, reverse_active=True), row)

    def test_program_nba_captures_old_value_while_blocking_captures_new(self):
        row = cases.MODEL.anchors[0]
        blocking = (*row[:5], "blocking", row[6])
        nba = (*row[:5], "nba", row[6])
        self.assertIn("p0 program captured=1 sampled=1", simulate(blocking))
        self.assertIn("p0 program captured=0 sampled=1", simulate(nba))

    def test_early_and_late_events_see_previous_and_settled_final_stage(self):
        row = cases.MODEL.anchors[0]
        text = simulate(row)
        self.assertIn("early t=10 value=1 last=1", text)
        self.assertIn("late t=10 value=1 last=0 steps=1", text)
        self.assertLess(text.index("early t=10"), text.index("late t=10"))

    def test_unknown_frames_always_follow_ones_and_change_converted_source(self):
        for row in cases.MODEL.rows():
            if row[2] == "known":
                continue
            width = int(row[0])
            frames = input_vectors(width, row[2])
            for index in (17, 19, 21):
                self.assertEqual(frames[index-1], ((1 << width)-1, 0, 0))
                self.assertNotEqual(frames[index][0], frames[index-1][0])

    def test_known_histories_distinguish_every_position_through_129_bits(self):
        frames = input_vectors(129, "known")
        histories = {tuple((v >> bit) & 1 for v, _, _ in frames) for bit in range(129)}
        self.assertEqual(len(histories), 129)
        for i in range(0, 16, 2):
            self.assertEqual(frames[i][0] ^ frames[i+1][0], (1 << 129)-1)

    def test_cases_export_program_state_by_ports_and_classify_fourstate(self):
        import common
        for row in cases.MODEL.select():
            case = cases.make_case(row)
            common.render(case, cases.NAME, cases.VERSION, cases.CHAPTER, "spec")
            self.assertEqual(case.fourstate, row[2] != "known")
            self.assertNotIn("p.captured", case.body)
            self.assertNotIn("p.sampled", case.body)


if __name__ == "__main__":
    unittest.main()
