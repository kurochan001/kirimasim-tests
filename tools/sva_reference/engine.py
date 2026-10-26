"""Single-clock SVA evaluation from sampled inputs, chapter 16 and Annex F.

Sequence matches are a multiset. Property evaluation distinguishes a decided
result from finite-trace satisfaction (F.5.3.2): an unresolved weak property
may hold on the finite word without having a pass action at any clock tick.
"""

from dataclasses import dataclass
from functools import cache

from . import automata as rx
from .parser import Node, Spec, Unsupported, parse_spec, resolve_bounds
from .values import evaluate


@dataclass(frozen=True)
class Match:
    start: int
    end: int  # empty interval: end == start - 1


@dataclass(frozen=True)
class Result:
    value: bool | None  # None: no clock tick has decided the attempt
    at: int | None
    neutral: bool      # truth on the finite word, F.5.3.1
    vacuous: bool = False

    @property
    def level(self):
        if self.value is not None:
            return "holds_strongly" if self.value else "fails"
        return "holds" if self.neutral else "pending"


@dataclass(frozen=True)
class Attempt:
    start: int
    status: str  # success/failure/vacuous/disabled/holds/pending
    tick: int | None
    time: int | None
    satisfaction: str
    finite_truth: bool | None


@dataclass(frozen=True)
class Current:
    time: int
    values: dict
    phase: str = "observed"  # "change" for other current-value updates


def combine(operator, results):
    results = tuple(results)
    conjunction = operator == "and"
    neutral = all(r.neutral for r in results) if conjunction else any(r.neutral for r in results)
    decisive = [r for r in results if r.value is (False if conjunction else True)]
    if decisive:
        chosen = min(decisive, key=lambda r: r.at)
        return Result(not conjunction, chosen.at, neutral,
                      all(r.vacuous for r in decisive))
    if all(r.value is not None for r in results):
        return Result(conjunction, max(r.at for r in results), neutral,
                      all(r.vacuous for r in results))
    return Result(None, None, neutral)


def negate(result):
    return Result(None if result.value is None else not result.value,
                  result.at, not result.neutral, result.vacuous)


