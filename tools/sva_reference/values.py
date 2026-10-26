"""Small integral four-state expression evaluator, clauses 11.4/11.6/11.8.

Signals carry their declared width and signedness in Bits. Python integers
are signed 32-bit test inputs; VCD strings are unsigned bit vectors. This is
not an implementation of real, string, cast, class or user-function semantics.
"""

from dataclasses import dataclass
import re

from .parser import Node, Unsupported


@dataclass(frozen=True)
class Bits:
    bits: str
    signed: bool = False
    fill: bool = False
    lsb: int = 0
    ascending: bool = False

    def __post_init__(self):
        if not re.fullmatch("[01xz]+", self.bits):
            raise Unsupported(f"invalid four-state value: {self.bits}")

    @property
    def width(self):
        return len(self.bits)

    def resize(self, width, signed=None):
        extension = self.bits[0] if self.signed or self.fill else "0"
        return Bits(self.bits.rjust(width, extension)[-width:],
                    self.signed if signed is None else signed)

    def integer(self):
        if "x" in self.bits or "z" in self.bits:
            raise Unsupported("unknown value used as an integer")
        result = int(self.bits, 2)
        return result - (1 << self.width) if self.signed and self.bits[0] == "1" else result

    def truth(self):
        if "1" in self.bits:
            return True
        return None if "x" in self.bits or "z" in self.bits else False

    def assertion(self):
        # 16.6: unknown Boolean values do not satisfy an assertion expression.
        return self.truth() is True

    def bit(self, index):
        offset = self.lsb - index if self.ascending else index - self.lsb
        return self.bits[-1 - offset] if 0 <= offset < self.width else "x"


def number(value, width=32, signed=True):
    return Bits(format(value & ((1 << width) - 1), f"0{width}b"), signed)


def logical(value):
    return Bits("x" if value is None else "1" if value else "0")


def literal(text):
    text = text.replace("_", "").lower().replace("?", "z")
    if "'" not in text:
        value = int(text)
        return number(value, max(32, value.bit_length() + 1))
    width, digits = text.split("'")
    if not width and digits in "01xz":
        return Bits(digits, fill=True)
    signed = digits.startswith("s")
    if signed:
        digits = digits[1:]
    base, digits = digits[0], digits[1:]
    if base == "d":
        if any(c in "xz" for c in digits):
            if len(set(digits)) != 1:
                raise Unsupported("mixed unknown decimal literal")
            result = Bits(digits[0] * (int(width) if width else 32), signed)
        else:
            size = int(width) if width else max(32, int(digits).bit_length())
            result = number(int(digits), size, signed)
    else:
        size = {"b": 1, "o": 3, "h": 4}[base]
        bits = "".join(c * size if c in "xz" else format(int(c, 16), f"0{size}b")
                       for c in digits)
        if base == "b" and any(c not in "01xz" for c in digits):
            raise Unsupported("invalid binary digit")
        if base == "o" and any(c not in "01234567xz" for c in digits):
            raise Unsupported("invalid octal digit")
        target = int(width) if width else max(32, len(bits))
        extension = bits[0] if bits[0] in "xz" else "0"
        result = Bits(bits.rjust(target, extension)[-target:], signed)
    if result.width < 1:
        raise Unsupported("zero-width literal")
    return result


def coerce(value):
    if isinstance(value, Bits):
        return value
    if isinstance(value, int):
        return number(value)
    if isinstance(value, str):
        return Bits(value.lower())
    raise Unsupported(f"unsupported integral input type: {type(value).__name__}")


def _align(a, b):
    width, signed = max(a.width, b.width), a.signed and b.signed
    # An unsigned operand suppresses sign extension of BOTH operands (11.8).
    def extend(value):
        raw = Bits(value.bits, value.signed and signed, value.fill)
        return raw.resize(width, signed)
    return extend(a), extend(b)


def _bitwise(operator, a, b):
    result = []
    for x, y in zip(a.bits, b.bits):
        if operator == "&":
            bit = "0" if "0" in (x, y) else "1" if x == y == "1" else "x"
        elif operator == "|":
            bit = "1" if "1" in (x, y) else "0" if x == y == "0" else "x"
        else:
            bit = str(int(x != y)) if x in "01" and y in "01" else "x"
            if operator in {"~^", "^~"} and bit in "01":
                bit = "1" if bit == "0" else "0"
        result.append(bit)
    return Bits("".join(result), a.signed)


