"""Independent recursive-descent SVA subset parser (1800-2023 Tables 16-1/3).

No simulator front end is used. Unsupported syntax is an error, never an
uninterpreted expression that silently becomes true or false.
"""

from dataclasses import dataclass
import re


class Unsupported(ValueError):
    pass


@dataclass(frozen=True)
class Node:
    op: str
    args: tuple = ()
    value: object = None


@dataclass(frozen=True)
class Spec:
    body: Node
    clock: str | None = None
    edge: str | None = None
    disable: Node | None = None


@dataclass(frozen=True)
class Definition:
    kind: str
    parameters: tuple[str, ...]
    spec: Spec
    casts: tuple = ()
    defaults: tuple = ()


LEX = re.compile(r"\s+|//[^\n]*|/\*.*?\*/|"
                 r"(?:\d+)?'[sS]?[bBoOdDhH][0-9a-fA-F_xXzZ?]+|'[01xXzZ]|\d[\d_]*|"
                 r"[a-zA-Z_$][\w$]*(?:\.[a-zA-Z_$][\w$]*)*|"
                 r"===|!==|==\?|!=\?|\|->|\|=>|#-#|#=#|>>>|<<<|<->|"
                 r"##|->|&&|\|\||==|!=|<=|>=|<<|>>|\*\*|~&|~\||~\^|\^~|[^\s]", re.S)

# Binding powers are deliberately different for sequence and property 'and/or'.
SVA = {"##": (90, False), "throughout": (80, True), "within": (70, False),
       "intersect": (60, False), "and": (40, False), "or": (30, False),
       "iff": (25, True), "until": (20, True), "s_until": (20, True),
       "until_with": (20, True), "s_until_with": (20, True), "implies": (20, True),
       "|->": (10, True), "|=>": (10, True), "#-#": (10, True), "#=#": (10, True)}
BOOL = {"||": 1, "&&": 2, "|": 3, "^": 4, "~^": 4, "^~": 4, "&": 5,
        "==": 6, "!=": 6, "===": 6, "!==": 6, "==?": 6, "!=?": 6,
        "<": 7, "<=": 7, ">": 7, ">=": 7, "<<": 8, ">>": 8, ">>>": 8, "<<<": 8,
        "+": 9, "-": 9, "*": 10, "/": 10, "%": 10, "**": 11,
        "->": -2, "<->": -2, "inside": 7, "dist": 7}
SAMPLED = {"$past", "$rose", "$fell", "$stable", "$changed", "$sampled"}
EXCLUDED = {"$isunknown",
            "$global_clock", "accept_on", "reject_on", "sync_accept_on", "sync_reject_on"}


def lex(text):
    return [m[0] for m in LEX.finditer(text)
            if not m[0].isspace() and not m[0].startswith(("//", "/*"))]


