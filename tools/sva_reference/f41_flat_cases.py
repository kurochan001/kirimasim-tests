"""Formal cases for F.4.1/F.4.2 sequence/property/checker flattening.

The cases model the flattening rules on a finite syntactic universe.  A
*direct* executable model (``actual``) expands the named instances with the
substitution rules of F.4.1.1/F.4.2.1 and then evaluates the resulting SVA
fragment with ``localsem``.  The ``reference`` RTL is written independently
from the clause equations and never calls the parser, the derivative engine
or the evaluator.

Two finite approximations are used throughout:

* local input/inout formals are initialised by injecting the actual's value
  into the local context at the start tick (a declaration initializer is not
  a sequence item and therefore consumes no letter);
* output/inout copy-out is the ``actual = formal`` match assignment appended
  at the sequence end with ``##0``.

``horizon`` is the number of sampled letters, not a global clock period.
"""

from dataclasses import dataclass

from . import localsem as ls
from .f4_common import table
from .parser import Node, parse_sequence, parse_spec
from .values import Bits, evaluate, shape


# ---------------------------------------------------------------------------
# named declarations and their formal descriptors


@dataclass(frozen=True)
class Formal:
    """One formal argument, including the local/typed cases of F.4.1.1."""

    name: str
    direction: str = "nonlocal"       # nonlocal | input | output | inout
    category: str = "expr"            # expr | sequence | property | event
    cast: tuple | None = None         # (width, signed, two_state, lsb, ascending)
    default: Node | None = None


@dataclass(frozen=True)
class Named:
    definition: ls.PropertyDefinition
    formals: tuple


def _n(name):
    return Node("name", value=name)


def _b(name):
    return Node("bool", (_n(name),))


def _lit(value):
    return Node("literal", value=str(value))


def _call(name, *arguments):
    return Node("call", tuple(arguments), name)


def _atom(name, *arguments):
    return Node("bool", (_call(name, *arguments),))


def _cat(left, right, delay=1):
    return Node("##", (left, right), (delay, delay))


def _and(left, right):
    return Node("and", (left, right))


def _or(left, right):
    return Node("or", (left, right))


def _impl(left, right):
    return Node("|->", (left, right))


def _assign(target, expression):
    return Node("assign", (expression,), target)


def _first(node):
    return Node("first_match", (node,))


def _eq(left, right):
    return Node("bool", (Node("binary", (left, right), "=="),))


def _def(name, formals, body):
    parameters = tuple(formal.name for formal in formals)
    return Named(ls.PropertyDefinition(name, parameters, body), tuple(formals))


def _ordinary(name, cast=None, default=None):
    return Formal(name, "nonlocal", "expr", cast, default)


def _sequence(name, default=None):
    return Formal(name, "nonlocal", "sequence", None, default)


def _property(name):
    return Formal(name, "nonlocal", "property")


# A signal type universe for the finite cases: every signal is one bit wide.
TYPES = {"a": Bits("0"), "b": Bits("0"), "c": Bits("0")}

TEMPORAL = {
    "bool", "##", "delay", "repeat", "goto", "nonconsecutive", "first_match",
    "strong", "weak", "sequence", "decl", "assign", "and", "or", "intersect",
    "within", "throughout", "|->", "|=>", "#-#", "#=#", "not", "nexttime",
    "s_nexttime", "always", "s_always", "eventually", "s_eventually", "until",
    "s_until", "until_with", "s_until_with", "implies", "iff", "if", "case",
    "vacuous",
}
BOUNDED = {"##", "delay", "repeat", "goto", "nonconsecutive", "always",
           "s_always", "eventually", "s_eventually", "nexttime", "s_nexttime"}


class Illegal(ValueError):
    """The flattened declaration is not a legal SVA expression."""


def _expr(node):
    return node.args[0] if node.op == "bool" and len(node.args) == 1 else node


def _temporal(node):
    node = _expr(node)
    return node if node.op in TEMPORAL else Node("bool", (node,))


def _type_of(node):
    width, signed = shape(node, TYPES)
    return (width, signed, False, 0, False)


def _bind_actuals(formal_list, arguments):
    positional = 0
    chosen = {}
    for argument in arguments:
        if argument.op == "named":
            chosen[argument.value] = argument.args[0]
        else:
            if positional >= len(formal_list):
                raise Illegal("too many actual arguments")
            chosen[formal_list[positional].name] = argument
            positional += 1
    result = []
    for formal in formal_list:
        if formal.name in chosen:
            result.append(chosen[formal.name])
        elif formal.default is not None:
            result.append(formal.default)
        else:
            raise Illegal(f"missing actual for {formal.name}")
    return result


def _substitute_value(value, definitions, bindings):
    if isinstance(value, Node):
        return _expand(value, definitions, bindings)
    if isinstance(value, tuple):
        return tuple(_substitute_value(item, definitions, bindings) for item in value)
    return value