class Engine:
    def __init__(self, samples, *, times=None, current=None, end_time=None):
        if not samples:
            raise Unsupported("at least one sampled tick is required")
        self.samples = tuple(dict(row) for row in samples)
        self.times = tuple(range(len(samples))) if times is None else tuple(times)
        if len(self.samples) != len(self.times) or any(a >= b for a, b in zip(self.times, self.times[1:])):
            raise Unsupported("sample timestamps must be strictly increasing")
        self.end_time = self.times[-1] if end_time is None else end_time
        if self.end_time < self.times[-1]:
            raise Unsupported("end time precedes the final sample")
        self.current = None if current is None else tuple(Current(event.time, dict(event.values), event.phase) for event in current)
        if self.current is not None:
            if any(a.time > b.time for a, b in zip(self.current, self.current[1:])):
                raise Unsupported("current-value events must be in timestamp/region order")
            if any(event.phase not in {"observed", "change"} or event.time > self.end_time for event in self.current):
                raise Unsupported("invalid current-value event phase or timestamp")
        # Per-engine caches do not retain every input trace through global
        # method-cache keys when the CLI later evaluates many source files.
        self._compile = cache(self._compile)
        self._derive = cache(self._derive)
        self._property = cache(self._property)

    def _compile(self, node):
        return rx.compile_sequence(resolve_bounds(node))

    def _derive(self, state, tick):
        return rx.derivative(state, lambda atom: evaluate(atom, self.samples[tick]).assertion())

    def matches(self, expression, start=0):
        node = parse_spec(expression).body if isinstance(expression, str) else expression
        if not 0 <= start < len(self.samples):
            raise Unsupported("sequence start is outside the trace")
        state = self._compile(node)
        result = [Match(start, start - 1)] * rx.nullable(state)
        for tick in range(start, len(self.samples)):
            state = self._derive(state, tick)
            result.extend([Match(start, tick)] * rx.nullable(state))
            if state == rx.ZERO:
                break
        return tuple(result)

    def _sequence_property(self, node, start, strength):
        state = self._compile(node)
        if rx.nullable(state):
            raise Unsupported("a sequence used as a property cannot admit empty matches (16.12.22)")
        if not rx.viable(state):
            raise Unsupported("degenerate sequence property (16.12.22)")
        for tick in range(start, len(self.samples)):
            state = self._derive(state, tick)
            if rx.nullable(state):
                return Result(True, tick, True)
            if not rx.viable(state):
                return Result(False, tick, False)
        return Result(None, None, strength == "weak")

    def _implication(self, antecedent, consequent, start, strength, nonoverlap=False):
        state = self._compile(antecedent)
        if nonoverlap:
            # F.3.4.3.3 also aligns an empty antecedent to the current tick.
            state = rx.concat(state, rx.ANY)
        elif not rx.viable(state, require_nonempty=True):
            raise Unsupported("overlapped implication requires a nondegenerate antecedent")
        children = []
        closed = None
        for tick in range(start, len(self.samples)):
            state = self._derive(state, tick)
            if rx.nullable(state):
                # Multiplicity affects sequence coverage, but repeating an
                # identical consequent does not affect universal truth.
                children.append(self._property(consequent, tick, strength))
            if not rx.viable(state, require_nonempty=True):
                closed = tick
                break
        failed = [child for child in children if child.value is False]
        if failed:
            first = min(failed, key=lambda child: child.at)
            return Result(False, first.at, False)
        neutral = all(child.neutral for child in children)
        if closed is not None and all(child.value is True for child in children):
            return Result(True, max([closed, *(child.at for child in children)]), True, not children)
        return Result(None, None, neutral)

    def _property(self, node, start, strength):
        op, args = node.op, node.args
        if op == "vacuous":
            return Result(True, start, True, True)
        if op == "not":
            return negate(self._property(args[0], start, strength))
        if op in {"strong", "weak"}:
            return self._sequence_property(args[0], start, op)
        if op in {"and", "or"}:
            return combine(op, (self._property(arg, start, strength) for arg in args))
        if op == "implies":
            return combine("or", (negate(self._property(args[0], start, strength)),
                                  self._property(args[1], start, strength)))
        if op == "iff":
            a, b = (self._property(arg, start, strength) for arg in args)
            return combine("and", (combine("or", (negate(a), b)), combine("or", (negate(b), a))))
        if op in {"|->", "|=>", "#-#", "#=#"}:
            consequent = args[1] if op in {"|->", "|=>"} else Node("not", (args[1],))
            result = self._implication(args[0], consequent, start, strength, op in {"|=>", "#=#"})
            return negate(result) if op in {"#-#", "#=#"} else result
        if op in {"nexttime", "s_nexttime"}:
            target = start + node.value
            return (self._property(args[0], target, strength) if target < len(self.samples)
                    else Result(None, None, op == "nexttime"))
        if op in {"always", "s_always", "eventually", "s_eventually"}:
            lo, hi = node.value
            is_always = op in {"always", "s_always"}
            strong = op.startswith("s_")
            children = [self._property(args[0], tick, strength)
                        for tick in range(start + lo, min(len(self.samples), start + hi + 1)
                                          if hi is not None else len(self.samples))]
            if hi is None or start + hi >= len(self.samples):
                children.append(Result(None, None, not strong))
            if not children:
                return Result(None, None, not strong)
            return combine("and" if is_always else "or", children)
        if op in {"until", "s_until", "until_with", "s_until_with"}:
            # F.3.4.3.8; use a backward fold rather than Python recursion per
            # clock tick. Temporal property operands are evaluated from each tick.
            right = Node("and", args) if op.endswith("_with") else args[1]
            weak = Result(None, None, True)
            for tick in range(len(self.samples) - 1, start - 1, -1):
                weak = combine("or", (self._property(right, tick, strength),
                                       combine("and", (self._property(args[0], tick, strength), weak))))
            if op.startswith("s_"):
                existence = self._property(Node("s_eventually", (right,), (0, None)), start, strength)
                return combine("and", (weak, existence))
            return weak
        if op == "if":
            if start >= len(self.samples):
                raise Unsupported("if property requires an existing start tick")
            branch = args[1] if evaluate(args[0], self.samples[start]).assertion() else args[2]
            return self._property(branch, start, strength)
        if op == "case":
            for item in args[1:-1]:
                for choice in item.args[:-1]:
                    # Case equality sizes operands together (12.5).
                    comparison = Node("binary", (args[0], choice), "===")
                    if evaluate(comparison, self.samples[start]).assertion():
                        return self._property(item.args[-1], start, strength)
            return self._property(args[-1], start, strength)
        return self._sequence_property(node, start, strength)

    def property(self, expression, start=0, *, kind="assert property"):
        if kind not in {"assert property", "assume property", "cover property"}:
            raise Unsupported(f"unsupported property directive kind: {kind}")
        if not 0 <= start < len(self.samples):
            raise Unsupported("property start is outside the trace")
        spec = parse_spec(expression) if isinstance(expression, str) else expression
        if isinstance(spec, Node):
            spec = Spec(spec)
        result = self._property(resolve_bounds(spec.body), start, "strong" if kind == "cover property" else "weak")
        decision_time = self.times[result.at] if result.at is not None else self.end_time
        if spec.disable is not None:
            for event in self._current_between(start, result.at):
                if evaluate(spec.disable, event.values).assertion():
                    tick = self.times.index(event.time) if event.time in self.times else None
                    return Attempt(start, "disabled", tick, event.time, "disabled", None)
        if result.value is None:
            return Attempt(start, result.level, None, None, result.level, result.neutral)
        status = "vacuous" if result.value and result.vacuous else "success" if result.value else "failure"
        return Attempt(start, status, result.at, decision_time, result.level, result.neutral)

    def attempts(self, expression, *, kind="assert property"):
        return tuple(self.property(expression, start, kind=kind) for start in range(len(self.samples)))

    def sequence_coverage(self, expression):
        spec = parse_spec(expression) if isinstance(expression, str) else expression
        if isinstance(spec, Node):
            spec = Spec(spec)
        if spec.disable is not None:
            self._current_between(0, None)  # validate even when no sequence matches
        result = []
        for start in range(len(self.samples)):
            for match in self.matches(spec.body, start):
                if spec.disable is None or not any(
                    evaluate(spec.disable, event.values).assertion()
                    for event in self._current_between(start, max(start, match.end))
                ):
                    result.append(match)
        return tuple(sorted(result, key=lambda match: (match.end, match.start)))

    def _current_between(self, start, end):
        if self.current is None:
            raise Unsupported("disable iff requires current-value events including every Observed tick")
        observed = {}
        for i, event in enumerate(self.current):
            if event.phase == "observed" and event.time in self.times:
                if event.time in observed:
                    raise Unsupported("duplicate Observed snapshot for a tick")
                observed[event.time] = i
        if not set(self.times).issubset(observed):
            raise Unsupported("disable iff requires current-value events including every Observed tick")
        begin = observed[self.times[start]]
        final = observed[self.times[end]] + 1 if end is not None else len(self.current)
        return self.current[begin:final]