class Parser:
    def __init__(self, text):
        self.words = lex(text)
        self.pos = 0

    def peek(self, offset=0):
        i = self.pos + offset
        return self.words[i] if i < len(self.words) else "<end>"

    def pop(self):
        word = self.peek()
        if word == "<end>":
            raise Unsupported("unexpected end of SVA expression")
        self.pos += 1
        return word

    def take(self, word):
        if self.peek() == word:
            self.pos += 1
            return True
        return False

    def need(self, word):
        if not self.take(word):
            raise Unsupported(f"expected {word!r}, got {self.peek()!r}")

    def finish(self):
        if self.peek() != "<end>":
            raise Unsupported(f"unhandled SVA token: {self.peek()}")

    def range(self, default=None):
        if not self.take("["):
            if default is not None:
                return default
            n = self.integer()
            return (n, n)
        if self.take("*"):
            result = (0, None)
        elif self.take("+"):
            result = (1, None)
        else:
            lo = self.integer()
            hi = lo
            if self.take(":"):
                hi = None if self.take("$") else self.integer()
            result = (lo, hi)
        self.need("]")
        if all(isinstance(n, int) for n in result) and result[0] > result[1]:
            raise Unsupported("range lower bound exceeds upper bound")
        return result

    def integer(self):
        # Constant arithmetic in bounds is evaluated with the same expression
        # evaluator as Boolean operands, and must contain no signal names.
        from .values import evaluate
        node = self.boolean()
        try:
            result = evaluate(node, {}).integer()
        except Unsupported:
            return node  # named constant/formal; resolve after instantiation
        if result < 0:
            raise Unsupported("negative sequence/property bound")
        return result

    def spec(self):
        clock = edge = disable = None
        # The clock and disable prefixes may occur in either order (16.12).
        while self.peek() in {"@", "disable"}:
            if self.take("@"):
                if clock is not None:
                    raise Unsupported("multiple clock controls")
                self.need("(")
                edge = self.pop()
                if edge not in {"posedge", "negedge"}:
                    raise Unsupported("only scalar positive/negative clocks are supported")
                clock = self.pop()
                if not re.fullmatch(r"[a-zA-Z_]\w*(?:\.\w+)*", clock):
                    raise Unsupported("clock must be a signal name")
                self.need(")")
            else:
                self.need("disable")
                self.need("iff")
                if disable is not None:
                    raise Unsupported("nested disable iff")
                self.need("(")
                disable = self.boolean()
                self.need(")")
        return Spec(self.temporal(), clock, edge, disable)

    def temporal(self, minimum=0):
        word = self.peek()
        if word in EXCLUDED or word in {"@", "disable"}:
            raise Unsupported(f"unsupported temporal construct: {word}")
        if word in {"not", "nexttime", "s_nexttime"}:
            self.pop()
            bounds = self.range((1, 1)) if word != "not" else None
            if bounds and (bounds[1] != bounds[0]):
                raise Unsupported("nexttime requires a single bound")
            left = Node(word, (self.temporal(50),), None if bounds is None else bounds[0])
        elif word in {"always", "s_always", "eventually", "s_eventually"}:
            self.pop()
            bounds = self.range((0, None))
            if word in {"s_always", "eventually"} and bounds[1] is None:
                raise Unsupported(f"{word} requires a bounded range")
            left = Node(word, (self.temporal(),), bounds)
        elif self.take("if"):
            self.need("(")
            condition = self.boolean()
            self.need(")")
            yes = self.temporal()
            no = self.temporal() if self.take("else") else Node("vacuous")
            left = Node("if", (condition, yes, no))
        elif self.take("case"):
            self.need("(")
            select = self.boolean()
            self.need(")")
            items, default = [], None
            while self.peek() != "endcase":
                if self.take("default"):
                    if default is not None:
                        raise Unsupported("duplicate default case item")
                    self.take(":")
                    default = self.temporal()
                else:
                    choices = [self.boolean()]
                    while self.take(","):
                        choices.append(self.boolean())
                    self.need(":")
                    items.append(Node("item", (*choices, self.temporal())))
                self.need(";")
            self.need("endcase")
            left = Node("case", (select, *items, default or Node("vacuous")))
        elif word in {"strong", "weak", "first_match"}:
            self.pop()
            self.need("(")
            left = Node(word, (self.temporal(),))
            self.need(")")
        elif self.take("##"):
            bounds = self.range()
            left = Node("delay", (self.temporal(91),), bounds)
        elif self.take("("):
            # A parenthesized Boolean expression can continue with a Boolean
            # operator, while a temporal group cannot. Backtrack only here.
            begin = self.pos - 1
            left = self.temporal()
            self.need(")")
            if self.peek() in BOOL or self.peek() in {"?", "["} and self.peek(1) not in {"*", "=", "->", "+"}:
                self.pos = begin
                left = Node("bool", (self.boolean(),))
        else:
            left = Node("bool", (self.boolean(),))
        while True:
            if self.peek() == "[" and self.peek(1) in {"*", "+", "=", "->"}:
                if 100 < minimum:
                    break
                self.pop()
                repetition = self.pop()
                if repetition == "+":
                    bounds = (1, None)
                elif self.peek() == "]":
                    if repetition != "*":
                        raise Unsupported("missing repetition count")
                    bounds = (0, None)
                else:
                    lo = self.integer()
                    hi = lo
                    if self.take(":"):
                        hi = None if self.take("$") else self.integer()
                    bounds = (lo, hi)
                self.need("]")
                if all(isinstance(n, int) for n in bounds) and bounds[0] > bounds[1]:
                    raise Unsupported("invalid repetition range")
                left = Node({"*": "repeat", "+": "repeat", "=": "nonconsecutive", "->": "goto"}[repetition],
                            (left,), bounds)
                continue
            operator = self.peek()
            if operator not in SVA or SVA[operator][0] < minimum:
                break
            bp, right = SVA[operator]
            self.pop()
            bounds = self.range() if operator == "##" else None
            operand = self.temporal(bp if right else bp + 1)
            left = Node(operator, (left, operand), bounds)
        return left

    def boolean(self, minimum=-2):
        word = self.pop()
        if word in EXCLUDED or (word.startswith("$") and word not in SAMPLED) or word.endswith((".triggered", ".matched")):
            raise Unsupported(f"unsupported expression: {word}")
        if word in SAMPLED:
            self.need("(")
            arguments = []
            while True:
                if self.peek() in {",", ")"}:
                    arguments.append(Node("omitted"))
                elif self.take("@"):
                    self.need("(")
                    edge, clock = self.pop(), self.pop()
                    if edge not in {"posedge", "negedge"} or not re.fullmatch(r"[a-zA-Z_]\w*(?:\.\w+)*", clock):
                        raise Unsupported("sampled function clock must be a scalar signal edge")
                    self.need(")")
                    arguments.append(Node("clock", value=(clock, edge)))
                else:
                    arguments.append(self.boolean())
                if not self.take(","):
                    break
            self.need(")")
            maximum = 1 if word == "$sampled" else 4 if word == "$past" else 2
            if len(arguments) > maximum or arguments[0].op in {"omitted", "clock"}:
                raise Unsupported("invalid sampled function arguments")
            for i, argument in enumerate(arguments[1:], 1):
                if ((argument.op == "clock" and i != maximum - 1)
                        or (i == maximum - 1 and argument.op not in {"clock", "omitted"})):
                    raise Unsupported("invalid sampled function clock argument")
            left = Node("sampled", tuple(arguments), word)
        elif word in {"!", "~", "+", "-", "&", "|", "^", "~&", "~|", "~^", "^~"}:
            left = Node("unary", (self.boolean(12),), word)
        elif word == "(":
            left = self.boolean()
            self.need(")")
        elif word == "{":
            parts = [self.boolean()]
            while self.take(","):
                parts.append(self.boolean())
            self.need("}")
            left = Node("concat", tuple(parts))
        elif re.fullmatch(r"[a-zA-Z_]\w*(?:\.\w+)*", word):
            left = Node("name", value=word)
            if self.take("("):
                args = []
                if self.peek() != ")":
                    while True:
                        if self.take("."):
                            name = self.pop()
                            self.need("(")
                            argument = Node("omitted") if self.peek() == ")" else self.boolean()
                            self.need(")")
                            args.append(Node("named", (argument,), name))
                        else:
                            args.append(Node("omitted") if self.peek() in {",", ")"} else self.boolean())
                        if not self.take(","):
                            break
                self.need(")")
                left = Node("call", tuple(args), word)
        elif re.fullmatch(r"\d[\d_]*|(?:\d+)?'[sS]?[bBoOdDhH][0-9a-fA-F_xXzZ?]+|'[01xXzZ]", word):
            left = Node("literal", value=word)
        else:
            raise Unsupported(f"expected Boolean operand, got {word!r}")
        while True:
            if self.peek() == "[" and self.peek(1) not in {"*", "+", "=", "->"}:
                self.pop()
                index = self.boolean()
                end = self.boolean() if self.take(":") else None
                self.need("]")
                left = Node("select", (left, index) if end is None else (left, index, end))
                continue
            if self.peek() == "?" and minimum <= -1:
                self.pop()
                yes = self.boolean()
                self.need(":")
                left = Node("ternary", (left, yes, self.boolean(-1)))
                continue
            operator = self.peek()
            if operator not in BOOL or BOOL[operator] < minimum:
                break
            self.pop()
            bp = BOOL[operator]
            if operator in {"inside", "dist"}:
                self.need("{")
                members = []
                while True:
                    if self.take("["):
                        lo = Node("unbounded", value="low") if self.take("$") else self.boolean()
                        self.need(":")
                        hi = Node("unbounded", value="high") if self.take("$") else self.boolean()
                        self.need("]")
                        member = Node("setrange", (lo, hi))
                    else:
                        member = self.boolean(8)
                    weight = Node("literal", value="1")
                    if operator == "dist" and self.take(":"):
                        if self.pop() not in {"=", "/"}:
                            raise Unsupported("invalid distribution weight operator")
                        weight = self.boolean()
                    members.append(Node("weighted", (member, weight)) if operator == "dist" else member)
                    if not self.take(","):
                        break
                self.need("}")
                left = Node(operator, (left, *members))
            else:
                left = Node("binary", (left, self.boolean(bp if operator in {"->", "<->"} else bp + 1)), operator)
        return left