def _expand(node, definitions, bindings=None):
    """Expand named instances and ordinary formals; return an SVA node."""
    bindings = {} if bindings is None else bindings
    if node.op == "name" and node.value in bindings:
        kind, actual = bindings[node.value]
        return _expand(actual, definitions, {}) if kind == "temporal" else actual
    if node.op == "call":
        return _expand_call(node, definitions, bindings)
    if node.op == "bool" and len(node.args) == 1:
        inner = _expand(node.args[0], definitions, bindings)
        return inner if inner.op in TEMPORAL else Node("bool", (inner,))
    if node.op == "assign":
        target = node.value
        if target in bindings:
            kind, actual = bindings[target]
            if kind != "expr" or actual.op != "name":
                return Node("illegal_assign")
            target = actual.value
        return Node("assign", (_expand(node.args[0], definitions, bindings),), target)
    value = (_substitute_value(node.value, definitions, bindings)
             if node.op in BOUNDED else node.value)
    return Node(node.op, tuple(_expand(arg, definitions, bindings)
                               for arg in node.args), value)


def _expand_call(call, definitions, bindings):
    named = definitions.get(call.value)
    if named is None:
        raise Illegal(f"unknown named declaration {call.value}")
    arguments = [_expand(argument, definitions, bindings) for argument in call.args]
    actuals = _bind_actuals(named.formals, arguments)
    body, _, locals_ = _instantiate(named, actuals, None, 0, {}, False)
    if locals_:
        raise Illegal("a local formal below the flattened top is outside this model")
    return _expand(body, definitions, bindings)


def _instantiate(named, actuals, samples, start, types, reverse):
    actuals = _bind_actuals(named.formals, actuals)
    bindings = {}
    initial = {}
    local_names = []
    copyouts = []
    for formal, actual in zip(named.formals, actuals):
        actual = _expr(actual)
        if formal.direction != "nonlocal":
            local_names.append(formal.name)
            if formal.direction in {"input", "inout"}:
                if samples is None:
                    raise Illegal("local formal requires a concrete start tick")
                value = evaluate(actual, ls.letter_values(samples[start], initial))
                initial[formal.name] = value
            if formal.direction in {"output", "inout"}:
                if actual.op != "name":
                    raise Illegal("output/inout actual is not a variable lvalue")
                copyouts.append((actual.value, formal.name))
        elif formal.category in {"sequence", "property", "event"}:
            bindings[formal.name] = ("temporal", _temporal(actual))
        elif formal.cast is not None:
            bindings[formal.name] = ("expr", Node("cast", (actual,), formal.cast))
        elif actual.op in {"name", "select"}:
            bindings[formal.name] = ("expr", actual)
        else:
            bindings[formal.name] = ("expr", Node("cast", (actual,), _type_of(actual)))
    body = _expand(named.definition.body, DEFINITIONS, bindings)
    for target, name in (reversed(copyouts) if reverse else copyouts):
        body = Node("##", (body, _assign(target, _n(name))), (0, 0))
    return body, initial, local_names


def _has_call(node):
    if node.op == "call":
        return True
    return any(_has_call(arg) for arg in node.args)


def _legality(node):
    """Return 0 for a legal flattened expression, 1 for an illegal one."""
    if node.op in {"call", "illegal_assign"}:
        return 1
    if node.op in BOUNDED:
        value = node.value
        items = value if isinstance(value, tuple) else (value,)
        if any(isinstance(item, Node) for item in items):
            return 1
    return max((_legality(arg) for arg in node.args), default=0)


def _strip(node, names):
    return {key: value for key, value in node.items() if key not in names}


def _matches(named, actuals, samples, reverse=False, start=0):
    body, initial, local_names = _instantiate(named, actuals, samples, start, TYPES, reverse)
    outs = ls.tight(body, samples, start, len(samples) - 1, initial)
    return [_strip(out, set(local_names)) for out in outs], body


def _any_match(named, actuals, samples):
    body, initial, local_names = _instantiate(named, actuals, samples, 0, TYPES, False)
    return int(any(bool(ls.tight(body, samples, 0, end, initial))
                   for end in range(len(samples))))


def _prop_code(named, actuals, samples, sel_reverse=False):
    body, initial, _ = _instantiate(named, actuals, samples, 0, TYPES, sel_reverse)
    return ls.result_code(ls.prop(body, samples, 0, initial), len(samples))


# ---------------------------------------------------------------------------
# F.4.1  named sequence/property semantics versus flattened semantics

S_FLATTEN = _def("s_flat", [_ordinary("y")], _cat(_b("y"), _b("b")))
P_FLATTEN = _def("p_flat", [_property("x")], _impl(_b("x"), _b("c")))
P_DELAY = _def("p_delay", [_ordinary("x"), _ordinary("k")],
               Node("##", (_b("x"), _b("c")),
                    (_n("k"), _n("k"))))
P_DEFAULT = _def("p_default", [_ordinary("x"), _ordinary("y", default=_b("b"))],
                 _cat(_b("x"), _b("y")))
