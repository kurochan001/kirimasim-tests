"""Formal cases for F.4 item and F.4.3 declaration-assignment rewriting.

The F.4.3 clause is a rewriting definition, not a simulator rule.  Each table
here models one equation of that definition on a finite syntax fragment:

* ``admits_empty``       the structural emptiness relation of F.4.3;
* ``empty_tight``        tight local satisfaction of the empty word (F.5.5),
                         used as the semantic reading of misleading names;
* ``push``/``fuse``      the pending-declaration-assignment list pushed into
                         properties and sequences, with ``(1, A)`` alignment
                         written as a fused ``##0`` chain;
* ``pack``               a single tight output context as presence/value bits.

The ``actual`` side runs those Python models.  The ``reference`` RTL is
written independently from the clause for each syntax variant and never calls
the parser, the derivative engine or the evaluator.  Every table enumerates
all input words of its finite alphabet in one combinational case statement, so
a PASS is an exhaustive statement about that variant list and word length, not
about the whole SystemVerilog language.
"""

from . import localsem as ls
from .f4_common import table
from .parser import Node, Spec, Unsupported, parse_sequence, parse_spec
from .values import evaluate


# ---------------------------------------------------------------------------
# helpers


def seq(text):
    return parse_sequence(text)


def variants(*texts):
    return [seq(text) for text in texts]


def bool_literal(value):
    return Node("bool", (Node("literal", value=str(value)),))


def null_repetition():
    """(1)[*0]: the sequence that matches the empty word with no effects."""
    return Node("repeat", (bool_literal(1),), (0, 0))


def assign(name, text):
    node = text if isinstance(text, Node) else seq(text)
    if node.op == "bool":
        node = node.args[0]
    return Node("assign", (node,), name)


def expr(text):
    """A Boolean expression node, unwrapped from the parser's bool wrapper."""
    node = seq(text)
    return node.args[0] if node.op == "bool" else node


def fuse(items, body):
    """Aligned (1, assignments) fused with the body (F.4.3 push-sequence).

    Each pending assignment is a one-letter sequence; ``##0`` fuses them so the
    whole list executes on the body's first letter in list order.
    """
    for name, expression in reversed(list(items)):
        body = Node("##", (assign(name, expression), body), (0, 0))
    return body


def fuse_anchor(items):
    """(1, assignments): the aligned one-letter prefix of a property."""
    return fuse(items, bool_literal(1))


def pack(contexts, names, base=1):
    """Pack at most one tight output context into presence/value bits."""
    if not contexts:
        return 0
    context = contexts[0]
    code = base
    for index, name in enumerate(names):
        if name in context:
            code |= 1 << (2 * index + 1)
            code |= context[name].integer() << (2 * index + 2)
    return code


def tight_code(node, samples, names):
    """Union of the packed output contexts over all endpoints of the word."""
    code = 0
    for end in range(len(samples)):
        code |= pack(ls.tight(node, samples, 0, end, {}), names)
    return code


def sel_case(constants, width=8):
    body = " ".join(f"{i}: reference_result={width}'d{value};"
                    for i, value in enumerate(constants))
    return f"always @* begin reference_result=0; case(sel) {body} endcase end"


# ---------------------------------------------------------------------------
# F.4.3 admits_empty and the empty-word reading


def admits_empty(node):
    """Structural emptiness relation of F.4.3 on the parsed syntax."""
    op, args = node.op, node.args
    if op in {"bool", "assign"}:
        return False
    if op in {"sequence", "decl", "first_match"}:
        return admits_empty(args[0])
    if op == "repeat":
        lo, hi = node.value
        return True if lo == 0 or hi == 0 else admits_empty(args[0])
    if op == "##":
        lo, hi = node.value
        if (lo, hi) == (0, 0):
            return False                      # fusion never admits empty
        return admits_empty(args[0]) and admits_empty(args[1])
    if op == "or":
        return admits_empty(args[0]) or admits_empty(args[1])
    if op in {"intersect", "and"}:
        return admits_empty(args[0]) and admits_empty(args[1])
    if op == "delay":
        return node.value[0] == 0 and admits_empty(args[0])
    raise Unsupported(f"admits_empty does not cover {op}")


def _merge(left, right):
    result = dict(left)
    result.update(right)
    return result


def _unique(contexts):
    return ls._unique(contexts)


def empty_tight(node, context=None):
    """Tight matches of ``node`` on the empty word (F.5.5 restricted)."""
    context = {} if context is None else dict(context)
    op, args = node.op, node.args
    if op in {"bool", "assign"}:
        return []
    if op == "sequence":
        return empty_tight(args[0], context)
    if op == "decl":
        name = node.value
        outer = context.get(name)
        inner = dict(context)
        inner.pop(name, None)
        results = []
        for outgoing in empty_tight(args[0], inner):
            outgoing = dict(outgoing)
            outgoing.pop(name, None)
            if outer is not None:
                outgoing[name] = outer
            results.append(outgoing)
        return _unique(results)
    if op == "first_match":
        return empty_tight(args[0], context)
    if op == "repeat":
        lo, hi = node.value
        if lo == 0:
            return [dict(context)]
        return empty_tight(args[0], context)
    if op == "##":
        lo, hi = node.value
        if (lo, hi) == (0, 0):
            return []
        results = []
        for left in empty_tight(args[0], context):
            results.extend(empty_tight(args[1], left))
        return _unique(results)
    if op == "or":
        allowed = ls.flow(set(context), node)
        results = empty_tight(args[0], context) + empty_tight(args[1], context)
        return _unique(ls.restrict(outgoing, allowed) for outgoing in results)
    if op in {"intersect", "and"}:
        allowed = ls.flow(set(context), node)
        left_names = ls.flow(set(context), args[0]) - ls.block(node) - ls.sample(args[1])
        right_names = ls.flow(set(context), args[1]) - ls.block(node) - ls.sample(args[0])
        results = []
        for left in empty_tight(args[0], context):
            for right in empty_tight(args[1], context):
                results.append(ls.restrict(_merge(ls.restrict(left, left_names),
                                                  ls.restrict(right, right_names)), allowed))
        return _unique(results)
    if op == "delay":
        return empty_tight(args[0], context) if node.value[0] == 0 else []
    raise Unsupported(f"empty_tight does not cover {op}")


