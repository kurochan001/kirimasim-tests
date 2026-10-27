"""IEEE 1800-2023 F.5.3.3 nonvacuity over finite sampled words.

This is a relation separate from satisfaction.  It is computed from the
inductive equations in F.5.3.3, using the F.5.3.1 neutral finite-word truth
of subproperties for the "earlier suffix satisfies" side conditions.  No RTL
or expected-output file is consulted.  See formal_cases.NONVACUITY for the
independent RTL monitors that are compared against this implementation.
"""

from .engine import Engine
from .parser import Node, Spec, Unsupported

DECIDED = {"success", "failure", "vacuous"}


class Nonvacuity:
    """The F.5.3.3 relation on one finite word (a sampled trace)."""

    def __init__(self, samples):
        self.samples = tuple(dict(row) for row in samples)
        self.size = len(self.samples)
        self.engine = Engine(self.samples)
        self._truth = {}
        self._nv = {}

    def truth(self, node, start):
        """Neutral satisfaction (F.5.3.1) of a property at one suffix."""
        if start >= self.size:
            return False
        key = (node, start)
        if key not in self._truth:
            self._truth[key] = self.engine.property(node, start).finite_truth is True
        return self._truth[key]

    def _empty(self, node):
        """Nonvacuity on the empty word; only the base cases are nonvacuous."""
        op, args = node.op, node.args
        if op == "not":
            return self._empty(args[0])
        if op in {"and", "or", "iff"}:
            return any(self._empty(arg) for arg in args)
        if op == "if":
            if args[2].op == "vacuous":
                # if (b) P is b |-> P; there is no else branch to be nonvacuous.
                return False
            return self._empty(args[1]) or self._empty(args[2])
        if op in {"implies", "|->", "|=>", "#-#", "#=#", "nexttime", "s_nexttime",
                  "always", "s_always", "eventually", "s_eventually",
                  "until", "s_until", "until_with", "s_until_with"}:
            return False
        # strong(R), weak(R), and every sequence used as a property.
        return True

    def _endpoints(self, antecedent, start):
        ends = {match.end for match in self.engine.matches(antecedent, start)
                if match.end >= start}
        return sorted(ends)

    def nv(self, node, start):
        """w^{start..} satisfies node nonvacuously (F.5.3.3 induction)."""
        if start >= self.size:
            return self._empty(node)
        key = (node, start)
        if key in self._nv:
            return self._nv[key]
        op, args = node.op, node.args
        if op == "not":
            value = self.nv(args[0], start)
        elif op in {"and", "or", "iff"}:
            value = any(self.nv(arg, start) for arg in args)
        elif op == "implies":
            # w |= P1, w non P1, w non P2.
            value = (self.truth(args[0], start) and self.nv(args[0], start)
                     and self.nv(args[1], start))
        elif op == "|->":
            value = any(self.nv(args[1], end) for end in self._endpoints(args[0], start))
        elif op == "|=>":
            value = any(self.nv(args[1], end + 1) for end in self._endpoints(args[0], start))
        elif op == "#-#":
            # R #-# P = not (R |-> not P); nv(not P) = nv(P).
            value = any(self.nv(args[1], end) for end in self._endpoints(args[0], start))
        elif op == "#=#":
            value = any(self.nv(args[1], end + 1) for end in self._endpoints(args[0], start))
        elif op in {"nexttime", "s_nexttime"}:
            bound = 1 if node.value is None else node.value
            value = start + bound <= self.size and self.nv(args[0], start + bound)
        elif op in {"always", "s_always"}:
            lo, hi = node.value
            last = self.size - 1 if hi is None else min(hi, self.size - 1)
            value = any(self.nv(args[0], tick)
                        and all(self.truth(args[0], earlier)
                                for earlier in range(start + lo, tick))
                        for tick in range(start + lo, last + 1))
        elif op in {"eventually", "s_eventually"}:
            lo, hi = node.value
            last = self.size - 1 if hi is None else min(hi, self.size - 1)
            value = any(self.nv(args[0], tick)
                        and all(not self.truth(args[0], earlier)
                                for earlier in range(start + lo, tick))
                        for tick in range(start + lo, last + 1))
        elif op in {"until", "s_until", "until_with", "s_until_with"}:
            right = (Node("and", (args[0], args[1]))
                     if op.endswith("_with") else args[1])
            value = any((self.nv(args[0], tick) or self.nv(right, tick))
                        and all(self.truth(args[0], earlier)
                                and not self.truth(right, earlier)
                                for earlier in range(start, tick))
                        for tick in range(start, self.size))
        elif op == "if":
            condition = self.truth(args[0], start)
            if args[2].op == "vacuous":
                # if (b) P = b |-> P: no antecedent match is vacuous.
                value = condition and self.nv(args[1], start)
            else:
                value = ((condition and self.nv(args[1], start))
                         or (not condition and self.nv(args[2], start)))
        elif op == "case":
            raise Unsupported("nonvacuity for case properties is not modelled")
        else:
            # Base case: strong(R), weak(R), and sequence properties.
            value = True
        self._nv[key] = value
        return value

    def spec(self, spec: Spec):
        """Nonvacuity of a parsed spec, including the F.5.3.3 abort rule."""
        if spec.clock is not None:
            raise Unsupported("nonvacuity cases are single-clock unclocked words")
        base = self.nv(spec.body, 0)
        if spec.disable is None:
            return base
        if not base:
            return False
        aborts = [self.engine.history.evaluate(spec.disable, tick).assertion()
                  for tick in range(self.size)]
        if not any(aborts):
            return True
        first = aborts.index(True)
        # An abort-free prefix that already settles the operand keeps the
        # result nonvacuous.  With no sample the empty prefix is not counted:
        # every abort case in NONVACUITY uses a strong sequence whose bottom
        # extension fails and whose top extension satisfies, so the empty
        # prefix settles neither way (documented limitation).
        for length in range(1, first + 1):
            prefix = Nonvacuity(self.samples[:length])
            if prefix.engine.property(spec.body, 0).status in DECIDED:
                return True
        return False


def nonvacuous(expression, samples):
    """True iff the parsed expression is nonvacuously evaluated on the word."""
    from .parser import parse_spec
    return Nonvacuity(samples).spec(parse_spec(expression))


def nonvacuous_satisfaction(expression, samples):
    """Both F.5.3.1 satisfaction and F.5.3.3 nonvacuity hold."""
    from .parser import parse_spec
    spec = parse_spec(expression)
    relation = Nonvacuity(samples)
    satisfied = relation.engine.property(spec.body, 0).finite_truth is True
    return satisfied and relation.spec(spec)
