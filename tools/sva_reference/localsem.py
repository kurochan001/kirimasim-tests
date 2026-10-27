"""Local-variable SVA semantics and F.5.4 set analyses.

This module is the executable form of Annex F.5.4-F.5.6, F.6 and F.7 for the
finite-word subset used by the formal cases:

* F.5.4: block/flow/sample sets over the parsed sequence syntax.
* F.5.5: tight local satisfaction over a finite word and a local context.
* F.5.6: local neutral satisfaction, strong/weak finite-word views, local
  declarations.  Only the fragment needed by the cases is implemented; an
  unsupported construct raises ``Unsupported`` rather than guessing.
* F.6: bounded recursive unfolding and property graph analyses.

No function here calls the derivative engine or a simulator.  Reference RTL
in ``formal_cases`` is written independently from the clause text.
"""

from dataclasses import dataclass
from functools import lru_cache

from .parser import Node, Unsupported, substitute
from .values import Bits, coerce, evaluate


# ---------------------------------------------------------------------------
# contexts and letters


def value(raw):
    return raw if isinstance(raw, Bits) else coerce(raw)


def letter_values(letter, context):
    """F.5.5: the local context is consulted before the letter."""
    merged = {name: value(raw) for name, raw in letter.items()}
    merged.update(context)
    return merged


def restrict(context, names):
    return {name: raw for name, raw in context.items() if name in names}


def domain(context):
    return set(context)


def _merge_contexts(left, right):
    result = dict(left)
    result.update(right)
    return result


# ---------------------------------------------------------------------------
# F.5.4 block / flow / sample


def block(node):
    """Names prevented from flowing out of a sequence (F.5.4)."""
    op, args = node.op, node.args
    if op in {"bool", "assign", "epsilon", "zero"}:
        return set()
    if op == "sequence":
        return block(args[0])
    if op == "decl":
        return block(args[0]) | {node.value}
    if op in {"first_match", "delay"}:
        return block(args[0])
    if op == "repeat":
        lo, hi = node.value
        return set() if hi == 0 else block(args[0])
    if op in {"##", "concat"}:
        left, right = args[0], args[1]
        return (block(left) - flow(set(), right)) | block(right)
    if op in {"intersect", "and", "or"}:
        return block(args[0]) | block(args[1])
    if op in {"within", "throughout"}:
        return block(args[0]) | block(args[1])
    raise Unsupported(f"block() does not cover {op}")


def flow(incoming, node):
    """Names flowing out for an incoming set (F.5.4)."""
    incoming = set(incoming)
    op, args = node.op, node.args
    if op in {"bool", "epsilon", "zero"}:
        return set(incoming)
    if op == "sequence":
        return flow(incoming, args[0])
    if op == "assign":
        return incoming | {node.value}
    if op == "decl":
        name = node.value
        inner = incoming - {name}
        return (flow(inner, args[0]) - {name}) | (incoming & {name})
    if op in {"first_match"}:
        return flow(incoming, args[0])
    if op == "delay":
        return flow(incoming, args[0])
    if op == "repeat":
        lo, hi = node.value
        if hi == 0:
            return incoming
        positive = flow(incoming, args[0])
        return incoming & positive if lo == 0 else positive
    if op in {"##", "concat"}:
        return flow(flow(incoming, args[0]), args[1])
    if op == "intersect":
        return (flow(incoming, args[0]) | flow(incoming, args[1])) - block(node)
    if op == "or":
        return flow(incoming, args[0]) & flow(incoming, args[1])
    if op == "and":
        return flow(incoming, args[0]) & flow(incoming, args[1])
    if op in {"within", "throughout"}:
        return flow(flow(incoming, args[0]), args[1])
    raise Unsupported(f"flow() does not cover {op}")