def parse_spec(text):
    parser = Parser(text)
    result = parser.spec()
    parser.finish()
    return result


def parse_sequence(text):
    result = parse_spec(text)
    if result.clock or result.disable:
        raise Unsupported("use parse_spec for clocked/disabled sequences")
    return result.body


def substitute(node, bindings):
    if node.op == "name" and node.value in bindings:
        return bindings[node.value]
    def value(item):
        if isinstance(item, Node):
            return substitute(item, bindings)
        return tuple(value(part) for part in item) if isinstance(item, tuple) else item
    return Node(node.op, tuple(substitute(arg, bindings) for arg in node.args), value(node.value))


def resolve_bounds(node):
    from .values import evaluate
    value = node.value
    if node.op in {"##", "delay", "repeat", "goto", "nonconsecutive", "always", "s_always",
                   "eventually", "s_eventually", "nexttime", "s_nexttime"}:
        def bound(item):
            if item is None:
                return None
            result = evaluate(item, {}).integer() if isinstance(item, Node) else item
            if result < 0:
                raise Unsupported("negative bound")
            return result
        value = tuple(bound(item) for item in value) if isinstance(value, tuple) else bound(value)
        if isinstance(value, tuple) and value[1] is not None and value[0] > value[1]:
            raise Unsupported("range lower bound exceeds upper bound")
    return Node(node.op, tuple(resolve_bounds(arg) for arg in node.args), value)