def shape(node, values):
    op = node.op
    if op == "literal":
        value = literal(node.value)
        return value.width, value.signed
    if op == "name":
        if node.value not in values:
            raise Unsupported(f"unknown signal or parameter: {node.value}")
        value = coerce(values[node.value])
        return value.width, value.signed
    if op == "self":
        return shape(node.args[0], values)
    if op == "cast":
        return node.value[:2]
    if op == "select":
        hi = evaluate(node.args[1], values).integer()
        lo = evaluate(node.args[2], values).integer() if len(node.args) == 3 else hi
        base = evaluate(node.args[0], values)
        if len(node.args) == 3 and hi != lo and (hi < lo) != base.ascending:
            raise Unsupported("part-select direction differs from the declared packed range")
        return abs(hi - lo) + 1, False
    if op == "concat":
        return sum(shape(arg, values)[0] for arg in node.args), False
    if op == "unary":
        return (1, False) if node.value in {"!", "&", "|", "^", "~&", "~|", "~^", "^~"} else shape(node.args[0], values)
    if op == "inside":
        return 1, False
    if op == "binary":
        if node.value in {"&&", "||", "->", "<->", "==", "!=", "===", "!==", "==?", "!=?", "<", "<=", ">", ">="}:
            return 1, False
        a, b = (shape(arg, values) for arg in node.args)
        return a if node.value in {"<<", ">>", "<<<", ">>>", "**"} else (max(a[0], b[0]), a[1] and b[1])
    if op == "ternary":
        a, b = (shape(arg, values) for arg in node.args[1:])
        return max(a[0], b[0]), a[1] and b[1]
    raise Unsupported(f"unsupported integral expression: {op}")


def evaluate(node, values, context_width=None, context_signed=None):
    natural_width, natural_signed = shape(node, values)
    width = max(natural_width, context_width or 0)
    signed = natural_signed if context_signed is None else context_signed
    result = _evaluate(node, values, width, signed)
    if context_width is None and context_signed is None and node.op in {"name", "cast", "self"}:
        return result
    return Bits(result.bits, result.signed and signed, result.fill).resize(width, signed)