def empty_contexts(node):
    return empty_tight(node, {})


# ---------------------------------------------------------------------------
# F.4.3 push


def push_seq(items, node):
    """F.4.3 PUSH-SEQUENCE: an empty list leaves a sequence untouched."""
    return node if not items else fuse(items, node)


def push_prop(items, node):
    """F.4.3 push over the property fragment used by the cases."""
    op, args = node.op, node.args
    if op == "initdecl":
        name, expression = node.value
        return Node("decl", (push_prop(list(items) + [(name, expression)], args[0]),), name)
    if op == "decl":
        return Node("decl", (push_prop(items, args[0]),), node.value)
    if op == "clock":
        return Node("clock", (push_prop(items, args[0]),), node.value)
    if op == "disable":
        return Node("disable", (push_prop(items, args[0]),), node.value)
    if op == "not":
        return Node("not", (push_prop(items, args[0]),))
    if op in {"or", "and"}:
        return Node(op, (push_prop(items, args[0]), push_prop(items, args[1])))
    if op == "if":
        condition = args[0]
        body = Node("if", (condition, push_prop([], args[1]), push_prop([], args[2])))
        return body if not items else Node("|->", (fuse_anchor(items), body))
    if op == "|->":
        body = Node("|->", (push_prop([], args[0]), push_prop([], args[1])))
        return body if not items else Node("|->", (fuse_anchor(items), body))
    if op == "|=>":
        main = Node("|=>", (push_prop(items, args[0]), push_prop([], args[1])))
        if admits_empty(args[0]):
            return Node("and", (main, push_prop(items, args[1])))
        return main
    return push_seq(items, node)


def disable_code(node, word, start=0):
    """Approximation of F.5.6.1 disable iff used by the wrapper case."""
    expression, body = node.value, node.args[0]
    result = ls.prop(body, word, start, {})
    for tick in range(len(word)):
        truth = evaluate(expression, ls.letter_values(word[tick], {}))
        if truth.assertion():
            if result.at is not None and result.at < tick:
                return ls.result_code(result, len(word))
            return (5 << 4) | tick
    return ls.result_code(result, len(word))


def prop_code(node, word, start=0, context=None):
    """Top-level result code with the local wrapper nodes of this module."""
    context = {} if context is None else context
    if node.op == "disable":
        return disable_code(node, word, start)
    if node.op == "clock":
        return prop_code(node.args[0], word, start, context)
    return ls.result_code(ls.prop(node, word, start, context), len(word))


def spec_prop_code(spec, word):
    extra = 1 << 8 if spec.clock is not None else 0
    node = spec.body
    if spec.disable is not None:
        node = Node("disable", (node,), spec.disable)
    return prop_code(node, word, 0) | extra


# ---------------------------------------------------------------------------
# F.4 ITEM and ITEM-RESTRICTIONS


ITEM_EXPRESSIONS = variants("(a & b)", "(a | !b)", "(a == b)", "(a ^ b)")


def item_permitted(kind, operation):
    """Operations an item(e) of the given expression type permits (F.4).

    ``kind`` 0 is an undefined type, 1 an integral/Boolean expression, 2 a
    sequence expression and 3 a property or top-level property expression.
    ``operation`` 0 reads the value, 1 uses the operand as a named
    sequence/property instance, 2 applies a sequence method and 3 uses the
    result as a top-level property of an assertion statement.
    """
    if kind == 0:
        return 0                     # ITEM-RESTRICTIONS: nothing is added
    if kind == 1:
        return 1 if operation == 0 else 0
    if kind == 2:
        return 1 if operation in {1, 2} else 0
    return 1 if operation in {1, 3} else 0


def item_code(samples, context, sel, values):
    letter = samples[0]
    # F.4: item(e) denotes e, so the wrapper is transparent to the value.
    expression = ITEM_EXPRESSIONS[sel]
    expression = expression.args[0] if expression.op == "bool" else expression
    wrapped = Node("item", (expression,))
    value = evaluate(wrapped.args[0], letter).integer() & 1
    permitted = item_permitted(values["T"], values["O"])
    return value | (permitted << 1)