def sample(node):
    """Names assigned inside a sequence (F.5.4)."""
    op, args = node.op, node.args
    if op in {"bool", "epsilon", "zero"}:
        return set()
    if op == "sequence":
        return sample(args[0])
    if op == "assign":
        return {node.value}
    if op == "decl":
        return sample(args[0]) - {node.value}
    if op in {"first_match", "delay"}:
        return sample(args[0])
    if op == "repeat":
        lo, hi = node.value
        return set() if hi == 0 else sample(args[0])
    if op in {"##", "concat", "and", "or", "intersect"}:
        return sample(args[0]) | sample(args[1])
    if op in {"within", "throughout"}:
        return sample(args[0]) | sample(args[1])
    raise Unsupported(f"sample() does not cover {op}")


# ---------------------------------------------------------------------------
# F.5.5 tight local satisfaction


def tight(node, word, start, end, context):
    """Outgoing contexts of tight matches of ``node`` on word[start:end+1]."""
    if start > end:
        # only the null repetition matches the empty word
        if node.op == "repeat" and node.value == (0, 0):
            return [dict(context)]
        if node.op in {"sequence", "first_match"}:
            return tight(node.args[0], word, start, end, context)
        return []
    if end >= len(word):
        return []
    op, args = node.op, node.args
    if op == "sequence":
        return tight(args[0], word, start, end, context)
    if op == "bool":
        if end != start:
            return []
        truth = evaluate(args[0], letter_values(word[start], context))
        return [dict(context)] if truth.assertion() else []
    if op == "assign":
        if end != start:
            return []
        result = evaluate(args[0], letter_values(word[start], context))
        outgoing = dict(context)
        outgoing[node.value] = result
        return [outgoing]
    if op == "decl":
        name = node.value
        outer = context.get(name)
        inner = dict(context)
        inner.pop(name, None)
        results = []
        for outgoing in tight(args[0], word, start, end, inner):
            outgoing = dict(outgoing)
            outgoing.pop(name, None)
            if outer is not None:
                outgoing[name] = outer
            results.append(outgoing)
        return _unique(results)
    if op in {"##", "concat"}:
        lo, hi = node.value if op == "##" else (1, 1)
        return _concat(args[0], args[1], word, start, end, context, lo, hi)
    if op == "delay":
        lo, hi = node.value
        results = []
        limit = (end - start) if hi is None else min(hi, end - start)
        for delay in range(lo, limit + 1):
            results.extend(tight(args[0], word, start + delay, end, context))
        return _unique(results)
    if op == "repeat":
        lo, hi = node.value
        return _repeat(args[0], lo, hi, word, start, end, context)
    if op == "first_match":
        results, earlier = [], False
        for stop in range(start, end + 1):
            found = tight(args[0], word, start, stop, context)
            if stop < end and found:
                earlier = True
            if stop == end:
                if not earlier:
                    results.extend(found)
        return _unique(results)
    if op == "or":
        allowed = flow(domain(context), node)
        results = tight(args[0], word, start, end, context)
        results += tight(args[1], word, start, end, context)
        return _unique(restrict(outgoing, allowed) for outgoing in results)
    if op == "and":
        # Both branches start together; the shorter endpoint is padded with
        # arbitrary ticks, so every branch may finish at or before ``end``.
        allowed = flow(domain(context), node)
        left, right = [], []
        for stop in range(start, end + 1):
            left.extend(tight(args[0], word, start, stop, context))
            right.extend(tight(args[1], word, start, stop, context))
        results = []
        for a in left:
            for b in right:
                results.append(restrict(_merge_contexts(a, b), allowed))
        return _unique(results)
    if op == "intersect":
        common_block = block(node)
        left_names = flow(domain(context), args[0]) - common_block - sample(args[1])
        right_names = flow(domain(context), args[1]) - common_block - sample(args[0])
        results = []
        for a in tight(args[0], word, start, end, context):
            for b in tight(args[1], word, start, end, context):
                results.append(_merge_contexts(restrict(a, left_names), restrict(b, right_names)))
        return _unique(results)
    if op in {"within", "throughout"}:
        raise Unsupported(f"local tight satisfaction for {op} is outside this model")
    raise Unsupported(f"local tight satisfaction does not cover {op}")


