"""Weighted regular derivatives for tight sequence satisfaction (F.5.2).

Coefficients retain match multiplicity. Prefix viability uses the abstract
top letter of F.5, not a guessed number of future ticks. It runs to acceptance
or a repeated Boolean residual, so no arbitrary horizon changes an answer.
"""

from collections import Counter
from functools import cache
from itertools import product

from .parser import Node, Unsupported


ZERO = Node("zero")
EPS = Node("epsilon")
ANY = Node("atom", value=Node("literal", value="1"))


def scale(coefficient, expression):
    if coefficient == 0 or expression == ZERO:
        return ZERO
    if coefficient == 1:
        return expression
    if expression.op == "scale":
        return scale(coefficient * expression.value, expression.args[0])
    return Node("scale", (expression,), coefficient)


def terms(expression):
    if expression == ZERO:
        return []
    if expression.op == "sum":
        return [(term.value, term.args[0]) if term.op == "scale" else (1, term)
                for term in expression.args]
    if expression.op == "scale":
        return [(expression.value, expression.args[0])]
    return [(1, expression)]


def alternative(*expressions):
    counts = Counter()
    for expression in expressions:
        for coefficient, term in terms(expression):
            counts[term] += coefficient
    parts = tuple(scale(count, term) for term, count in sorted(counts.items(), key=lambda p: repr(p[0]))
                  if count)
    return ZERO if not parts else parts[0] if len(parts) == 1 else Node("sum", parts)


def concat(*expressions):
    coefficient, parts = 1, []
    for expression in expressions:
        if expression == ZERO:
            return ZERO
        if expression.op == "scale":
            coefficient *= expression.value
            expression = expression.args[0]
        if expression == EPS:
            continue
        parts.extend(expression.args if expression.op == "concat" else (expression,))
    if any(part.op == "sum" for part in parts):
        choices = [part.args if part.op == "sum" else (part,) for part in parts]
        return scale(coefficient, alternative(*(concat(*choice) for choice in product(*choices))))
    result = EPS if not parts else parts[0] if len(parts) == 1 else Node("concat", tuple(parts))
    return scale(coefficient, result)


@cache
def nullable(expression):
    op, args = expression.op, expression.args
    if op == "epsilon":
        return 1
    if op in {"zero", "atom", "fuse", "nonempty"}:
        return 0
    if op == "scale":
        return expression.value * nullable(args[0])
    if op == "sum":
        return sum(map(nullable, args))
    if op in {"concat", "intersect"}:
        result = 1
        for arg in args:
            result *= nullable(arg)
        return result
    if op == "star":
        return 1
    if op == "first":
        return nullable(args[0])
    raise Unsupported(f"invalid regular operator: {op}")


def nonempty(expression):
    if expression == EPS or expression == ZERO:
        return ZERO
    if not nullable(expression):
        return expression
    return Node("nonempty", (expression,))


def intersect(a, b):
    if a == ZERO or b == ZERO:
        return ZERO
    if a == EPS:
        return scale(nullable(b), EPS)
    if b == EPS:
        return scale(nullable(a), EPS)
    if a.op in {"sum", "scale"} or b.op in {"sum", "scale"}:
        return alternative(*(scale(ca * cb, intersect(ra, rb))
                             for ca, ra in terms(a) for cb, rb in terms(b)))
    return Node("intersect", tuple(sorted((a, b), key=repr)))


def fuse(a, b):
    a, b = nonempty(a), nonempty(b)
    if a == ZERO or b == ZERO:
        return ZERO
    if a.op in {"sum", "scale"} or b.op in {"sum", "scale"}:
        return alternative(*(scale(ca * cb, fuse(ra, rb))
                             for ca, ra in terms(a) for cb, rb in terms(b)))
    return Node("fuse", (a, b))


def star(expression):
    if expression in {ZERO, EPS}:
        return EPS
    if nullable(expression):
        # Otherwise infinitely many zero-length decompositions would make
        # match multiplicity undefined. Do not silently collapse them.
        raise Unsupported("unbounded repetition of an empty-admitting sequence")
    return Node("star", (expression,))


def repeat(expression, lo, hi):
    if hi is None:
        return concat(*([expression] * lo), star(expression))
    return alternative(*(concat(*([expression] * count)) for count in range(lo, hi + 1)))


def first(expression):
    if nullable(expression):
        return scale(nullable(expression), EPS)
    return ZERO if expression == ZERO else Node("first", (expression,))