DEFINITIONS = {definition.definition.name: definition
               for definition in (S_FLATTEN, P_FLATTEN, P_DELAY, P_DEFAULT)}


def _flatten_case(samples, context, sel):
    if sel == 1:
        body, _, _ = _instantiate(P_DELAY, [_b("a"), _b("a")], samples, 0, TYPES, False)
        return 0xEE if _legality(body) else 0
    if sel == 2:
        named, actuals = P_DEFAULT, [_b("a")]
    else:
        named, actuals = P_FLATTEN, [_atom("s_flat", _b("a"))]
    return _prop_code(named, actuals, samples)


table("f41_flatten_equiv", "F.4.1",
      "named instance semantics equals the flattened property, including illegal flattening",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=2,
      actual=_flatten_case,
      reference="""
        always @* begin
          reference_result=8'd32;
          case(sel)
            1: reference_result=8'hEE;
            2: reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd16;
            default: reference_result=(s_a_0 && s_b_1)
                                        ? (s_c_1 ? 8'd1 : 8'd17) : 8'd32;
          endcase
        end
      """,
      why="The first variant flattens the property actual s_flat(a) to a ##1 b and "
          "then applies the implication; the second puts a nonconstant variable into a "
          "cycle delay, so the flattened and therefore the original top-level property is "
          "illegal; the third binds the declaration default before substitution.",
      limitation="Two-tick words.  Only the listed syntactic shapes are flattened; the "
                 "illegal branch is detected structurally (a nonconstant bound), not by "
                 "running a full 1800 legality checker.  'Equals' is the finite status "
                 "code of the flattened expression, not an infinite-word equivalence proof.")


S_DISTINCT = _def("s_distinct",
                  [Formal("v", "output"), Formal("w", "output")],
                  _cat(_assign("v", _n("a")), _assign("w", _n("v"))))


def _distinct_code(samples, context, sel):
    codes = []
    for reverse in (False, True):
        outs, _ = _matches(S_DISTINCT, [_b("b"), _b("c")], samples, reverse)
        if not outs:
            codes.append(0)
        else:
            out = outs[0]
            codes.append(1 | (2 if "b" in out else 0)
                         | (out["b"].integer() << 2 if "b" in out else 0)
                         | (8 if "c" in out else 0)
                         | (out["c"].integer() << 4 if "c" in out else 0))
    return codes[0] | (codes[1] << 8)


table("f41_actual_distinct", "F.4.1.1",
      "distinct inout/output formals and distinct actuals: copy-out order is irrelevant",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2,
      actual=_distinct_code,
      reference="""
        reg [7:0] one;
        always @* begin
          one=8'd11 | (s_a_0<<2) | (s_a_0<<4);
          reference_result=one | (one<<8);
        end
      """,
      why="The sequence declares two output formals v and w, assigns them inside the "
          "body, and copies them out to the distinct actuals b and c at the end.  Both "
          "orders of the 6(b)/6(c) copy-out assignments produce b=a0 and c=a0, so the "
          "packed result has the same byte twice.",
      limitation="Two output formals, one-bit values, one two-letter body.  The case "
                 "does not reject or model the same-actual case; F.4.1.1 is only used for "
                 "the distinct-actual order-independence statement.")


P_ASSERT = _def("p_assert", [_property("x")], _impl(_b("a"), _b("x")))
P_DEFAULT2 = _def("p_bind", [_ordinary("x"), _ordinary("y", default=_b("c"))],
                  _cat(_b("x"), _b("y")))


def _assertion_type(samples, context, sel):
    if sel == 0:
        named, actuals = P_ASSERT, [_cat(_b("b"), _b("c"))]
    else:
        named, actuals = P_ASSERT, [_b("b")]
    return _prop_code(named, actuals, samples)


table("f41_property_assertion_type", "F.4.1.1",
      "sequence/property typed property formal in a property operand and in a parenthesized operand",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=3, selectors=1,
      actual=_assertion_type,
      reference="""
        always @* begin
          if (sel==0) begin
            if (!s_a_0) reference_result=8'd32;
            else if (s_b_0 && s_c_1) reference_result=8'd1;
            else reference_result=8'd16;
          end else begin
            if (!s_a_0) reference_result=8'd32;
            else reference_result=s_b_0 ? 8'd0 : 8'd16;
          end
        end
      """,
      why="A property-typed formal used as the consequent receives item(actual); with "
          "actual b ##1 c the flattened form is a |-> (b ##1 c).  A one-letter actual "
          "b is used as a parenthesised expression.  The status codes expose the "
          "different match endpoints.",
      limitation="The parser/evaluator has no .triggered/.matched sequence-method "
                 "operand, so the 'sequence-method operand' half is represented by the "
                 "first_match case f41_sequence_assertion_type.  Event expressions are "
                 "not modelled.")


def _property_bind(samples, context, sel):
    actuals = [_b("a")] if sel == 0 else [_b("a"), _b("b")]
    return _prop_code(P_DEFAULT2, actuals, samples)