table("f4_item", "F.4", "item(e) value and permitted operations",
      signals=[("a", 1), ("b", 1)], horizon=1,
      inputs=[("T", 2), ("O", 2)], selectors=2,
      actual=item_code,
      reference="""
        always @* begin
          case(sel)
            0: reference_result = (s_a_0 & s_b_0);
            1: reference_result = (s_a_0 | !s_b_0);
            2: reference_result = (s_a_0 == s_b_0);
            default: reference_result = (s_a_0 ^ s_b_0);
          endcase
          case(i_T)
            0: ;                                  // undefined type: no operation
            1: reference_result = reference_result | ((i_O==0)<<1);
            2: reference_result = reference_result | (((i_O==1)||(i_O==2))<<1);
            default: reference_result = reference_result | (((i_O==1)||(i_O==3))<<1);
          endcase
        end
      """,
      why="item(e) has the value of e for every input word (first result bit) and permits "
          "exactly the operations of a same-typed named item: value read for an integral "
          "expression, named-instance use and sequence method for a sequence, named-instance "
          "use and assertion-statement use for a property.  An undefined type permits no "
          "operation at all.",
      limitation="item is a rewriting device, not a language function: the case models value "
          "preservation on four Boolean expressions and a four-by-four operation/type lattice, "
          "not the full expression grammar or name resolution.")


# ---------------------------------------------------------------------------
# F.4.3 empty atoms / concat / wrappers / or-intersect / meaning


EMPTY_ATOMS = variants("a", "(v=a)", "a[*0]", "b", "(w=b)", "a[*1:3]",
                       "a[*0:1]", "b[*0]")


def atoms_code(samples, context, sel):
    node = EMPTY_ATOMS[sel]
    admitted = int(admits_empty(node))
    letter = int(bool(ls.tight(node, samples, 0, 0, {})))
    empty = int(bool(empty_contexts(node)))
    return admitted | (letter << 1) | (empty << 2)


table("f43_empty_atoms", "F.4.3", "admits_empty of Boolean, assignment and repetition",
      signals=[("a", 1), ("b", 1)], horizon=1, selectors=3,
      actual=atoms_code,
      reference="""
        always @* begin
          case(sel)
            0: reference_result = (s_a_0<<1);                 // a
            1: reference_result = 2;                          // (v=a)
            2: reference_result = 1 | 4;                      // a[*0]
            3: reference_result = (s_b_0<<1);                 // b
            4: reference_result = 2;                          // (w=b)
            5: reference_result = (s_a_0<<1);                 // a[*1:3]
            6: reference_result = 1 | (s_a_0<<1) | 4;         // a[*0:1]
            default: reference_result = 1 | 4;                // b[*0]
          endcase
        end
      """,
      why="A Boolean and a local sampling assignment never admit an empty match but always match "
          "one letter; a positive repetition matches a letter iff its operand does; a null "
          "repetition admits empty and matches no letter, and an optional repetition admits empty "
          "and matches a letter iff its operand does.",
      limitation="Two Boolean operands and one letter; unbounded repetition and nested "
          "repetition bounds are not varied.")


EMPTY_CONCAT = variants("a ##1 b", "a[*0] ##1 b[*0]", "a[*0] ##1 b", "a ##1 b[*0]",
                        "a[*0] ##0 b[*0]", "a ##0 b", "(v=a) ##1 (w=b)",
                        "(a ##1 b[*0]) ##1 a[*0]")
EMPTY_CONCAT_TABLE = [0, 3, 0, 0, 0, 0, 0, 0]


def concat_code(samples, context, sel):
    node = EMPTY_CONCAT[sel]
    return int(admits_empty(node)) | (int(bool(empty_contexts(node))) << 1)


table("f43_empty_concat", "F.4.3", "admits_empty of concatenation and fusion",
      signals=[("a", 1), ("b", 1)], selectors=3,
      actual=concat_code,
      reference=sel_case(EMPTY_CONCAT_TABLE),
      why="r1 ##m r2 admits empty exactly when both operands do, while the fusion r1 ##0 r2 "
          "never admits empty.  Variant 1 is the only one whose two operands both admit empty; "
          "the fusion variants therefore report false even when both sides are null.",
      limitation="Word independent: the requirement is a property of syntax.  Repetition bounds "
          "and multi-way concatenation are not enumerated.")


WRAPPER_SPECS = [parse_spec(text) for text in [
    "(v; a)", "(v; a[*0])", "(v; (w; a[*0]))", "((a[*0]))", "first_match(a[*0])",
    "first_match(a)", "a[*1:$]", "(a[*0])[*1:$]", "@(posedge clk) (a[*0])",
    "@(posedge clk) (a ##1 b)"]]
WRAPPER_TABLE = [0, 3, 3, 3, 3, 0, 0, 3, 7, 4, 0, 3, 3, 3, 3, 0]


def wrapper_code(samples, context, sel):
    spec = WRAPPER_SPECS[sel % len(WRAPPER_SPECS)]
    return (int(admits_empty(spec.body))
            | (int(bool(empty_contexts(spec.body))) << 1)
            | (int(spec.clock is not None) << 2))


table("f43_empty_wrappers", "F.4.3", "admits_empty through declarations, parentheses, "
      "first_match, positive repetition and clock",
      signals=[("a", 1), ("b", 1)], selectors=4,
      actual=wrapper_code,
      reference=sel_case(WRAPPER_TABLE),
      why="A local declaration, parentheses, first_match, a positive unbounded repetition and an "
          "explicit leading clock all preserve admits_empty of the operand; the clock bit makes "
          "the clocked variants visible, and the unclocked first_match(a) and a[*1:$] keep the "
          "operand's false.",
      limitation="Parentheses are dropped by the parser, so their variant only checks that the "
          "source form parses to the same node.  One leading clock and one nesting level.")