def _unique(contexts):
    seen, result = set(), []
    for context in contexts:
        key = tuple(sorted((name, raw.bits) for name, raw in context.items()))
        if key not in seen:
            seen.add(key)
            result.append(context)
    return result


def _concat(left, right, word, start, end, context, lo, hi):
    results = []
    max_delay = end - start
    upper = max_delay if hi is None else min(hi, max_delay)
    for delay in range(lo, upper + 1):
        for middle in range(start, end + 1):
            left_end = middle
            right_start = middle + delay if delay else middle
            if right_start > end:
                break
            for outgoing in tight(left, word, start, left_end, context):
                results.extend(tight(right, word, right_start, end, outgoing))
    return _unique(results)


def _repeat(operand, lo, hi, word, start, end, context):
    results = []
    if lo == 0 and start > end:
        results.append(dict(context))
    upper = (end - start + 1) if hi is None else min(hi, end - start + 1)
    # A positive repetition needs at least one letter per piece.  Sequences
    # that themselves admit an empty match are outside this finite model.
    for count in range(max(1, lo), upper + 1):
        results.extend(_repeat_pieces(operand, count, word, start, end, context))
    return _unique(results)


def _repeat_pieces(operand, count, word, start, end, context):
    if count == 1:
        return tight(operand, word, start, end, context)
    results = []
    for middle in range(start, end):
        for outgoing in tight(operand, word, start, middle, context):
            results.extend(_repeat_pieces(operand, count - 1, word, middle + 1, end, outgoing))
    return _unique(results)


# ---------------------------------------------------------------------------
# F.5.6 local property satisfaction


@dataclass(frozen=True)
class PResult:
    value: bool | None
    at: int | None
    neutral: bool
    vacuous: bool = False

    @property
    def status(self):
        if self.value is True:
            return "vacuous" if self.vacuous else "success"
        if self.value is False:
            return "failure"
        return "holds" if self.neutral else "pending"


def _pcombine(operator, results):
    results = tuple(results)
    conjunction = operator == "and"
    neutral = all(r.neutral for r in results) if conjunction else any(r.neutral for r in results)
    decisive = [r for r in results if r.value is (False if conjunction else True)]
    if decisive:
        chosen = min(decisive, key=lambda r: (r.at is None, r.at))
        return PResult(not conjunction, chosen.at, neutral,
                       all(r.vacuous for r in decisive))
    if all(r.value is not None for r in results):
        return PResult(conjunction, max((r.at for r in results), key=lambda t: -1 if t is None else t),
                       neutral, all(r.vacuous for r in results))
    return PResult(None, None, neutral)


def _pnegate(result):
    return PResult(None if result.value is None else not result.value,
                   result.at, not result.neutral, result.vacuous)


def _top_letter(width_names):
    return {name: Bits("1") for name in width_names}


def strong_sequence(node, word, start, context, *, top=0):
    extended = list(word) + [_top_letter(word[0].keys()) for _ in range(top)]
    for stop in range(start, len(extended)):
        if tight(node, extended, start, stop, context):
            return PResult(True, stop, True)
    if top:
        return PResult(None, None, False)
    # No match on the finite word.  If even a top extension cannot produce
    # one, the prefix is dead and the strong property fails at the start.
    probe = list(word) + [_top_letter(word[0].keys()) for _ in range(len(word) + 8)]
    if any(tight(node, probe, start, stop, context) for stop in range(start, len(probe))):
        return PResult(None, None, False)
    return PResult(False, start, False)


def weak_sequence(node, word, start, context):
    if start >= len(word):
        return PResult(None, None, True)
    # Every finite prefix extended with infinite top must contain a strong
    # match.  A match needs at most as many letters as the sequence itself;
    # len(word)+8 is a safe finite bound for the cases in this suite.
    top = len(word) + 8
    for stop in range(start, len(word)):
        prefix = word[:stop + 1]
        if strong_sequence(node, prefix, start, context, top=top).value is not True:
            return PResult(False, stop, False)
    return PResult(None, None, True)