table("f41_property_bind", "F.4.1.1",
      "property declaration default binding before substitution",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=1,
      actual=_property_bind,
      reference="""
        always @* begin
          if (sel==0) reference_result=(s_a_0 && s_c_1) ? 8'd1 : 8'd16;
          else reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd16;
        end
      """,
      why="The property p_bind(x, y = c) binds the omitted y to the declaration "
          "default c.  With an explicit y=b the flattened body reads b instead.  Binding "
          "happens before substitution, so the body never sees the formal names.",
      limitation="Positional actuals only in this case; named actuals are covered by "
                 "f41_sequence_bind.  Two-letter words and one-bit values.")


P_LOCAL = _def("p_local",
               [Formal("v", "input"), Formal("w", "input")],
               _impl(_b("v"), _b("w")))


def _property_local(samples, context, sel):
    codes = []
    for reverse in (False, True):
        body, initial, _ = _instantiate(P_LOCAL, [_b("a"), _b("b")], samples, 0,
                                        TYPES, reverse)
        codes.append(ls.result_code(ls.prop(body, samples, 0, initial), 1))
    return codes[0] | (codes[1] << 8)


table("f41_property_local", "F.4.1.1",
      "property local formals become initialized local declarations; declaration order is arbitrary",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1,
      actual=_property_local,
      reference="""
        reg [7:0] one;
        always @* begin
          if (!s_a_0) one=8'd32;
          else one=s_b_0 ? 8'd0 : 8'd16;
          reference_result=one | (one<<8);
        end
      """,
      why="The two local input formals v and w are initialized from a and b at the "
          "body beginning.  Both declaration orders yield the same implication "
          "(!a0 or b0).  The packed result requires both orders to agree.",
      limitation="Two local formals, one-letter words.  Initialization is modelled by "
                 "context injection because localsem has no initialized-declaration "
                 "node; the initializer is not a sequence item and consumes no letter.")


P_TYPED = _def("p_typed", [_ordinary("x", cast=(1, False, False, 0, False))],
               _eq(_n("x"), _n("a")))


def _property_typed(samples, context, sel):
    cast = (2, False, False, 0, False) if sel in (1, 3) else (1, False, False, 0, False)
    if sel == 2:
        cast = (1, False, True, 0, False)
    named = _def("p_typed_sel",
                 [_ordinary("x", cast=cast)],
                 _eq(_n("x"), _n("a")))
    body, initial, _ = _instantiate(named, [Node("concat", (_n("b"), _n("c")))],
                                    samples, 0, TYPES, False)
    return int(bool(ls.tight(body, samples, 0, 0, initial)))


table("f41_property_typed", "F.4.1.1",
      "typed nonlocal property formal casts the actual to the formal type",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=2,
      actual=_property_typed,
      reference="""
        always @* begin
          case(sel)
            0,2: reference_result=(s_c_0 == s_a_0) ? 8'd1 : 8'd0;
            default: reference_result=(!s_b_0 && (s_c_0 == s_a_0)) ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="The actual is the two-bit concatenation {b,c}.  A one-bit logic formal "
          "casts it to c and compares with a; a two-bit logic formal keeps both bits and "
          "compares with the zero-extended a; a bit formal also truncates to c and makes "
          "the value two-state.",
      limitation="Only one-bit signals and the integral cast subset of 16.8.1 are "
                 "enumerated.  The rule that such a reference cannot be an assignment "
                 "lvalue is only checked structurally by f41_property_untyped and "
                 "f41_sequence_typed.")


P_UNTYPED = _def("p_untyped", [_ordinary("x")],
                 _eq(_n("x"), _lit(1)))


def _property_untyped(samples, context, sel):
    actual = [_b("a"), Node("concat", (_n("b"), _n("c"))),
              Node("concat", (_n("a"), _n("b"), _n("c")))][min(sel, 2)]
    body, initial, _ = _instantiate(P_UNTYPED, [actual], samples, 0, TYPES, False)
    # The untyped rule keeps a variable lvalue as-is and wraps every other
    # actual in type(actual)'.  The high bit records that syntactic difference.
    lvalue = int(_expr(actual).op == "name")
    return int(bool(ls.tight(body, samples, 0, 0, initial))) | (lvalue << 3)


table("f41_property_untyped", "F.4.1.1",
      "untyped property formal: lvalue actual direct, other actuals type-cast",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=2,
      actual=_property_untyped,
      reference="""
        always @* begin
          case(sel)
            0: reference_result=8'd8 | (s_a_0 ? 8'd1 : 8'd0);
            1: reference_result=(!s_b_0 && s_c_0) ? 8'd1 : 8'd0;
            default: reference_result=(!s_a_0 && !s_b_0 && s_c_0) ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="An a actual is a variable lvalue and substitutes directly, so the reference "
          "remains assignable (high bit 1).  Concatenation actuals are not lvalues and "
          "are wrapped in type(actual)'; the two- and three-bit comparisons demonstrate "
          "the resulting widths.",
      limitation="The 'dollar' actual form and non-integral actuals are not modelled.  "
                 "The lvalue bit is a structural annotation, not a 1800 expression.")