def expand(spec, definitions, active=()):
    """Lexical argument substitution, F.4.1; recursion is outside v1."""
    clocks, disables = [], []
    if spec.clock:
        clocks.append((spec.clock, spec.edge))
    if spec.disable:
        disables.append(spec.disable)

    def visit(node, stack):
        if node.op in {"name", "call"} and node.value in definitions and definitions[node.value].kind == "let":
            return visit(Node("bool", (node,)), stack).args[0]
        if node.op == "bool" and node.args[0].op in {"name", "call"}:
            call = node.args[0]
            if call.value in definitions:
                name = call.value
                if name in stack:
                    raise Unsupported(f"recursive SVA definition: {name}")
                definition = definitions[name]
                arguments, positional, named = {}, 0, False
                for argument in call.args:
                    if argument.op == "named":
                        named = True
                        parameter, argument = argument.value, argument.args[0]
                        if parameter not in definition.parameters:
                            raise Unsupported(f"unknown formal {parameter} in {name}")
                    else:
                        if named or positional >= len(definition.parameters):
                            raise Unsupported(f"wrong argument list for {name}")
                        parameter = definition.parameters[positional]
                        positional += 1
                    if parameter in arguments:
                        raise Unsupported(f"duplicate argument {parameter} in {name}")
                    arguments[parameter] = argument
                defaults = definition.defaults or (None,) * len(definition.parameters)
                ordered = []
                for parameter, default in zip(definition.parameters, defaults):
                    argument = arguments.get(parameter, Node("omitted"))
                    if argument.op == "omitted":
                        argument = default
                    if argument is None:
                        raise Unsupported(f"missing argument {parameter} in {name}")
                    ordered.append(argument)
                casts = definition.casts or (None,) * len(definition.parameters)
                actuals = tuple(Node("cast", (arg,), cast) if cast is not None else
                                arg if arg.op in {"name", "select"} else Node("self", (arg,))
                                for arg, cast in zip(ordered, casts))
                bindings = dict(zip(definition.parameters, actuals))
                inner = definition.spec
                if inner.clock:
                    clock = substitute(Node("name", value=inner.clock), bindings)
                    if clock.op != "name":
                        raise Unsupported("clock argument must be a signal name")
                    clocks.append((clock.value, inner.edge))
                if inner.disable:
                    disables.append(substitute(inner.disable, bindings))
                body = visit(substitute(inner.body, bindings), (*stack, name))
                return Node("sequence", (body,)) if definition.kind == "sequence" else body
        return Node(node.op, tuple(visit(arg, stack) for arg in node.args), node.value)

    body = visit(spec.body, active)
    if len(set(clocks)) > 1:
        raise Unsupported("multiple clocks are outside v1")
    if len(disables) > 1:
        raise Unsupported("nested disable iff is illegal")
    clock, edge = clocks[0] if clocks else (None, None)
    return Spec(resolve_bounds(body), clock, edge, disables[0] if disables else None)