EMPTY_OR_INTERSECT = variants(
    "a[*0] or b", "a or b", "a[*0] or b[*0]", "a or b[*0]",
    "a[*0] intersect b", "a intersect b[*0]",
    "a[*0] intersect b[*0]", "a intersect b")


def or_intersect_code(samples, context, sel):
    node = EMPTY_OR_INTERSECT[sel]
    return int(admits_empty(node)) | (int(bool(empty_contexts(node))) << 1)


table("f43_empty_or_intersect", "F.4.3", "admits_empty of or and intersect",
      signals=[("a", 1), ("b", 1)], selectors=3,
      actual=or_intersect_code,
      reference=sel_case([3, 0, 3, 3, 0, 0, 3, 0]),
      why="or admits empty exactly when one operand does and intersect exactly when both do; the "
          "third and fourth variants exercise the nullable side of each operator.",
      limitation="Word independent.  The property-level or/and and the sequence-level and are not "
          "separately enumerated; intersect is the representative conjunctive operator.")


MEANING_SPECS = [parse_spec(text) for text in [
    "a[*0]", "(v=a)", "(v; a[*0])", "@(posedge clk) (a[*0])", "a[*0] ##1 b[*0]"]]


def meaning_code(samples, context, sel):
    admitted = 0
    tight = 0
    for index, spec in enumerate(MEANING_SPECS):
        admitted |= int(admits_empty(spec.body)) << index
        tight |= int(bool(empty_contexts(spec.body))) << index
    return admitted | (tight << len(MEANING_SPECS))


table("f43_empty_meaning", "F.4.3", "admits_empty equals empty-word tight satisfaction",
      selectors=0,
      actual=meaning_code,
      reference="""
        always @* begin
          // variants: a[*0], (v=a), (v; a[*0]), @(posedge clk) (a[*0]), a[*0] ##1 b[*0]
          reference_result = 32'd957;   // 29 | (29<<5)
        end
      """,
      why="The left half of the result is the structural admits_empty of five variants and the "
          "right half is their tight satisfaction of the empty word after the declaration-"
          "assignment and clock rewriting; both halves are 0b11101, so the two readings agree on "
          "null repetition, assignment, declaration, clock wrapper and the concatenation of two "
          "null repetitions.",
      limitation="Word independent by construction.  Symbolic-word tight satisfaction cannot "
          "express the empty word, so the semantic half uses the empty-word restriction of F.5.5 "
          "implemented in this module, not the derivative engine.")


# ---------------------------------------------------------------------------
# F.4.3 kappa and the rewriting order


KAPPA_SPECS = [parse_spec("a[*0]"), parse_spec("@(posedge clk) a[*0]")]


def kappa_code(samples, context, sel, values):
    spec = KAPPA_SPECS[sel]
    inherited = values["I"]
    if spec.clock is None:
        leading = 1 if inherited else 0
    else:
        leading = 2
    return leading | (int(admits_empty(spec.body)) << 2)


table("f43_kappa", "F.4.3", "kappa(r) and the semantic leading clock",
      signals=[("a", 1)], horizon=1, inputs=[("I", 1)], selectors=1,
      actual=kappa_code,
      reference="""
        always @* begin
          if (sel==0) reference_result = (i_I ? 1 : 0) | 4;   // empty kappa: inherited clock
          else reference_result = 2 | 4;                     // explicit leading clock
        end
      """,
      why="kappa(r) is the empty syntax when r has no leading clock control, so the semantic "
          "leading clock is inherited from the enclosing property (1) or absent when there is "
          "nothing to inherit (0); an explicit clock control selects that clock (2).  kappa does "
          "not change admits_empty, which stays true for the null repetition.",
      limitation="One scalar clock and one nesting level: uniqueness of the semantic leading "
          "clock is structural here because the parser rejects multiple clock controls; "
          "multi-clock inheritance is outside the model.")


STAGES = ["source", "flattened", "declaration-eliminated", "clock-rewritten"]


def order_code(samples, context, sel, values):
    stage = values["S"]
    declaration_first = int(STAGES[stage] == "flattened")
    flattened = int(stage >= 1)
    clocked = int(STAGES[stage] == "clock-rewritten")
    return declaration_first | (flattened << 1) | (clocked << 2) | ((samples[0]["a"].integer() & 1) << 3)


table("f43_order", "F.4.3", "declaration-assignment elimination stage",
      signals=[("a", 1)], horizon=1, inputs=[("S", 2)],
      actual=order_code,
      reference="""
        always @* begin
          reference_result = ((i_S==1)) | ((i_S>=1)<<1) | ((i_S==3)<<2) | (s_a_0<<3);
        end
      """,
      why="Of the four stages source, flattened, declaration-eliminated and clock-rewritten, the "
          "elimination runs only immediately after flattening and therefore before the clock "
          "rewrites.  The last bit observes the initialization value that the eliminated "
          "assignment makes visible at the first tick.",
      limitation="A pipeline-order predicate over four named stages, not a semantic comparison "
          "of two rewrite orders; the value bit only witnesses that the assignment is still "
          "executable at the aligned tick.")


# ---------------------------------------------------------------------------
# F.4.3 push