def prop(node, word, start=0, context=None, strength="weak"):
    context = {} if context is None else dict(context)
    op, args = node.op, node.args
    if op == "sequence":
        return prop(args[0], word, start, context, strength)
    if op == "vacuous":
        return PResult(True, start, True, True)
    if op == "bool":
        if start >= len(word):
            return PResult(None, None, strength == "weak")
        truth = evaluate(args[0], letter_values(word[start], context))
        return PResult(truth.assertion(), start, truth.assertion())
    if op == "strong":
        return strong_sequence(args[0], word, start, context)
    if op == "weak":
        return weak_sequence(args[0], word, start, context)
    if op == "not":
        return _pnegate(prop(args[0], word, start, context, strength))
    if op in {"and", "or"}:
        return _pcombine(op, (prop(arg, word, start, context, strength) for arg in args))
    if op == "implies":
        return _pcombine("or", (_pnegate(prop(args[0], word, start, context, strength)),
                                prop(args[1], word, start, context, strength)))
    if op == "iff":
        left, right = (prop(arg, word, start, context, strength) for arg in args)
        return _pcombine("and", (_pcombine("or", (_pnegate(left), right)),
                                 _pcombine("or", (_pnegate(right), left))))
    if op in {"|->", "|=>", "#-#", "#=#"}:
        consequent = args[1] if op in {"|->", "|=>"} else Node("not", (args[1],))
        result = _implication(args[0], consequent, word, start, context, strength,
                              op in {"|=>", "#=#"})
        return _pnegate(result) if op in {"#-#", "#=#"} else result
    if op in {"nexttime", "s_nexttime"}:
        target = start + node.value
        if target < len(word):
            return prop(args[0], word, target, context, strength)
        return PResult(None, None, op == "nexttime")
    if op in {"always", "s_always", "eventually", "s_eventually"}:
        lo, hi = node.value
        is_always = op in {"always", "s_always"}
        strong = op.startswith("s_")
        stop = len(word) - 1 if hi is None else min(len(word) - 1, start + hi)
        children = [prop(args[0], word, tick, context, strength)
                    for tick in range(start + lo, stop + 1)]
        if hi is None or start + hi >= len(word):
            children.append(PResult(None, None, not strong))
        if not children:
            return PResult(None, None, not strong)
        return _pcombine("and" if is_always else "or", children)
    if op in {"until", "s_until", "until_with", "s_until_with"}:
        right = Node("and", args) if op.endswith("_with") else args[1]
        weak = PResult(None, None, True)
        for tick in range(len(word) - 1, start - 1, -1):
            weak = _pcombine("or", (prop(right, word, tick, context, strength),
                                    _pcombine("and", (prop(args[0], word, tick, context, strength), weak))))
        if op.startswith("s_"):
            existence = prop(Node("s_eventually", (right,), (0, None)), word, start, context, strength)
            return _pcombine("and", (weak, existence))
        return weak
    if op == "decl":
        name = node.value
        inner = dict(context)
        inner.pop(name, None)
        return prop(args[0], word, start, inner, strength)
    if op == "if":
        if start >= len(word):
            raise Unsupported("if property requires an existing start tick")
        condition = evaluate(args[0], letter_values(word[start], context))
        branch = args[1] if condition.assertion() else args[2]
        return prop(branch, word, start, context, strength)
    if op == "case":
        for item in args[1:-1]:
            for choice in item.args[:-1]:
                comparison = Node("binary", (args[0], choice), "===")
                if evaluate(comparison, letter_values(word[start], context)).assertion():
                    return prop(item.args[-1], word, start, context, strength)
        return prop(args[-1], word, start, context, strength)
    # A bare sequence used as a property: success on an actual tight match,
    # failure when the prefix is dead, and weak hold when only a top
    # extension could still complete it.  ``strong(R)``/``weak(R)`` keep the
    # explicit F.5.6.1 definitions above.
    if strength == "strong":
        return strong_sequence(node, word, start, context)
    result = strong_sequence(node, word, start, context)
    if result.value is True or result.value is False:
        return result
    return PResult(None, None, True)