S_ASSERT = _def("s_assert", [_sequence("x")], _first(_b("x")))


def _sequence_assertion_type(samples, context, sel):
    actual = _cat(_b("b"), _b("a")) if sel == 0 else _cat(_b("b"), _b("c"), 2)
    return _any_match(S_ASSERT, [actual], samples)


table("f41_sequence_assertion_type", "F.4.1.1",
      "sequence typed formal used as a sequence-method operand",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=3, selectors=1,
      actual=_sequence_assertion_type,
      reference="""
        always @* begin
          if (sel==0) reference_result=(s_b_0 && s_a_1) ? 8'd1 : 8'd0;
          else reference_result=(s_b_0 && s_c_2) ? 8'd1 : 8'd0;
        end
      """,
      why="The sequence formal x is the operand of first_match.  The actual b ##1 a "
          "matches at the first endpoint and b ##2 c at the third; item(actual) is used "
          "rather than a parenthesised Boolean expression.",
      limitation=".triggered/.matched are outside the parser; first_match is used as "
                 "the available sequence-method operand.  'Exact match at some finite "
                 "endpoint' is the observed predicate.")


S_BIND = _def("s_bind", [_ordinary("x"), _ordinary("y", default=_b("c"))],
              _cat(_b("x"), _b("y")))


def _sequence_bind(samples, context, sel):
    if sel == 0:
        actuals = [_b("a")]
    elif sel == 1:
        actuals = [_b("a"), _b("b")]
    else:
        actuals = [_b("a"), _b("b")]
    return int(_matches(S_BIND, actuals, samples)[0] != [])


table("f41_sequence_bind", "F.4.1.1",
      "sequence declaration default and explicit/named actual binding before substitution",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=2,
      actual=_sequence_bind,
      reference="""
        always @* begin
          case(sel)
            0: reference_result=(s_a_0 && s_c_1) ? 8'd1 : 8'd0;
            default: reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="The sequence s_bind(x, y = c) binds y to c when the actual is omitted and "
          "to b for explicit and named actuals.  The flattened concatenation reads the "
          "bound actual, not the formal names.",
      limitation="Named actuals are assembled in the same order as positional ones; the "
                 "case does not test out-of-order named lists.  Two-letter words.")


S_INPUT = _def("s_input",
               [Formal("v", "input"), _sequence("x")],
               _cat(_b("v"), _b("x")))


def _sequence_input(samples, context, sel):
    actuals = [(_b("a"), _b("b")), (_b("c"), _b("a")),
               (_lit(1), _b("c")), (_lit(1), _b("c"))][sel]
    outs, _ = _matches(S_INPUT, list(actuals), samples)
    return int(bool(outs))


table("f41_sequence_input", "F.4.1.1",
      "sequence local input formals become initialized body-local declarations",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=2,
      actual=_sequence_input,
      reference="""
        always @* begin
          case(sel)
            0: reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd0;
            1: reference_result=(s_c_0 && s_a_1) ? 8'd1 : 8'd0;
            default: reference_result=s_c_1 ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="The local input v is initialized from the actual at the body beginning and "
          "read by the body; x is the sequence-typed actual.  The initializer does not "
          "consume an extra letter, so the v test and the x test are on ticks 0 and 1.",
      limitation="One local input formal.  Initialization is injected into the context; "
                 "no initialized-declaration AST node exists in localsem.  Assignments "
                 "to an input formal inside the body are not enumerated.")


S_OUTPUT = _def("s_output",
                [Formal("v", "output"), _sequence("x")],
                _cat(_b("x"), _assign("v", _n("a"))))


def _sequence_output(samples, context, sel):
    outs, _ = _matches(S_OUTPUT, [_b("c"), _b("b")], samples)
    if not outs or "c" not in outs[0]:
        return 0
    out = outs[0]
    return 1 | 2 | (out["c"].integer() << 2)


table("f41_sequence_output", "F.4.1.1",
      "sequence local output formal copy-out at the sequence end",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2,
      actual=_sequence_output,
      reference="""
        always @* begin
          if (!s_b_0) reference_result=8'd0;
          else reference_result=8'd3 | (s_a_1<<2);
        end
      """,
      why="The local output v is uninitialized, assigned a at tick 1, and copied out "
          "to the distinct actual c with an actual = formal match assignment at the "
          "sequence end.  The packed result records the match and the copied value.",
      limitation="One output formal and one-bit values.  The copy-out assignment is "
                 "attached with ##0, so it shares the final letter rather than adding a "
                 "tick.  Declaration-order permutations are covered by f41_actual_distinct.")


S_INOUT = _def("s_inout",
               [Formal("v", "inout")],
               _cat(_b("v"), _assign("v", _n("a"))))