PUSH_SEQUENCE = [([("v", "a")], seq("(w=b) ##1 a")),
                 ([], seq("(w=b) ##1 a")),
                 ([("v", "a")], seq("a ##1 b")),
                 ([("v", "a")], seq("a[*0]"))]


def push_sequence_code(samples, context, sel):
    items, body = PUSH_SEQUENCE[sel]
    return tight_code(push_seq(items, body), samples, ["v", "w"])


table("f43_push_sequence", "F.4.3", "push of a pending list into a sequence",
      signals=[("a", 1), ("b", 1)], horizon=2, selectors=2,
      actual=push_sequence_code,
      reference="""
        always @* begin
          reference_result=0;
          case(sel)
            0: if (s_a_1)
                 reference_result=1 | (1<<1) | (s_a_0<<2) | (1<<3) | (s_b_0<<4);
            1: if (s_a_1)
                 reference_result=1 | (1<<3) | (s_b_0<<4);
            2: if (s_a_0 && s_b_1)
                 reference_result=1 | (1<<1) | (s_a_0<<2);
            default: ;                       // fusion with a null repetition never matches
          endcase
        end
      """,
      why="An empty list leaves the sequence unchanged (variant 1 keeps no v).  A nonempty list "
          "is fused as an aligned (1,assignments) prefix, so the assignment executes on the "
          "sequence's first letter (variant 0 keeps v=a0 and w=b0) and the result cannot admit "
          "empty: variant 3 fuses a one-letter assignment with a null repetition and matches "
          "nothing.",
      limitation="Words of two letters, one or two pending assignments, one sequence shape per "
          "variant; ordering of a longer list is covered by f43_push_decl.")


PUSH_BOOLEAN = [([("v", "a")], seq("((w=b) ##0 b) or ((w=c) ##0 c)")),
                ([("v", "a")], seq("((w=b) ##0 b) or ((x=c) ##0 c)")),
                ([("v", "a")], seq("((w=b) ##0 b) and ((x=c) ##0 c)")),
                ([("v", "a")], seq("((w=b) ##0 b) and ((w=c) ##0 c)")),
                ([("v", "a")], seq("((w=b) ##0 b) intersect ((x=c) ##0 c)")),
                ([], seq("((w=b) ##0 b) or ((w=c) ##0 c)"))]


def push_boolean_code(samples, context, sel):
    items, body = PUSH_BOOLEAN[sel % len(PUSH_BOOLEAN)]
    pushed = push_seq(items, body)
    return pack(ls.tight(pushed, samples, 0, 0, {}), ["v", "w", "x"])


table("f43_push_boolean", "F.4.3", "push into both operands of or/and",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=1, selectors=3,
      actual=push_boolean_code,
      reference="""
        always @* begin
          reference_result=0;
          case(sel)
            0: if (s_b_0 || s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2) | (1<<3) | (1<<4);
            1: if (s_b_0 || s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2);
            2: if (s_b_0 && s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2);
            3: if (s_b_0 && s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2) | (1<<3) | (s_c_0<<4);
            4: if (s_b_0 && s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2) | (1<<3) | (s_b_0<<4)
                                  | (1<<5) | (s_c_0<<6);
            5: if (s_b_0 || s_c_0)
                 reference_result=1 | (1<<3) | (1<<4);
            6: if (s_b_0 || s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2) | (1<<3) | (1<<4);
            default: if (s_b_0 || s_c_0)
                 reference_result=1 | (1<<1) | (s_a_0<<2);
          endcase
        end
      """,
      why="The pending v=a is pushed into both operands, so either branch can match only with v "
          "already assigned (variant 1 would lose v if the push went to one branch only).  The or "
          "keeps only the names in both branch flows, which is why variant 1 drops w and x while "
          "variant 0 keeps w; and is flow-restricted the same way (variant 2 keeps only v, variant "
          "3 keeps w because both branches name it), intersect merges both branch contexts "
          "(variant 4) and an empty list keeps no v (variant 5).",
      limitation="One letter, at most two pending names, sequence-level or/and/intersect standing "
          "for the property operators of the clause; the property-level or/and with no context "
          "output is not separately enumerated.")


PUSH_CONDITIONAL = [([("v", "a")], parse_spec("if (v) (b) else (c)").body),
                    ([], parse_spec("if (v) (b) else (c)").body),
                    ([("v", "a")], parse_spec("if (a) (if (v) (b) else (c)) else (d)").body),
                    ([("v", "a"), ("w", "v")], parse_spec("if (w) (b) else (c)").body)]


def push_conditional_code(samples, context, sel):
    items, body = PUSH_CONDITIONAL[sel]
    return prop_code(push_prop(items, body), samples, 0)


table("f43_push_cond", "F.4.3", "push into if/else",
      signals=[("a", 1), ("v", 1), ("b", 1), ("c", 1), ("d", 1)], horizon=1,
      selectors=2,
      actual=push_conditional_code,
      reference="""
        always @* begin
          reference_result=16;
          case(sel)
            0,3: reference_result = s_a_0 ? (s_b_0 ? 0 : 16) : (s_c_0 ? 0 : 16);
            1: reference_result = s_v_0 ? (s_b_0 ? 0 : 16) : (s_c_0 ? 0 : 16);
            default: reference_result = s_a_0 ? (s_b_0 ? 0 : 16) : (s_d_0 ? 0 : 16);
          endcase
        end
      """,
      why="The arms are pushed with empty lists, and a nonempty pending list is executed by "
          "(1,assignments) |-> conditional before the condition: variant 0 reads v=a0 while "
          "variant 1, with an empty list, reads the letter v0.  Variant 2 nests the conditional "
          "and variant 3 shows a two-element ordered list feeding the condition.",
      limitation="One letter, Boolean conditions, no action blocks; the nested conditional is one "
          "level deep.")