def derivative(expression, truth):
    """Consume one letter. truth evaluates an entire Boolean atom (F.5)."""
    memo = {}

    def derive(r):
        if r in memo:
            return memo[r]
        op, args = r.op, r.args
        if op in {"zero", "epsilon"}:
            result = ZERO
        elif op == "atom":
            result = EPS if truth(r.value) else ZERO
        elif op == "scale":
            result = scale(r.value, derive(args[0]))
        elif op == "sum":
            result = alternative(*(derive(arg) for arg in args))
        elif op == "concat":
            parts, prefix = [], 1
            for i, arg in enumerate(args):
                if not prefix:
                    break
                parts.append(scale(prefix, concat(derive(arg), *args[i + 1:])))
                prefix *= nullable(arg)
            result = alternative(*parts)
        elif op == "intersect":
            result = intersect(derive(args[0]), derive(args[1]))
        elif op == "fuse":
            left = derive(args[0])
            result = alternative(fuse(left, args[1]), scale(nullable(left), derive(args[1])))
        elif op == "nonempty":
            result = derive(args[0])
        elif op == "star":
            result = concat(derive(args[0]), r)
        elif op == "first":
            result = first(derive(args[0]))
        else:
            raise Unsupported(f"invalid regular derivative: {op}")
        memo[r] = result
        return result
    return derive(expression)


def support(expression):
    """Forget counts ONLY when asking if a future completion exists."""
    op, args = expression.op, expression.args
    if op == "scale":
        return support(args[0])
    if op == "sum":
        parts = set(support(arg) for arg in args) - {ZERO}
        return ZERO if not parts else next(iter(parts)) if len(parts) == 1 else Node("sum", tuple(sorted(parts, key=repr)))
    if op == "concat":
        return concat(*(support(arg) for arg in args))
    if op == "intersect":
        return intersect(*(support(arg) for arg in args))
    if op == "fuse":
        return fuse(*(support(arg) for arg in args))
    if op == "atom":
        return ANY  # every Boolean atom is satisfied by the abstract top letter
    return Node(op, tuple(support(arg) for arg in args), expression.value)


@cache
def viable(expression, require_nonempty=False):
    state = support(expression)
    if require_nonempty:
        state = support(derivative(state, lambda _: True))
    seen = set()
    while state not in seen:
        if nullable(state):
            return True
        seen.add(state)
        state = support(derivative(state, lambda _: True))
    return False


def boolean_node(node):
    return node.args[0] if node.op == "bool" else None


def compile_sequence(node):
    op, args = node.op, node.args
    if op == "bool":
        return Node("atom", value=args[0])
    if op == "sequence":
        return compile_sequence(args[0])
    if op == "delay":
        lo, hi = node.value
        return concat(repeat(ANY, lo, hi), compile_sequence(args[0]))
    if op == "##":
        a, b = map(compile_sequence, args)
        lo, hi = node.value
        overlap = fuse(a, b) if lo == 0 else ZERO
        if hi == 0:
            return overlap
        delayed = concat(a, repeat(ANY, max(1, lo) - 1, None if hi is None else hi - 1), b)
        return alternative(overlap, delayed)
    if op == "repeat":
        return repeat(compile_sequence(args[0]), *node.value)
    if op in {"goto", "nonconsecutive"}:
        boolean = boolean_node(args[0])
        if boolean is None:
            raise Unsupported("goto/nonconsecutive operands must be Boolean expressions")
        no = Node("atom", value=Node("unary", (boolean,), "!"))
        yes = Node("atom", value=boolean)
        result = repeat(concat(star(no), yes), *node.value)
        return concat(result, star(no)) if op == "nonconsecutive" else result
    if op == "first_match":
        return first(compile_sequence(args[0]))
    if op == "throughout":
        boolean = boolean_node(args[0])
        if boolean is None:
            raise Unsupported("throughout left operand must be a Boolean expression")
        return intersect(star(Node("atom", value=boolean)), compile_sequence(args[1]))
    if op == "within":
        a, b = map(compile_sequence, args)
        return intersect(concat(star(ANY), a, star(ANY)), b)
    if op in {"and", "or", "intersect"}:
        a, b = map(compile_sequence, args)
        if op == "intersect":
            return intersect(a, b)
        if op == "or":
            # 16.9.7 distinguishes two Boolean operands from sequence operands.
            if all(boolean_node(arg) is not None for arg in args):
                return Node("atom", value=Node("binary", tuple(boolean_node(arg) for arg in args), "||"))
            return alternative(a, b)
        # Partition endpoint pairs as left <= right and right < left, avoiding
        # a duplicate pair at equal endpoints (16.9.5, Figure 16-6).
        return alternative(intersect(concat(a, star(ANY)), b),
                           intersect(a, concat(b, ANY, star(ANY))))
    raise Unsupported(f"not a supported sequence operator: {op}")