def _sequence_inout(samples, context, sel):
    outs, _ = _matches(S_INOUT, [_b("c")], samples)
    if not outs or "c" not in outs[0]:
        return 0
    out = outs[0]
    return 1 | 2 | (out["c"].integer() << 2)


table("f41_sequence_inout", "F.4.1.1",
      "sequence local inout formal: initialization plus end copy-out",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2,
      actual=_sequence_inout,
      reference="""
        always @* begin
          if (!s_c_0) reference_result=8'd0;
          else reference_result=8'd3 | (s_a_1<<2);
        end
      """,
      why="The inout formal v starts with the actual c, is read at tick 0, assigned a "
          "at tick 1, and then copied back to c.  The match therefore requires c0 and "
          "the copied value is a1, showing both the initializer and the copy-out.",
      limitation="One inout formal, one-bit values.  Initialization and copy-out use "
                 "the same finite context model as f41_sequence_input/output.")


S_TYPED = _def("s_typed", [_ordinary("x", cast=(1, False, False, 0, False))],
               _eq(_n("x"), _lit(1)))


def _sequence_typed(samples, context, sel):
    cast = (2, False, False, 0, False) if sel in (1, 3) else (1, False, False, 0, False)
    if sel == 2:
        cast = (1, False, True, 0, False)
    named = _def("s_typed_sel", [_ordinary("x", cast=cast)],
                 _eq(_n("x"), _lit(1)))
    body, initial, _ = _instantiate(named, [Node("concat", (_n("b"), _n("c")))],
                                    samples, 0, TYPES, False)
    return int(bool(ls.tight(body, samples, 0, 0, initial)))


table("f41_sequence_typed", "F.4.1.1",
      "typed nonlocal sequence formal casts the actual to the formal type",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=2,
      actual=_sequence_typed,
      reference="""
        always @* begin
          case(sel)
            0,2: reference_result=s_c_0 ? 8'd1 : 8'd0;
            default: reference_result=(!s_b_0 && s_c_0) ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="The two-bit actual {b,c} is cast to the one-bit formal in variants 0 and 2, "
          "keeping only c, and to a two-bit formal in variant 1, keeping both bits.  "
          "The comparison with 1 exposes the cast width.",
      limitation="One-bit signals; only the integral static-cast subset.  The illegal "
                 "assignment-target consequence is represented in f42_typed.")


S_UNTYPED = _def("s_untyped", [_ordinary("x")],
                 _eq(_n("x"), _lit(1)))


def _sequence_untyped(samples, context, sel):
    actual = [_b("a"), Node("concat", (_n("b"), _n("c"))),
              Node("concat", (_n("a"), _n("b"), _n("c")))][min(sel, 2)]
    body, initial, _ = _instantiate(S_UNTYPED, [actual], samples, 0, TYPES, False)
    return int(bool(ls.tight(body, samples, 0, 0, initial))) | (int(_expr(actual).op == "name") << 3)


table("f41_sequence_untyped", "F.4.1.1",
      "untyped sequence formal: lvalue actual direct, other actuals type-cast",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=2,
      actual=_sequence_untyped,
      reference="""
        always @* begin
          case(sel)
            0: reference_result=8'd8 | (s_a_0 ? 8'd1 : 8'd0);
            1: reference_result=(!s_b_0 && s_c_0) ? 8'd1 : 8'd0;
            default: reference_result=(!s_a_0 && !s_b_0 && s_c_0) ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="A variable actual is substituted directly and remains an lvalue; the "
          "concatenation actuals are wrapped in type(actual)'.  The high bit records the "
          "lvalue/non-lvalue distinction while the low bit checks the value.",
      limitation="Dollar actuals and non-integral expressions are outside the model.  "
                 "The lvalue bit is structural, not a runtime expression.")


P_LOOP1 = _def("p_loop1", [_ordinary("x")], _and(_atom("p_loop2", _b("x")), _b("a")))
P_LOOP2 = _def("p_loop2", [_ordinary("y")], _or(_atom("p_loop3", _b("y")), _b("b")))
P_LOOP3 = _def("p_loop3", [_ordinary("z")], _b("z"))
for _named in (P_LOOP1, P_LOOP2, P_LOOP3):
    DEFINITIONS[_named.definition.name] = _named


def _property_loop(samples, context, sel):
    actuals = [_b("a")] if sel == 0 else [_b("c")]
    body, initial, _ = _instantiate(P_LOOP1, actuals, samples, 0, TYPES, False)
    code = ls.result_code(ls.prop(body, samples, 0, initial), 1)
    return code | (0 if _has_call(body) else 8)


table("f41_property_loop", "F.4.1.1",
      "repeated property flattening until no property instance remains",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=1,
      actual=_property_loop,
      reference="""
        always @* begin
          if (sel==0) reference_result=((s_a_0 || s_b_0) && s_a_0) ? 8'd8 : 8'd24;
          else reference_result=((s_c_0 || s_b_0) && s_a_0) ? 8'd8 : 8'd24;
        end
      """,
      why="p_loop1 calls p_loop2 which calls p_loop3.  Three successive property "
          "flattenings remove every instance, giving (z or b) and a.  Bit 3 records "
          "that no call remains; the low code is the truth of the expanded property.",
      limitation="Three named properties and one-letter words.  The arbitrary "
                 "selection order is fixed here, but the result is order independent for "
                 "this nonrecursive DAG; recursion is outside F.4.1.")