PUSH_DECL = [([("v", "a")], "w", "v", "(w==1) ##1 b"),
             ([], "w", "v", "(w==1) ##1 b"),
             ([("v", "a")], "w", None, "b ##1 (v==1)"),
             ([("v", "a")], "w", "v", "b ##1 (w==1)")]


def push_decl_code(samples, context, sel):
    items, name, initializer, body = PUSH_DECL[sel]
    node = seq(body)
    if initializer is None:
        tree = Node("decl", (node,), name)
    else:
        tree = Node("initdecl", (node,), (name, initializer))
    return tight_code(push_prop(items, tree), samples, ["v"])


table("f43_push_decl", "F.4.3", "push through a local declaration",
      signals=[("a", 1), ("v", 1), ("b", 1)], horizon=2, selectors=2,
      actual=push_decl_code,
      reference="""
        always @* begin
          reference_result=0;
          case(sel)
            0: if (s_a_0 && s_b_1) reference_result=1 | (1<<1) | (s_a_0<<2);
            1: if (s_v_0 && s_b_1) reference_result=1;
            2: if (s_b_0 && s_a_0) reference_result=1 | (1<<1) | (s_a_0<<2);
            default: if (s_b_0 && s_a_0) reference_result=1 | (1<<1) | (s_a_0<<2);
          endcase
        end
      """,
      why="A declaration is preserved and its initializer becomes the last element of the pending "
          "ordered list with the initializer removed from the declaration.  In variant 0 the "
          "pending v=a therefore executes before w=v, so w receives a0 rather than the letter v0 "
          "(variant 1, with an empty list, receives v0).  Variant 3 shows the initializer aligned "
          "with the declaration's first letter even though the body reads w on the second.",
      limitation="One declared name, one or two pending assignments, 1-bit values; nested "
          "declarations are not enumerated.")


PUSH_NONOVERLAP = [([("v", "a")], seq("(w=b) ##1 c"), parse_spec("(v==1)").body),
                   ([], seq("(w=b) ##1 c"), parse_spec("(v==1)").body),
                   ([("v", "a")], seq("a[*0]"), parse_spec("(v==1)").body),
                   ([], seq("a[*0]"), parse_spec("(v==1)").body)]


def push_nonoverlap_code(samples, context, sel):
    items, antecedent, consequent = PUSH_NONOVERLAP[sel]
    return prop_code(push_prop(items, Node("|=>", (antecedent, consequent))), samples, 0)


table("f43_push_nonoverlap", "F.4.3", "push into a nonoverlapping implication",
      signals=[("a", 1), ("b", 1), ("c", 1), ("v", 1)], horizon=3, selectors=2,
      actual=push_nonoverlap_code,
      reference="""
        always @* begin
          case(sel)
            0: if (!s_c_1) reference_result=32;
               else reference_result = s_a_0 ? 2 : 18;
            1: if (!s_c_1) reference_result=32;
               else reference_result = s_v_2 ? 2 : 18;
            2: reference_result = s_a_0 ? 0 : 16;
            default: reference_result = s_v_0 ? 0 : 16;
          endcase
        end
      """,
      why="The pending list is pushed into the antecedent, so the aligned initialization runs "
          "before it and its context reaches the shifted consequent (variants 0 and 1 differ only "
          "by the empty list).  When the antecedent admits empty (variants 2 and 3, a[*0]) the "
          "pushed antecedent cannot match, so the conjoined push into the consequent decides the "
          "result: the failure tick 0 replaces the vacuous success the implication alone would "
          "give.",
      limitation="Three ticks, one antecedent shape and one Boolean consequent; the conjoined "
          "consequent is the literal clause rule, and its interaction with a matching but "
          "empty-admitting antecedent is not enumerated.")


PUSH_OVERLAP = [([("v", "a")], seq("(w=b)"), parse_spec("(v==1)").body),
                ([("v", "a")], seq("(v=0)"), parse_spec("(v==1)").body),
                ([], seq("(w=b)"), parse_spec("(v==1)").body),
                ([("v", "a")], seq("((w=b) ##1 (x=c))"), parse_spec("(v==1)").body)]


def push_overlap_code(samples, context, sel):
    items, antecedent, consequent = PUSH_OVERLAP[sel]
    return prop_code(push_prop(items, Node("|->", (antecedent, consequent))), samples, 0)


table("f43_push_overlap", "F.4.3", "push into an overlapping implication",
      signals=[("a", 1), ("v", 1), ("b", 1), ("c", 1), ("x", 1)], horizon=2,
      selectors=2,
      actual=push_overlap_code,
      reference="""
        always @* begin
          case(sel)
            0: reference_result = s_a_0 ? 0 : 16;
            1: reference_result = 16;
            2: reference_result = s_v_0 ? 0 : 16;
            default: reference_result = s_a_0 ? 1 : 17;
          endcase
        end
      """,
      why="With a nonempty pending list the initialization is aligned before the antecedent and "
          "the consequent recurses with an empty list.  Variant 0 reads v=a0 in the consequent; "
          "variant 1 would succeed if the list were pushed again into the consequent, because "
          "that would restore v=a0 after the antecedent set v=0, so its constant failure shows "
          "the empty-list recursion.  Variant 2, with no pending list, reads the letter v0.",
      limitation="Two ticks, one assignment in the antecedent, Boolean consequent; nested "
          "implications of greater depth are not enumerated.")