def _evaluate(node, values, context_width, context_signed):
    op = node.op
    if op == "literal":
        return literal(node.value)
    if op == "name":
        if node.value not in values:
            raise Unsupported(f"unknown signal or parameter: {node.value}")
        return coerce(values[node.value])
    if op == "call":
        raise Unsupported(f"unresolved named instance or function: {node.value}")
    if op == "self":
        return evaluate(node.args[0], values)
    if op == "cast":
        width, signed, two_state, lsb, ascending = node.value
        # A static cast has assignment context (6.24.1): its width reaches
        # arithmetic operands before evaluation, while extension follows the
        # expression's signedness before the final target-type conversion.
        result = evaluate(node.args[0], values, width).resize(width, signed)
        return Bits(result.bits.translate(str.maketrans("xz", "00")) if two_state else result.bits,
                    signed, False, lsb, ascending)
    if op == "inside":
        results = []
        for member in node.args[1:]:
            if member.op == "setrange":
                value = evaluate(node.args[0], values)
                low = -(1 << (value.width - 1)) if value.signed else 0
                high = (1 << (value.width - int(value.signed))) - 1
                lo, hi = member.args
                lo = Node("literal", value=str(low)) if lo.op == "unbounded" else lo
                hi = Node("literal", value=str(high)) if hi.op == "unbounded" else hi
                a = evaluate(Node("binary", (node.args[0], lo), ">="), values).truth()
                b = evaluate(Node("binary", (node.args[0], hi), "<="), values).truth()
                results.append(False if a is False or b is False else None if None in (a, b) else True)
            else:
                results.append(evaluate(Node("binary", (node.args[0], member), "==?"), values).truth())
        return logical(True if True in results else None if None in results else False)
    if op == "concat":
        return Bits("".join(evaluate(arg, values).bits for arg in node.args))
    if op == "select":
        base = evaluate(node.args[0], values)
        high = evaluate(node.args[1], values).integer()
        low = evaluate(node.args[2], values).integer() if len(node.args) == 3 else high
        step = 1 if high < low else -1
        return Bits("".join(base.bit(i) for i in range(high, low + step, step)))
    if op == "ternary":
        condition = evaluate(node.args[0], values).truth()
        a, b = (evaluate(arg, values, context_width, context_signed) for arg in node.args[1:])
        if condition is not None:
            return a if condition else b
        return Bits("".join(x if x == y else "x" for x, y in zip(a.bits, b.bits)), a.signed)
    if op == "unary":
        operator = node.value
        a = (evaluate(node.args[0], values, context_width, context_signed)
             if operator in {"+", "-", "~"} else evaluate(node.args[0], values))
        if operator == "!":
            truth = a.truth()
            return logical(None if truth is None else not truth)
        if operator == "~":
            return Bits("".join({"0": "1", "1": "0", "x": "x", "z": "x"}[c]
                                for c in a.bits), a.signed)
        if operator in {"+", "-"}:
            if any(c in "xz" for c in a.bits):
                return Bits("x" * a.width, a.signed)
            return number(a.integer() * (-1 if operator == "-" else 1), a.width, a.signed)
        if operator in {"&", "~&"}:
            truth = False if "0" in a.bits else None if any(c in "xz" for c in a.bits) else True
        elif operator in {"|", "~|"}:
            truth = a.truth()
        else:
            truth = None if any(c in "xz" for c in a.bits) else a.bits.count("1") % 2 == 1
        if operator in {"~&", "~|", "~^", "^~"} and truth is not None:
            truth = not truth
        return logical(truth)
    if op != "binary":
        raise Unsupported(f"not an integral expression: {op}")
    operator = node.value
    if operator in {"&&", "||", "->", "<->"}:
        a, b = (evaluate(arg, values) for arg in node.args)
    elif operator in {"<<", ">>", "<<<", ">>>", "**"}:
        a = evaluate(node.args[0], values, context_width, context_signed)
        b = evaluate(node.args[1], values)
    elif operator in {"==", "!=", "===", "!==", "==?", "!=?", "<", "<=", ">", ">="}:
        a_shape, b_shape = (shape(arg, values) for arg in node.args)
        common_width, common_signed = max(a_shape[0], b_shape[0]), a_shape[1] and b_shape[1]
        a, b = (evaluate(arg, values, common_width, common_signed) for arg in node.args)
    else:
        a, b = (evaluate(arg, values, context_width, context_signed) for arg in node.args)
    if operator in {"&&", "||", "->", "<->"}:
        x, y = a.truth(), b.truth()
        if operator == "->":
            x = None if x is None else not x
            return logical(True if x is True or y is True else None if None in (x, y) else False)
        if operator == "<->":
            return logical(None if None in (x, y) else x == y)
        if operator == "&&":
            return logical(False if x is False or y is False else None if None in (x, y) else True)
        return logical(True if x is True or y is True else None if None in (x, y) else False)
    if operator in {"<<", ">>", "<<<", ">>>", "**"}:
        width, signed = a.width, a.signed
    else:
        a, b = _align(a, b)
        width, signed = a.width, a.signed
    if operator in {"&", "|", "^", "~^", "^~"}:
        return _bitwise(operator, a, b)
    if operator in {"===", "!=="}:
        same = a.bits == b.bits
        return logical(same if operator == "===" else not same)
    if operator in {"==?", "!=?"}:
        mismatch = any(x in "01" and y in "01" and x != y for x, y in zip(a.bits, b.bits))
        unknown = any(x in "xz" and y in "01" for x, y in zip(a.bits, b.bits))
        truth = False if mismatch else None if unknown else True
        return logical(None if truth is None else truth if operator == "==?" else not truth)
    if operator in {"==", "!="}:
        mismatch = any(x in "01" and y in "01" and x != y for x, y in zip(a.bits, b.bits))
        unknown = any(c in "xz" for c in a.bits + b.bits)
        truth = False if mismatch else None if unknown else True
        return logical(None if truth is None else truth if operator == "==" else not truth)
    comparison = operator in {"<", "<=", ">", ">="}
    if any(c in "xz" for c in b.bits):
        return Bits("x" * (1 if comparison else width), False if comparison else signed)
    y = b.integer()
    if operator in {"<<", ">>", "<<<", ">>>"}:
        if y < 0:
            return Bits("x" * width, signed)
        if operator in {"<<", "<<<"}:
            return Bits((a.bits + "0" * min(y, width))[-width:], signed)
        fill = a.bits[0] if operator == ">>>" and signed else "0"
        return Bits((fill * min(y, width) + a.bits)[:width], signed)
    if any(c in "xz" for c in a.bits):
        return Bits("x" * (1 if comparison else width), False if comparison else signed)
    x = a.integer()
    if comparison:
        return logical({"<": x < y, "<=": x <= y, ">": x > y, ">=": x >= y}[operator])
    if operator in {"/", "%"}:
        if y == 0:
            return Bits("x" * width, signed)
        quotient = (abs(x) // abs(y)) * (-1 if (x < 0) != (y < 0) else 1)
        result = quotient if operator == "/" else x - quotient * y
    elif operator == "**":
        if y < 0:
            result = 1 if x == 1 else (-1 if y % 2 else 1) if x == -1 else 0
        else:
            result = pow(x, y, 1 << width)
    else:
        result = {"+": lambda: x + y, "-": lambda: x - y, "*": lambda: x * y}[operator]()
    return number(result, width, signed)