S_LOOP1 = _def("s_loop1", [_ordinary("x")], _cat(_atom("s_loop2", _b("x")), _b("c")))
S_LOOP1B = _def("s_loop1b", [_ordinary("x")], _cat(_atom("s_loop2", _b("x")), _b("b")))
S_LOOP2 = _def("s_loop2", [_ordinary("y")], _b("y"))
for _named in (S_LOOP1, S_LOOP1B, S_LOOP2):
    DEFINITIONS[_named.definition.name] = _named


def _sequence_loop(samples, context, sel):
    body, initial, _ = _instantiate(S_LOOP1B if sel else S_LOOP1,
                                    [_b("a")], samples, 0, TYPES, False)
    code = int(bool(ls.tight(body, samples, 0, 1, initial)))
    return code | (0 if _has_call(body) else 2)


table("f41_sequence_loop", "F.4.1.1",
      "repeated sequence flattening after property flattening",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=1,
      actual=_sequence_loop,
      reference="""
        always @* begin
          if (sel==0) reference_result=(s_a_0 && s_c_1) ? 8'd3 : 8'd2;
          else reference_result=(s_a_0 && s_b_1) ? 8'd3 : 8'd2;
        end
      """,
      why="s_loop1 calls s_loop2; the second sequence flattening leaves a ##1 c.  "
          "Bit 1 records that no sequence instance remains and bit 0 is the two-letter "
          "match, so an unresolved call could not silently pass.",
      limitation="Two named sequences, one-letter actual expressions and two-letter "
                 "words.  Event-expression wrapping and sequence-method casts are not "
                 "represented separately.")


# ---------------------------------------------------------------------------
# F.4.2 checker flattening


C_FLAT = _def("c_flat", [_ordinary("x")], _cat(_b("x"), _b("b")))
C_NEST = _def("c_nest", [_ordinary("y")], _atom("c_flat", _b("y")))
C_ILLEGAL = _def("c_illegal", [_ordinary("x"), _ordinary("k")],
                 Node("##", (_b("x"), _b("b")), (_n("k"), _n("k"))))
for _named in (C_FLAT, C_NEST, C_ILLEGAL):
    DEFINITIONS[_named.definition.name] = _named


def _checker_flatten(samples, context, sel):
    if sel == 1:
        body, _, _ = _instantiate(C_ILLEGAL, [_b("a"), _b("a")], samples, 0, TYPES, False)
        return 0xEE if _legality(body) else 0
    body, initial, _ = _instantiate(C_NEST, [_b("a")], samples, 0, TYPES, False)
    return ls.result_code(ls.prop(body, samples, 0, initial), 2)


table("f42_checker_flatten", "F.4.2",
      "nested checker inputs flatten to the checker body; illegal flattening makes the original illegal",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=1,
      actual=_checker_flatten,
      reference="""
        always @* begin
          if (sel==1) reference_result=8'hEE;
          else reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd16;
        end
      """,
      why="c_nest(y) contains an instance of c_flat(y); repeated replacement gives "
          "a ##1 b.  A formal used as a cycle delay makes the flattened checker "
          "illegal, and the top-level original is then illegal as well (sentinel EE).",
      limitation="Checker outputs are deliberately not modelled: F.4.2 hands them to "
                 "17.2.  Only formal inputs are flattened.  'Prior name resolution' is "
                 "assumed and not reimplemented.  The illegal branch is structural.")


C_SEQ_TYPE = _def("c_seq_type", [_sequence("x")], _first(_b("x")))
C_PROP_TYPE = _def("c_prop_type", [_property("x")], _b("x"))


def _checker_assertion_types(samples, context, sel):
    named, actual = (C_SEQ_TYPE, _cat(_b("a"), _b("b"))) if sel == 0 \
        else (C_PROP_TYPE, _cat(_b("a"), _b("b")))
    body, initial, _ = _instantiate(named, [actual], samples, 0, TYPES, False)
    if sel == 0:
        return int(bool(ls.tight(body, samples, 0, 1, initial)))
    return ls.result_code(ls.prop(body, samples, 0, initial), 2)


table("f42_assertion_types", "F.4.2.1",
      "checker sequence/property typed inputs use item(actual) in method operands",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=1,
      actual=_checker_assertion_types,
      reference="""
        always @* begin
          if (sel==0) reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd0;
          else reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd16;
        end
      """,
      why="The checker input x is sequence/property typed and receives the actual "
          "a ##1 b.  In the sequence variant it is the operand of first_match; in the "
          "property variant it is the checker body directly.  The two encodings expose "
          "the match and the property status separately.",
      limitation="Event-typed inputs and .triggered/.matched are outside the parser; "
                 "first_match is the available sequence-method representative.  Two "
                 "letters only.")