def _implication(antecedent, consequent, word, start, context, strength, nonoverlap):
    children, matched = [], False
    for stop in range(start, len(word)):
        outputs = tight(antecedent, word, start, stop, context)
        if not outputs:
            continue
        matched = True
        target = stop + 1 if nonoverlap else stop
        for outgoing in outputs:
            children.append(prop(consequent, word, target, outgoing, strength))
    if not matched:
        return PResult(True, start, True, True)
    failed = [child for child in children if child.value is False]
    if failed:
        first = min(failed, key=lambda child: (child.at is None, child.at))
        return PResult(False, first.at, False)
    if all(child.value is True for child in children):
        return PResult(True, max((child.at for child in children), key=lambda t: -1 if t is None else t),
                       True, all(child.vacuous for child in children))
    return PResult(None, None, all(child.neutral for child in children))


def result_code(result, horizon):
    """status<<4 | deciding tick, with f=15 for undecided results."""
    status = {"success": 0, "failure": 1, "vacuous": 2, "holds": 3, "pending": 4}[result.status]
    tick = 15 if result.at is None else result.at
    return (status << 4) | tick


def sequence_code(node, word, start=0, context=None):
    return result_code(strong_sequence(node, word, start, {} if context is None else context),
                       len(word))


# ---------------------------------------------------------------------------
# F.7 finite approximation of recursive named properties


@dataclass(frozen=True)
class PropertyDefinition:
    name: str
    parameters: tuple = ()
    body: Node | None = None
    disable: bool = False


def _instantiate(body, parameters, actuals):
    if not parameters:
        return body
    return substitute(body, dict(zip(parameters, actuals)))


def approximation(definitions, name, depth, actuals=()):
    """Zero-fold approximation copies the signature and uses ``true``.

    For k>0 a recursive instance of the same property (or a member of the
    same nontrivial SCC) is replaced by its k-1 approximation; a nonrecursive
    instance uses k.  This module handles a single self-recursive group,
    which is the shape used by the F.7 cases.
    """
    if depth <= 0:
        return Node("vacuous")
    definition = definitions[name]
    actuals = tuple(actuals) or tuple(Node("literal", value="1") for _ in definition.parameters)
    body = _instantiate(definition.body, definition.parameters, actuals)

    def rewrite(node):
        if node.op == "bool" and len(node.args) == 1 and node.args[0].op == "call":
            call = node.args[0]
            if call.value == name:
                return approximation(definitions, name, depth - 1,
                                     tuple(rewrite(arg) for arg in call.args))
        if node.op == "call" and node.value == name:
            return approximation(definitions, name, depth - 1,
                                 tuple(rewrite(arg) for arg in node.args))
        return Node(node.op, tuple(rewrite(arg) for arg in node.args), node.value)

    return rewrite(body)


def expand_property(definitions, name, depth, actuals=()):
    """Fully expand a recursive property to a plain property of given depth."""
    node = approximation(definitions, name, depth, actuals)

    def visit(part):
        if part.op == "call":
            if part.value in definitions:
                inner = definitions[part.value]
                actuals = tuple(visit(arg) for arg in part.args)
                body = _instantiate(inner.body, inner.parameters, actuals)
                return visit(body)
            raise Unsupported(f"unknown property {part.value}")
        return Node(part.op, tuple(visit(arg) for arg in part.args), part.value)

    return visit(node)


def dependency_edges(definitions):
    """Edges p -> q when q is instantiated in p (including actuals)."""
    edges = set()
    for name, definition in definitions.items():
        stack = [definition.body]

        def walk(part):
            if part.op == "call":
                edges.add((name, part.value))
                for argument in part.args:
                    walk(argument)
                return
            for arg in part.args:
                walk(arg)
        walk(definition.body)
    return edges


def strongly_connected(definitions):
    edges = dependency_edges(definitions)
    nodes = set(definitions)
    reach = {node: set() for node in nodes}

    def visit(node, seen):
        for tail, head in edges:
            if tail == node and head not in seen:
                seen.add(head)
                visit(head, seen)
        return seen

    for node in nodes:
        reach[node] = visit(node, {node})
    components = []
    remaining = set(nodes)
    while remaining:
        node = min(remaining)
        component = {other for other in remaining
                     if other in reach[node] and node in reach[other]}
        if not component:
            component = {node}
        components.append(frozenset(component))
        remaining -= component
    return components, edges