PUSH_WRAPPERS = [([("v", "a")], "not", parse_spec("not (v==1)").body),
                 ([("v", "a")], "paren", parse_spec("(v==1)").body),
                 ([("v", "a")], "disable", parse_spec("disable iff (d) (v==1)").body),
                 ([], "disable", parse_spec("disable iff (d) (v==1)").body),
                 ([("v", "a")], "clock", parse_spec("@(posedge clk) (v==1)").body)]


def push_wrapper_code(samples, context, sel):
    items, wrapper, body = PUSH_WRAPPERS[sel % len(PUSH_WRAPPERS)]
    pushed = push_prop(items, body)
    if wrapper == "clock":
        return spec_prop_code(Spec(pushed, "clk", "posedge", None), samples)
    if wrapper == "disable":
        return prop_code(Node("disable", (pushed,), expr("d")), samples, 0)
    return prop_code(pushed, samples, 0)


table("f43_push_wrappers", "F.4.3", "push through disable iff, clock, parentheses and not",
      signals=[("a", 1), ("v", 1), ("d", 1)], horizon=1, selectors=3,
      actual=push_wrapper_code,
      reference="""
        always @* begin
          case(sel)
            0: reference_result = s_a_0 ? 16 : 0;              // not
            1: reference_result = s_a_0 ? 0 : 16;              // parentheses
            2: if (s_d_0) reference_result=80;
               else reference_result = s_a_0 ? 0 : 16;         // disable iff
            3: if (s_d_0) reference_result=80;
               else reference_result = s_v_0 ? 0 : 16;
            4: reference_result = 256 + (s_a_0 ? 0 : 16);      // explicit clock bit
            5: reference_result = s_a_0 ? 16 : 0;
            6: reference_result = s_a_0 ? 0 : 16;
            default: if (s_d_0) reference_result=80;
                     else reference_result = s_a_0 ? 0 : 16;
          endcase
        end
      """,
      why="Each wrapper keeps the pending list: not inverts the pushed body, parentheses leave "
          "it unchanged, disable iff applies to the pushed body while the disable expression still "
          "reads the incoming context (variant 3 has no pending list and reads the letter v), and "
          "the explicit clock stays around the pushed body, marked by bit 8.",
      limitation="One tick and one wrapper level; the clock is not allowed to change the local "
          "value threading in this model (a single clock keeps the unclocked relation), so the "
          "clocked variant only checks placement and the clock-presence bit.")


PUSH_PROCEDURE = [([], "plain"), ([], "clock"), ([], "not"), ([], "shift")]


def procedure_body(kind):
    if kind == "plain":
        return Node("|->", (seq("a"), Node("initdecl", (parse_spec("(w==1)").body,), ("w", "v"))))
    if kind == "clock":
        return Node("|->", (seq("a"), Node("initdecl", (parse_spec("(w==1)").body,), ("w", "v"))))
    if kind == "not":
        return Node("not", (Node("initdecl", (parse_spec("(w==1)").body,), ("w", "a")),))
    return Node("|->", (seq("a ##1 b"), Node("initdecl", (parse_spec("(w==1)").body,), ("w", "a"))))


def push_procedure_code(samples, context, sel):
    items, kind = PUSH_PROCEDURE[sel]
    node = procedure_body(kind)
    pushed = push_prop(items, node)
    if kind == "clock":
        return spec_prop_code(Spec(pushed, "clk", "posedge", None), samples)
    return prop_code(pushed, samples, 0)


table("f43_push_procedure", "F.4.3", "push remaining assignments after clock alignment",
      signals=[("a", 1), ("b", 1), ("v", 1)], horizon=2, selectors=2,
      actual=push_procedure_code,
      reference="""
        always @* begin
          case(sel)
            0: reference_result = s_a_0 ? (s_v_0 ? 0 : 16) : 32;
            1: reference_result = 256 + (s_a_0 ? (s_v_0 ? 0 : 16) : 32);
            2: reference_result = s_a_0 ? 16 : 0;
            default: if (!(s_a_0 && s_b_1)) reference_result=32;
                     else reference_result = s_a_1 ? 1 : 17;
          endcase
        end
      """,
      why="Every top-level property starts with an empty ordered list, and the remaining "
          "declaration assignment is pushed down to the property it belongs to: the overlap "
          "consequent's first tick (variant 0 and the clocked variant 1), through not (variant 2) "
          "and to the second tick when the enclosing antecedent is two letters long (variant 3).",
      limitation="Two ticks, one declaration per variant; the clock shares the single-clock "
          "approximation of f43_push_wrappers, so only placement and the clock-presence bit are "
          "checked.")


# ---------------------------------------------------------------------------
# F.4.3 initialized local sequence declarations


SEQUENCE_INIT = [([("v", "a")], seq("(v==1) ##1 (w=b)")),
                 ([("v", "a")], seq("(v==1)")),
                 ([("v", "a")], seq("a[*0]")),
                 ([("v", "a")], seq("(w=b) ##1 (v==1)"))]