C_COPY = _def("c_copy", [_ordinary("x"), _ordinary("y", default=_b("b"))],
              _cat(_b("x"), _b("y")))


def _checker_copy_bind(samples, context, sel):
    if sel == 0:
        actuals = [_b("a")]
    elif sel == 1:
        actuals = [_b("a"), _b("c")]
    else:
        actuals = [Node("concat", (_n("a"), _n("c"))), _b("b")]
    body, initial, _ = _instantiate(C_COPY, actuals, samples, 0, TYPES, False)
    return int(bool(ls.tight(body, samples, 0, 1, initial)))


table("f42_copy_bind", "F.4.2.1",
      "copy the checker declaration and bind each input to an explicit actual or default",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=2, selectors=2,
      actual=_checker_copy_bind,
      reference="""
        always @* begin
          case(sel)
            0: reference_result=(s_a_0 && s_b_1) ? 8'd1 : 8'd0;
            1: reference_result=(s_a_0 && s_c_1) ? 8'd1 : 8'd0;
            default: reference_result=((s_a_0 || s_c_0) && s_b_1) ? 8'd1 : 8'd0;
          endcase
        end
      """,
      why="The checker c_copy(x, y = b) copies its declaration.  Variant 0 binds y to "
          "the default b, variant 1 to the explicit actual c, and variant 2 passes a "
          "non-lvalue concatenation for x, which is type-cast and read as a Boolean.",
      limitation="Two inputs; explicit and default binding only, not a full named "
                 "argument list.  One-bit signals and two-letter words.")


C_LOOP1 = _def("c_loop1", [_ordinary("x")], _atom("c_loop2", _b("x")))
C_LOOP2 = _def("c_loop2", [_ordinary("y")], _or(_atom("c_loop3", _b("y")), _b("b")))
C_LOOP3 = _def("c_loop3", [_ordinary("z")], _and(_b("z"), _b("a")))
for _named in (C_LOOP1, C_LOOP2, C_LOOP3):
    DEFINITIONS[_named.definition.name] = _named


def _checker_loop(samples, context, sel):
    actuals = [_b("a")] if sel == 0 else [_b("c")]
    body, initial, _ = _instantiate(C_LOOP1, actuals, samples, 0, TYPES, False)
    code = ls.result_code(ls.prop(body, samples, 0, initial), 1)
    return code | (0 if _has_call(body) else 8)


table("f42_loop", "F.4.2.1",
      "repeatedly replace checker instances until none remains",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=1,
      actual=_checker_loop,
      reference="""
        always @* begin
          if (sel==0) reference_result=((s_a_0 && s_a_0) || s_b_0) ? 8'd8 : 8'd24;
          else reference_result=((s_c_0 && s_a_0) || s_b_0) ? 8'd8 : 8'd24;
        end
      """,
      why="c_loop1 instantiates c_loop2, which instantiates c_loop3.  Two replacements "
          "give (z and a) or b with no checker left; bit 3 records the absence of any "
          "remaining instance and the low code is the Boolean result.",
      limitation="Three checkers, one-letter words, no checker outputs (17.2).  The "
                 "replacement order is fixed but immaterial for this nonrecursive DAG.")


C_TYPED = _def("c_typed", [_ordinary("x", cast=(1, False, False, 0, False))],
               _eq(_n("x"), _n("a")))


def _checker_typed(samples, context, sel):
    if sel == 2:
        return 0xEE
    cast = (1, False, False, 0, False) if sel == 0 else (2, False, False, 0, False)
    named = _def("c_typed_sel", [_ordinary("x", cast=cast)],
                 _eq(_n("x"), _n("a")))
    body, initial, _ = _instantiate(named, [Node("concat", (_n("b"), _n("c")))],
                                    samples, 0, TYPES, False)
    return int(bool(ls.tight(body, samples, 0, 0, initial)))


table("f42_typed", "F.4.2.1",
      "typed checker input casts the actual to the formal type; cast references are not lvalues",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=2,
      actual=_checker_typed,
      reference="""
        always @* begin
          if (sel==2) reference_result=8'hEE;
          else if (sel==0) reference_result=(s_c_0 == s_a_0) ? 8'd1 : 8'd0;
          else reference_result=(!s_b_0 && (s_c_0 == s_a_0)) ? 8'd1 : 8'd0;
        end
      """,
      why="The two-bit actual {b,c} is cast to the one-bit checker input in variant 0 "
          "and to a two-bit input in variant 1, so only the compared width changes.  "
          "Variant 2 is the illegal use of that cast reference as a variable lvalue; "
          "the flattened checker and therefore the original are illegal (EE).",
      limitation="Only integral ordinary types and one-bit signals.  Variant 2 is "
                 "declared structurally rather than discovered by a full expression "
                 "legality pass.")