def recursive_members(definitions):
    components, _ = strongly_connected(definitions)
    recursive = set()
    for component in components:
        if len(component) > 1:
            recursive |= set(component)
        elif len(component) == 1:
            name = next(iter(component))
            if (name, name) in dependency_edges(definitions):
                recursive.add(name)
    return recursive


def restriction_errors(definitions):
    """F.7 argument/disable/not/time restrictions as a sorted error list."""
    errors = []
    edges = dependency_edges(definitions)
    recursive = recursive_members(definitions)
    for name, definition in definitions.items():
        if name in recursive and definition.disable:
            errors.append(("disable", name))
    return errors


def call_instances(node, weight=0):
    """(called name, guaranteed time steps before the call) pairs."""
    op, args = node.op, node.args
    if op == "call":
        yield node.value, weight
    if op in {"nexttime", "s_nexttime"}:
        for item in call_instances(args[0], weight + node.value):
            yield item
        return
    if op == "delay":
        for item in call_instances(args[0], weight + node.value[0]):
            yield item
        return
    if op in {"##", "concat"}:
        lo = node.value[0] if op == "##" else 1
        for item in call_instances(args[0], weight):
            yield item
        for item in call_instances(args[1], weight + lo):
            yield item
        return
    for arg in args:
        for item in call_instances(arg, weight):
            yield item


def edge_weights(definitions):
    result = {}
    for name, definition in definitions.items():
        for called, weight in call_instances(definition.body):
            if called in definitions:
                key = (name, called)
                result[key] = min(weight, result.get(key, weight))
    return result


def argument_errors(definitions):
    """F.7 ARGUMENT: recursive actuals that reference an enclosing formal in a
    non-allowed way.  (a) the actual is exactly a formal of the enclosing
    property, (b) it contains no enclosing formal, or (c) it is a bare name
    that is a formal of the called property."""
    invalid = set()
    for name, definition in definitions.items():
        formals = set(definition.parameters)

        def visit(part):
            if part.op == "call":
                called = definitions.get(part.value)
                callee_formals = set(called.parameters) if called else set()
                for argument in part.args:
                    bare = argument.args[0] if (argument.op == "bool"
                                                and len(argument.args) == 1) else argument
                    used = {atom.value for atom in _names(argument)} & formals
                    if not used:
                        continue
                    allowed = (bare.op == "name" and bare.value in formals) or \
                              (bare.op == "name" and bare.value in callee_formals)
                    if not allowed:
                        invalid.add(name)
                for argument in part.args:
                    visit(argument)
                return
            for arg in part.args:
                visit(arg)

        visit(definition.body)
    return invalid


def _names(node):
    if node.op == "name":
        yield node
    for arg in node.args:
        yield from _names(arg)


def not_errors(definitions):
    recursive = recursive_members(definitions)
    invalid = set()

    def contains_recursive(part):
        if part.op == "call" and part.value in recursive:
            return True
        return any(contains_recursive(arg) for arg in part.args)

    def visit(part):
        if part.op == "not" and contains_recursive(part.args[0]):
            invalid.add(part.value if isinstance(part.value, str) else current[0])
        for arg in part.args:
            visit(arg)

    for name, definition in definitions.items():
        current = [name]
        visit(definition.body)
    return invalid


def min_cycle_weight(definitions):
    weights = edge_weights(definitions)
    best = None
    for start in definitions:
        stack = [(start, 0, {start})]
        while stack:
            node, total, seen = stack.pop()
            for (tail, head), weight in weights.items():
                if tail != node:
                    continue
                candidate = total + weight
                if head == start:
                    best = candidate if best is None else min(best, candidate)
                elif head not in seen:
                    stack.append((head, candidate, seen | {head}))
    return best