def rewritten_declaration(items, body):
    """(t v; ((v=e) ##0 r) or (r intersect null)) of F.4.3."""
    aligned = fuse(items, body)
    empty = Node("intersect", (body, null_repetition()))
    return Node("decl", (Node("or", (aligned, empty)),), "v")


def sequence_init_code(samples, context, sel):
    items, body = SEQUENCE_INIT[sel]
    node = rewritten_declaration(items, body)
    return tight_code(node, samples, ["w"]) | (int(bool(empty_contexts(node))) << 3)


table("f43_sequence_init", "F.4.3", "initialized local sequence declaration rewrite",
      signals=[("a", 1), ("v", 1), ("b", 1)], horizon=2, selectors=2,
      actual=sequence_init_code,
      reference="""
        always @* begin
          reference_result=0;
          case(sel)
            0: if (s_a_0) reference_result=1 | (1<<1) | (s_b_1<<2);
            1: if (s_a_0) reference_result=1;
            2: reference_result=8;
            default: if (s_a_0) reference_result=1 | (1<<1) | (s_b_0<<2);
          endcase
        end
      """,
      why="The initialized declaration becomes an uninitialized declaration whose body is the "
          "aligned initializer fused with r, or r intersect the null repetition.  On a nonempty "
          "word the initializer executes on r's first letter, so variant 0 matches when a0 holds "
          "(the assignment w=b always matches) and exports w=b1; variant 2 admits only the empty "
          "word, reported by bit 3.",
      limitation="Two ticks, one declared name, no explicit clock in the rewrite; the or-shaped "
          "alternative reduces the exported names to the branch flow intersection, which is why "
          "only names assigned on both branches stay visible.")


SEQUENCE_EMPTY = variants("a[*0]", "(v; a[*0])", "(v=a)[*0]", "a[*0:1]",
                          "first_match(a[*0])", "(a[*0])[*1:$]", "a")


def sequence_empty_code(samples, context, sel):
    node = SEQUENCE_EMPTY[sel % len(SEQUENCE_EMPTY)]
    empty_alt = Node("intersect", (node, null_repetition()))
    contexts = empty_contexts(empty_alt)
    unchanged = int(len(contexts) == 1 and contexts[0] == {})
    no_letter = int(not ls.tight(empty_alt, samples, 0, 0, {}))
    return (unchanged | (no_letter << 1) | (int(admits_empty(node)) << 2)
            | (int(bool(empty_contexts(null_repetition()))) << 3))


table("f43_sequence_empty", "F.4.3", "empty alternative simplifies to null repetition",
      signals=[("a", 1), ("b", 1)], horizon=1, selectors=3,
      actual=sequence_empty_code,
      reference=sel_case([15, 15, 15, 15, 15, 15, 10, 15]),
      why="When r admits empty, r intersect the null repetition matches the empty word with the "
          "unchanged context (bit 0), matches no letter (bit 1) and therefore simplifies to the "
          "null repetition, whose empty match is reported by bit 3; no initializer value is "
          "produced by that match.  The last variant cannot match empty, so the empty alternative "
          "matched nothing and only the null repetition bit remains.",
      limitation="The empty word has no letters, so the absence of an initializer effect is "
          "observed through the unchanged context rather than through a value; the case is word "
          "independent apart from the no-letter check.")


SEQUENCE_NONEMPTY = variants("a", "(v=a)", "a ##1 b", "(w=b)", "a[*0]",
                             "first_match(a)")


def sequence_nonempty_code(samples, context, sel):
    node = SEQUENCE_NONEMPTY[sel % len(SEQUENCE_NONEMPTY)]
    empty_alt = Node("intersect", (node, null_repetition()))
    one_letter = int(bool(ls.tight(node, samples, 0, 0, {})))
    return (int(admits_empty(node)) | (int(bool(empty_contexts(empty_alt))) << 1)
            | (int(bool(empty_contexts(Node("or", (node, empty_alt))))) << 2)
            | (one_letter << 3))


table("f43_sequence_nonempty", "F.4.3", "empty alternative removed for a nonempty sequence",
      signals=[("a", 1), ("b", 1)], horizon=1, selectors=3,
      actual=sequence_nonempty_code,
      reference="""
        always @* begin
          case(sel)
            0: reference_result = (s_a_0<<3);        // a
            1: reference_result = 8;                 // (v=a)
            2: reference_result = 0;                 // a ##1 b
            3: reference_result = 8;                 // (w=b)
            4: reference_result = 7;                 // a[*0]: nothing may be removed
            5: reference_result = (s_a_0<<3);        // first_match(a)
            6: reference_result = (s_a_0<<3);
            default: reference_result = 8;
          endcase
        end
      """,
      why="For a sequence that cannot match empty, r intersect the null repetition matches "
          "nothing (bit 1 clear), so adding it as an alternative leaves the empty-word behaviour "
          "unchanged (bit 2 clear) and the empty alternative can be removed.  The fifth variant is "
          "the control: a null repetition does admit empty, so nothing may be removed.  Bit 3 is "
          "the word-dependent one-letter match of r.",
      limitation="Word independent except the one-letter bit; the six variants sample the "
          "nonempty operators and the decision is reported rather than applied to a larger "
          "rewrite.")

