"""Formal case tables for Annex F.5.4-F.5.7.

Each table entry is a finite-input equivalence check:

* ``signals``   sampled 1..n-bit inputs, one sample per tick
* ``context``   incoming local context: a value and a presence bit per name
* ``inputs``    non-temporal anyconst inputs (used by the static set cases)
* ``selectors`` anyconst variant selector
* ``actual``    an independent executable model from ``localsem``
* ``reference`` RTL written directly from the clause text; it never calls the
  parser, the derivative engine or the evaluator.

The exporter in ``formal.py`` enumerates every input word in one combinational
``case`` statement.  This is exhaustive for the finite input set; it is not a
claim about infinite words or about a simulator.
"""

from . import localsem as ls
from .parser import Node, parse_sequence, parse_spec
from .sampled import History
from .values import Bits, evaluate


TABLES = {}


def table(name, clause, expression, *, signals=(), horizon=1, context=(),
          inputs=(), selectors=0, actual, reference, cover="1",
          why="", limitation=""):
    TABLES[name] = {
        "clause": clause, "expression": expression, "signals": list(signals),
        "horizon": horizon, "context": list(context), "inputs": list(inputs),
        "selectors": selectors, "actual": actual, "reference": reference,
        "cover": cover, "why": why, "limitation": limitation,
    }


def seq(text):
    return parse_sequence(text)


def prop_node(text):
    return parse_spec(text).body


def variants(*texts):
    return [seq(text) for text in texts]


def mask(names, values):
    order = ["v", "w", "x"]
    return sum(1 << order.index(name) for name in values if name in order)


def sel_case(constants, width=8):
    body = " ".join(f"{i}: reference_result={width}'d{value};"
                    for i, value in enumerate(constants))
    return f"always @* begin reference_result=0; case(sel) {body} endcase end"


# ---------------------------------------------------------------------------
# F.5.4 block / flow / sample


BLOCK_BASE = variants(
    "a", "a[*0]", "(v=a)", "(v; a)", "((v=a))",
    "first_match((v=a) ##1 b)", "((v=a) ##1 b)[*2]",
    "(v; (w=a) ##1 (v=b))")
table("f54_block_base", "F.5.4", "block base, declaration, parens, first_match, repeat",
      selectors=3,
      actual=lambda samples, context, sel: mask("vw", ls.block(BLOCK_BASE[sel])),
      reference=sel_case([0, 0, 0, 1, 0, 0, 0, 1]),
      why="block(Boolean/assignment/null repetition) is empty, a declaration adds its name, "
          "and parentheses/first_match/positive repetition preserve the operand block.",
      limitation="Finite syntax variants only; the universe of local names is {v,w}.")


BLOCK_CONCAT = variants(
    "(v; a) ##1 (v=b)", "(v; a) ##1 c",
    "(v; (w=a) ##1 (v=b)) ##1 (w=c)",
    "((v; a) intersect (v; b)) ##1 (v=c)")
table("f54_block_concat", "F.5.4", "block(R1 ##1 R2)",
      selectors=2,
      actual=lambda samples, context, sel: mask("vw", ls.block(BLOCK_CONCAT[sel])),
      reference=sel_case([0, 1, 1, 0]),
      why="block(concat) = (block(left) - flow(empty,right)) union block(right); "
          "a name assigned by the right operand lets the left declaration escape.",
      limitation="Two-name universe; fusion and unbounded concatenation are not enumerated.")


BLOCK_INTERSECT = variants(
    "(v; a) intersect ((w=b) ##1 c)",
    "(v=a) intersect (w=b)",
    "((v=a) ##1 (w=b)) intersect ((v=c) ##1 (w=d))",
    "((v=a) ##1 b) intersect ((v=c) ##1 d)")
def intersect_sample(node):
    """BLOCK-INTERSECT states intersection of the operand sample sets."""
    if node.op == "intersect":
        return ls.sample(node.args[0]) & ls.sample(node.args[1])
    return ls.sample(node)


table("f54_block_intersect", "F.5.4", "block/sample of intersect",
      selectors=2,
      actual=lambda samples, context, sel: (
          mask("vw", ls.block(BLOCK_INTERSECT[sel]))
          | (mask("vw", intersect_sample(BLOCK_INTERSECT[sel])) << 4)),
      reference=sel_case([1, 0, 3 << 4, 1 << 4], width=8),
      why="block(intersect) is the union of the branch block sets; sample(intersect) is the "
          "intersection of the branch sample sets.  The packed result tests both equations.",
      limitation="Two-name universe; branch flow difference is exercised by f54_flow_intersect.")


BLOCK_OR = variants(
    "(v; a) or (w; b)", "(v; a) or ((w=b) ##1 c)",
    "(v=a) or (w=b)", "((v; a) ##1 b) or ((w; c) ##1 d)")
table("f54_block_or", "F.5.4", "block(R1 or R2)",
      selectors=2,
      actual=lambda samples, context, sel: mask("vw", ls.block(BLOCK_OR[sel])),
      reference=sel_case([3, 1, 0, 3]),
      why="block(or) is the union of the operand block sets, independent of assignment.",
      limitation="Two-name universe.")


FLOW_BASE = variants("a", "(v=a)", "a[*0]", "((v=a))",
                     "first_match((v=a) ##1 b)", "(v=a)[*1:2]",
                     "(v=a) ##1 b", "a ##1 b")
table("f54_flow_base", "F.5.4", "flow(X,R) base and repetition",
      context=[("v", 1), ("w", 1)], selectors=3,
      actual=lambda samples, context, sel: mask("vw", ls.flow(set(context), FLOW_BASE[sel])),
      reference="""
        always @* begin
          reference_result=p_v | (p_w<<1);
          case(sel)
            1,3,4,5,6: reference_result=reference_result | 1;
            default: ;
          endcase
        end
      """,
      why="flow through a Boolean or null repetition is the incoming set X; an assignment adds "
          "its local name; parentheses, first_match and positive repetition use the operand flow.",
      limitation="Two-name universe; X ranges over all subsets through p_v/p_w.")


FLOW_CONCAT = variants(
    "(v=a) ##1 (w=v)", "(v; a) ##1 (w=b)",
    "((w=a) ##1 (v=w)) ##1 (w=v)", "(v=a) ##1 (v=b)")
table("f54_flow_concat", "F.5.4", "flow(X,R1 ##1 R2)",
      context=[("v", 1), ("w", 1), ("x", 1)], selectors=2,
      actual=lambda samples, context, sel: mask("vwx", ls.flow(set(context), FLOW_CONCAT[sel])),
      reference="""
        always @* begin
          reference_result=p_v | (p_w<<1) | (p_x<<2);
          case(sel)
            0: reference_result=reference_result | 1 | 2;
            1: reference_result=reference_result | 2;
            2: reference_result=reference_result | 1 | 2;
            3: reference_result=reference_result | 1;
          endcase
        end
      """,
      why="flow(concat) composes left then right: flow(flow(X,left),right).  Variant 1 shows "
          "that a left declaration removes the name before the right flow is taken.",
      limitation="Three-name universe; fusion is not separately selected here.")


FLOW_INTERSECT = variants(
    "(v=a) intersect (w=b)", "(v; a) intersect (w; b)",
    "((v=a) ##1 b) intersect (w=c)", "(v; a) intersect (v; b)")
table("f54_flow_intersect", "F.5.4", "flow(X,R1 intersect R2)",
      context=[("v", 1), ("w", 1), ("x", 1)], selectors=2,
      actual=lambda samples, context, sel: mask("vwx", ls.flow(set(context), FLOW_INTERSECT[sel])),
      reference="""
        always @* begin
          reference_result=p_v | (p_w<<1) | (p_x<<2);
          case(sel)
            0: reference_result=reference_result | 1 | 2;
            1: reference_result=reference_result & ~3;
            2: reference_result=reference_result | 1 | 2;
            3: reference_result=reference_result & ~1;
          endcase
        end
      """,
      why="flow(intersect) is the union of both branch flows minus block(intersect).  Variant 1 "
          "declares v and w in the branches, so both are removed.",
      limitation="Three-name universe; block(intersect) is exercised as the subtraction term.")


FLOW_OR = variants("(v=a) or (w=b)", "(v=a) or (v=b)",
                   "(v; a) or (v=b)", "(v; a) or (w; b)", "a or b",
                   "(v=a) or b", "a or (v=b)",
                   "(v; a) or (w; b) or (x; c)")
table("f54_flow_or", "F.5.4", "flow(X,R1 or R2)",
      context=[("v", 1), ("w", 1), ("x", 1)], selectors=3,
      actual=lambda samples, context, sel: mask("vwx", ls.flow(set(context), FLOW_OR[sel])),
      reference="""
        always @* begin
          reference_result=p_v | (p_w<<1) | (p_x<<2);
          case(sel)
            1: reference_result=reference_result | 1;
            default: ;
          endcase
        end
      """,
      why="flow(or) is the intersection of the two branch flows; a declaration in one branch "
          "therefore removes that name from the result.",
      limitation="Three-name universe.")


FLOW_SCOPE = variants("(v; (v=a) ##1 (w=v))", "(v; (w=v) ##1 (x=w))",
                      "(v; (v=a))", "(v; a)")
table("f54_flow_scope", "F.5.4", "flow(X,local v; R)",
      context=[("v", 1), ("w", 1), ("x", 1)], selectors=2,
      actual=lambda samples, context, sel: mask("vwx", ls.flow(set(context), FLOW_SCOPE[sel])),
      reference="""
        always @* begin
          reference_result=p_v | (p_w<<1) | (p_x<<2);
          case(sel)
            0: reference_result=reference_result | 2;
            1: reference_result=reference_result | 2 | 4;
            2,3: ;
          endcase
        end
      """,
      why="flow(local v;R) runs R with incoming v removed, removes inner v from the outgoing "
          "flow, and restores an incoming outer v.  Variant 0 keeps outer v and adds w.",
      limitation="Three-name universe; nested declarations are not enumerated.")


SAMPLE_BASE = variants("a", "a[*0]", "(v=a)", "((v=a))",
                       "first_match((v=a) ##1 b)", "(v=a)[*2]",
                       "(v=a) ##1 (w=b)", "(v=a) ##0 (w=b)")
table("f54_sample_base", "F.5.4", "sample base",
      selectors=3,
      actual=lambda samples, context, sel: mask("vw", ls.sample(SAMPLE_BASE[sel])),
      reference=sel_case([0, 0, 1, 1, 1, 1, 3, 3]),
      why="sample(Boolean) and sample(null repetition) are empty; sample(assignment to v) is "
          "{v}; parentheses, first_match and positive repetition preserve it.",
      limitation="Two-name universe.")


SAMPLE_BINARY = variants("(v=a) ##1 (w=b)", "(v=a) ##0 (w=b)",
                         "(v=a) or (w=b)", "(v=a) intersect (w=b)",
                         "((v=a) ##1 (w=b)) ##1 (x=c)", "(v=a)[*2]",
                         "(v; a)", "((v=a) ##0 (w=b)) ##1 (x=c)")
table("f54_sample_binary", "F.5.4", "sample of concat/fusion/or/intersect",
      selectors=3,
      actual=lambda samples, context, sel: mask("vwx", ls.sample(SAMPLE_BINARY[sel])),
      reference=sel_case([3, 3, 3, 3, 7, 1, 0, 7], width=8),
      why="sample of concat, fusion, or and intersect is the union of the operand sample sets.",
      limitation="Three-name universe; unbounded repetition is covered by f54_sample_base.")


SAMPLE_SCOPE = variants("(v; (v=a) ##1 (w=b))", "((v=a) ##1 (w=b))",
                        "first_match((v=a) ##1 (w=b))",
                        "((v=a) ##1 (w=b))[*2]",
                        "(v; (w=a) ##1 (x=b))", "(v; (v=a))",
                        "(w; (v=a))", "((v=a)[*2])")
table("f54_sample_scope", "F.5.4", "sample(local v;R)",
      selectors=3,
      actual=lambda samples, context, sel: mask("vwx", ls.sample(SAMPLE_SCOPE[sel])),
      reference=sel_case([2, 3, 3, 3, 6, 0, 1, 1], width=8),
      why="sample(local v;R) removes v; parentheses, first_match and positive repetition "
          "preserve the operand sample set.",
      limitation="Three-name universe.")


def set_operation(values, sel):
    a, b = values["A"], values["B"]
    if sel == 0:
        return a | b
    if sel == 1:
        return a & b
    if sel == 2:
        return a & ~b & 7
    return 0


table("f54_sets", "F.5.4", "set union / intersection / difference / empty",
      inputs=[("A", 3), ("B", 3)], selectors=2,
      actual=lambda samples, context, sel, inputs: set_operation(inputs, sel),
      reference="""
        always @* begin
          case(sel)
            0: reference_result=i_A | i_B;
            1: reference_result=i_A & i_B;
            2: reference_result=i_A & ~i_B & 3'b111;
            default: reference_result=0;
          endcase
        end
      """,
      why="F.5.4 uses set union, intersection, difference and the empty set; this case fixes "
          "the four operators on all pairs of 3-name subsets.",
      limitation="Set operators only; membership is a 3-bit indicator, not an SVA construct.")


# ---------------------------------------------------------------------------
# F.5.5 tight local satisfaction


def pack_context(outgoing, names, base=1):
    code = base
    for index, name in enumerate(names):
        if name in outgoing:
            code |= 1 << (index * 2 + 1)
            code |= outgoing[name].integer() << (index * 2 + 2)
    return code


def one_tight(node, word, end, context):
    outgoing = ls.tight(node, word, 0, end, context)
    return outgoing[0] if outgoing else None


ASSIGN_VARIANTS = variants("(v = a)", "(w = v)", "(v = w)", "(v = a)")
table("f55_assign", "F.5.5", "assignment (v = e)",
      signals=[("a", 1), ("v", 1), ("w", 1)], horizon=1,
      context=[("v", 1), ("w", 1)], selectors=2,
      actual=lambda samples, context, sel: (
          0 if one_tight(ASSIGN_VARIANTS[sel], samples, 0, context) is None
          else pack_context(one_tight(ASSIGN_VARIANTS[sel], samples, 0, context), ["v", "w"])),
      reference="""
        reg matched, pv, pw, vv, ww;
        always @* begin
          matched=1;
          pv=p_v; pw=p_w; vv=c_v; ww=c_w;
          case(sel)
            0,3: begin pv=1; vv=s_a_0; end
            1: begin pw=1; ww=p_v ? c_v : s_v_0; end
            2: begin pv=1; vv=p_w ? c_w : s_w_0; end
          endcase
          reference_result=matched | (pv<<1) | ((pv?vv:0)<<2) | (pw<<3) | ((pw?ww:0)<<4);
        end
      """,
      why="An assignment matches one letter satisfying true, evaluates its expression with the "
          "local context consulted before the letter, replaces only its own name and preserves "
          "the other inputs.",
      limitation="1-bit values, one letter; the context is either absent or 1.")


BOOLEAN_LOCAL = variants("(a && !b)", "((a && !b))", "(v && !b)", "(a && !v)")
table("f55_boolean", "F.5.5", "Boolean tight satisfaction with a local context",
      signals=[("a", 1), ("b", 1), ("v", 1)], horizon=1,
      context=[("v", 1)], selectors=2,
      actual=lambda samples, context, sel: (
          0 if one_tight(BOOLEAN_LOCAL[sel], samples, 0, context) is None
          else pack_context(one_tight(BOOLEAN_LOCAL[sel], samples, 0, context), ["v"])),
      reference="""
        reg matched, local_v;
        always @* begin
          local_v=p_v ? c_v : s_v_0;
          case(sel)
            0,1: matched=s_a_0 && !s_b_0;
            2: matched=local_v && !s_b_0;
            default: matched=s_a_0 && !local_v;
          endcase
          reference_result=matched ? (1 | (p_v<<1) | ((p_v?local_v:0)<<2)) : 0;
        end
      """,
      why="A Boolean tightly matches exactly one letter satisfying it after local substitution; "
          "parentheses preserve the relation and the context is unchanged.",
      limitation="1-bit values; only the scalar Boolean fragment.")


CLOCKED_LOCAL = parse_spec("@(posedge clk) ((v=a) ##1 (w=v))").body
table("f55_clocked", "F.5.5", "@(posedge clk) (v=a) ##1 (w=v)",
      signals=[("a", 1), ("v", 1), ("w", 1)], horizon=2,
      context=[("v", 1)],
      actual=lambda samples, context, sel: (
          0 if one_tight(CLOCKED_LOCAL, samples, 1, context) is None
          else pack_context(one_tight(CLOCKED_LOCAL, samples, 1, context), ["v", "w"])),
      reference="""
        reg [1:0] vout, wout; reg matched;
        always @* begin
          matched=1;
          vout=s_a_0;
          wout=s_a_0;
          reference_result=(matched | (1<<1) | (vout<<2) | (1<<3) | (wout<<4));
        end
      """,
      why="A clocked local tight match equals its unclocked rewrite with the same input and "
          "output contexts; the single clock does not change context threading.",
      limitation="One scalar clock only; multi-clock local semantics is outside the model.")


CONCAT_LOCAL = variants("(v=a) ##1 (w=b)", "(v=a) ##0 (w=b)")
table("f55_concat", "F.5.5", "concat and fusion context threading",
      signals=[("a", 1), ("b", 1), ("v", 1), ("w", 1)], horizon=2,
      context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: (
          0 if one_tight(CONCAT_LOCAL[sel], samples, 1 if sel == 0 else 0, context) is None
          else pack_context(one_tight(CONCAT_LOCAL[sel], samples, 1 if sel == 0 else 0, context),
                            ["v", "w"])),
      reference="""
        always @* begin
          reference_result=1 | (1<<1) | (s_a_0<<2) | (1<<3) |
                            ((sel ? s_b_0 : s_b_1)<<4);
        end
      """,
      why="Concat passes the left output context to the right on adjacent pieces; fusion does "
          "the same on one shared letter, so the right assignment reads b at tick 0 instead of 1.",
      limitation="Two-letter words; 1-bit values.")


table("f55_context", "F.5.5", "context restriction L\\v and L[v]",
      context=[("v", 1), ("w", 1)], selectors=2,
      actual=lambda samples, context, sel: pack_context(
          {"keep_v": ls.restrict(context, {"v"}), "keep_w": ls.restrict(context, {"w"}),
           "none": {}, "all": dict(context)}[["keep_v", "keep_w", "none", "all"][sel]],
          ["v", "w"], base=0),
      reference="""
        reg pv, pw, vv, ww;
        always @* begin
          pv=p_v; pw=p_w; vv=c_v; ww=c_w;
          case(sel)
            0: pw=0;
            1: pv=0;
            2: begin pv=0; pw=0; end
            3: ;
          endcase
          reference_result=(pv<<1) | ((pv?vv:0)<<2) | (pw<<3) | ((pw?ww:0)<<4);
        end
      """,
      why="L without v removes v and L[v] keeps only v; the packed result exposes both the "
          "domain and the retained values.",
      limitation="Two names, 1-bit values.")


DECL_LOCAL = variants("(v; (v=a) ##1 (w=v))", "(v; (w=v) ##1 (v=a))")
table("f55_decl", "F.5.5", "local declaration context",
      signals=[("a", 1), ("v", 1), ("w", 1)], horizon=2,
      context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: (
          0 if one_tight(DECL_LOCAL[sel], samples, 1, context) is None
          else pack_context(one_tight(DECL_LOCAL[sel], samples, 1, context), ["v", "w"])),
      reference="""
        reg pv, vv, pw, ww;
        always @* begin
          pv=p_v; vv=c_v;
          pw=1;
          case(sel)
            0: ww=s_a_0;
            default: ww=s_v_0;
          endcase
          reference_result=1 | (pv<<1) | ((pv?vv:0)<<2) | (pw<<3) | ((pw?ww:0)<<4);
        end
      """,
      why="The operand runs with incoming v removed; the outgoing context drops the inner v and "
          "restores the outer v, alongside the names the operand produced.",
      limitation="One outer and one inner name; 1-bit values.")


FIRST_LOCAL = variants("first_match(a ##[1:2] b)",
                       "first_match((a ##1 b) or (a ##2 b))")
table("f55_first", "F.5.5", "first_match",
      signals=[("a", 1), ("b", 1)], horizon=3, selectors=1,
      actual=lambda samples, context, sel: (
          0 if not ls.tight(FIRST_LOCAL[sel], samples, 0, 2, context)
          else 1 | (2 << 1)),
      reference="""
        always @* begin
          reference_result=(s_a_0 && s_b_2 && !(s_a_0 && s_b_1)) ? 3'd5 : 3'd0;
        end
      """,
      why="first_match at tick 2 requires a match of the operand and no earlier ending match of "
          "a proper prefix with the same input context.",
      limitation="The reference uses the operational earliest-end form; the explicit dual-word "
          "construction is not built.  Two-letter sequences only.")


INTERSECT_LOCAL = variants(
    "((v=a) ##1 (w=v)) intersect ((v=b) ##1 (x=v))",
    "(v=a) intersect (w=b)")
table("f55_intersect", "F.5.5", "intersect context combination",
      signals=[("a", 1), ("b", 1), ("v", 1), ("w", 1), ("x", 1)], horizon=2,
      context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: (
          0 if not ls.tight(INTERSECT_LOCAL[sel], samples, 0, 1 if sel == 0 else 0, context)
          else pack_context(ls.tight(INTERSECT_LOCAL[sel], samples, 0, 1 if sel == 0 else 0, context)[0],
                            ["w", "x"] if sel == 0 else ["v", "w"])),
      reference="""
        reg pw, ww, px, xx;
        always @* begin
          pw=0; ww=0; px=0; xx=0;
          if (sel==0) begin
            pw=1; ww=s_a_0;
          px=1; xx=s_b_0;
            reference_result=1 | (pw<<1) | (ww<<2) | (px<<3) | (xx<<4);
          end else begin
            pw=1; ww=s_b_0;
            reference_result=1 | (1<<1) | (s_a_0<<2) | (pw<<3) | (ww<<4);
          end
        end
      """,
      why="Both branches match the same input and word; each output is restricted to its branch "
          "flow minus the combined block and the other branch's sample set.  In variant 0 the "
          "common assigned v therefore disappears while w and x remain.",
      limitation="Two branches over at most two letters, 1-bit values.")


def _nondegenerate(node, signal_names, max_length=3):
    import itertools
    for length in range(1, max_length + 1):
        for bits in range(1 << (len(signal_names) * length)):
            word = [{name: Bits(str((bits >> (tick * len(signal_names) + index)) & 1))
                     for index, name in enumerate(signal_names)} for tick in range(length)]
            if ls.tight(node, word, 0, length - 1, {}):
                return 1
    return 0


NONDEGENERATE = variants("(v=a) ##1 (w=v)", "a[*0]", "a[*0] ##0 b[*0]",
                         "(v=a) ##0 (w=v)")
table("f55_non_degenerate", "F.5.5", "nondegenerate local sequence",
      signals=[("a", 1), ("b", 1)], horizon=1, selectors=2,
      actual=lambda samples, context, sel: _nondegenerate(NONDEGENERATE[sel], ["a", "b"]),
      reference=sel_case([1, 0, 0, 1], width=8),
      why="A local sequence is nondegenerate exactly when a nonempty finite word and some "
          "input/output contexts tightly satisfy it; the empty-only fusion is degenerate.",
      limitation="Words up to length 3 and empty input context; 1-bit signals.")


NULL_LOCAL = variants("(v=a)[*0]", "(v=a)[*0]")
table("f55_null", "F.5.5", "null repetition",
      signals=[("a", 1)], context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: (
          0 if not ls.tight(NULL_LOCAL[sel], samples, 0, -1 if sel == 0 else 0, context)
          else pack_context(ls.tight(NULL_LOCAL[sel], samples, 0, -1 if sel == 0 else 0, context)[0],
                            ["v"])),
      reference="""
        always @* begin
          reference_result = sel==0 ? (1 | (p_v<<1) | ((p_v?c_v:0)<<2)) : 0;
        end
      """,
      why="A null repetition matches the empty word with an unchanged context; the same sequence "
          "does not match a one-letter word.",
      limitation="Only the empty and one-letter cases are compared.")


OR_LOCAL = variants("(v=a) or (w=b)", "(v=a) or (v=b)")
table("f55_or", "F.5.5", "or branch context restriction",
      signals=[("a", 1), ("b", 1), ("v", 1), ("w", 1)], horizon=1,
      context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: _or_code(OR_LOCAL[sel], samples, context),
      reference="""
        always @* begin
          if (sel==0) begin
            if (!p_v) reference_result=1;
            else reference_result=1 | ((!s_a_0 || !c_v)<<1) | ((s_a_0 || c_v)<<2);
          end else reference_result=1 | ((!s_a_0 || !s_b_0)<<1) | ((s_a_0 || s_b_0)<<2);
        end
      """,
      why="or may match either branch and then restricts the resulting context to flow(or).  "
          "Two assignments to different names flow to the empty set; two assignments to v leave "
          "the two possible v values.",
      limitation="One-letter words; the packed v mask collapses to the two branch values.")


def _or_code(node, samples, context):
    outs = ls.tight(node, samples, 0, 0, context)
    if not outs:
        return 0
    code = 1
    values = {out["v"].integer() for out in outs if "v" in out}
    if 0 in values:
        code |= 1 << 1
    if 1 in values:
        code |= 1 << 2
    return code


REPEAT_LOCAL = parse_sequence("(v = v + 1)[+]")
table("f55_repeat", "F.5.5", "(v = v + 1)[+]",
      signals=[("v", 2)], horizon=3, context=[("v", 2)],
      actual=lambda samples, context, sel: _repeat_code(samples, context),
      reference="""
        wire [1:0] base = p_v ? c_v : s_v_0;
        wire [1:0] o1=base+2'd1, o2=base+2'd2, o3=base+2'd3;
        always @* begin
          reference_result = (32'd1<<o1) | (32'd1<<(4+o2)) | (32'd1<<(8+o3));
        end
      """,
      why="A positive unbounded repetition threads the context from each piece into the next and "
          "returns the final context; the three possible counts on a three-letter word produce "
          "initial+1, +2 and +3.",
      limitation="Finite word of three letters bounds the unbounded repetition; 2-bit values.")


def _repeat_code(samples, context):
    code = 0
    for end in range(3):
        for outgoing in ls.tight(REPEAT_LOCAL, samples, 0, end, context):
            code |= 1 << (end * 4 + (outgoing["v"].integer() & 3))
    return code


TIGHT_CONTEXT = variants("(v=a) ##1 (w=v)", "(v; (v=a))",
                         "(v=a) or (w=b)", "(v; a) intersect (w; b)")
table("f55_tight_context", "F.5.5", "output domain = flow(input domain, sequence)",
      context=[("v", 1), ("w", 1), ("x", 1)], selectors=2,
      actual=lambda samples, context, sel: mask("vwx", ls.flow(set(context), TIGHT_CONTEXT[sel])),
      reference="""
        always @* begin
          reference_result=p_v | (p_w<<1) | (p_x<<2);
          case(sel)
            0: reference_result=reference_result | 1 | 2;
            3: reference_result=reference_result & ~3;
            default: ;
          endcase
        end
      """,
      why="Tight local satisfaction has an output context whose domain equals flow of the input "
          "domain through the sequence; the packed mask is that domain.",
      limitation="Three-name universe; values are irrelevant to the domain equation.")


# ---------------------------------------------------------------------------
# F.5.6 local neutral satisfaction


def prop_code(node, samples, context, strength="weak", horizon=None):
    result = ls.prop(node, samples, 0, context, strength)
    return ls.result_code(result, len(samples) if horizon is None else horizon)


def top_disable_code(node, disable, samples, context):
    result = ls.prop(node, samples, 0, context)
    for tick in range(len(samples)):
        truth = evaluate(disable, ls.letter_values(samples[tick], context))
        if truth.assertion():
            if result.at is not None and result.at < tick:
                return ls.result_code(result, len(samples))
            return (5 << 4) | tick
    return ls.result_code(result, len(samples))


ASSERTIONS_LOCAL = parse_spec("(v; ((v=a) ##1 (w=v)) |-> (w==1))").body
table("f561_assertions", "F.5.6.1", "assertion statement with a local declaration",
      signals=[("a", 1), ("v", 1), ("w", 1)], horizon=2, context=[("v", 1)],
      actual=lambda samples, context, sel: prop_code(ASSERTIONS_LOCAL, samples, context),
      reference="""
        always @* begin
          reference_result = s_a_0 ? 8'd1 : 8'd17;
        end
      """,
      why="An assertion statement with locals follows the ordinary assertion-statement rules; "
          "the underlying property may nevertheless contain a local declaration and "
          "implication.  The declared v is removed before the antecedent and w threads to the "
          "consequent.",
      limitation="Finite two-tick words; no action blocks or severity.")


LOCAL_BOOLEAN_PROP = [
    prop_node("(v==1) and (a)"),
    prop_node("(v==1) or (b)"),
    prop_node("nexttime[1] (v==1)"),
    prop_node("a until b"),
]
table("f561_boolean", "F.5.6.1", "local and/or/nexttime/until",
      signals=[("a", 1), ("b", 1), ("v", 1)], horizon=3,
      context=[("v", 1)], selectors=2,
      actual=lambda samples, context, sel: prop_code(LOCAL_BOOLEAN_PROP[sel], samples, context),
      reference="""
        reg local_v;
        always @* begin
          local_v=p_v ? c_v : s_v_0;
          case(sel)
            0: reference_result=(local_v && s_a_0) ? 8'd0 : 8'd16;
            1: reference_result=(local_v || s_b_0) ? 8'd0 : 8'd16;
            2: begin
                 local_v=p_v ? c_v : s_v_1;
                 reference_result=local_v ? 8'd1 : 8'd17;
               end
            default: begin
              if (s_b_0) reference_result=8'd0;
              else if (!s_a_0) reference_result=8'd16;
              else if (s_b_1) reference_result=8'd1;
              else if (!s_a_1) reference_result=8'd17;
              else if (s_b_2) reference_result=8'd2;
              else if (!s_a_2) reference_result=8'd18;
              else reference_result=8'd63;
            end
          endcase
        end
      """,
      why="Local and/or apply conjunction/disjunction with the same incoming context; "
          "nexttime uses the suffix and the empty-word truth; until requires a later RHS or "
          "LHS on every suffix.",
      limitation="Two-value finite words; top/bottom letters and infinite suffixes are not built.")


DISABLE_PROP = prop_node("a")
DISABLE_EXPR = parse_spec("disable iff (d) (a)").disable
table("f561_disabled", "F.5.6.1", "disable iff (d) (a)",
      signals=[("a", 1), ("d", 1)], horizon=2,
      actual=lambda samples, context, sel: top_disable_code(DISABLE_PROP, DISABLE_EXPR, samples, context),
      reference="""
        always @* begin
          if (s_d_0) reference_result=8'd80;
          else if (s_a_0) reference_result=8'd0;
          else reference_result=8'd16;
        end
      """,
      why="A plain top-level property is never disabled; a disable before the deciding tick "
          "gives the disabled status while a pass at tick 0 is not revoked.  Parentheses and a "
          "declaration do not change the disabled relation.",
      limitation="Only the Engine-compatible prefix rule is modelled.  The literal "
          "'prefix + infinite top passes, bottom fails' branch for properties that still pass "
          "under infinite bottom is not implemented, and infinite top/bottom words are absent.")


EMPTY_CLOCKED = parse_spec("@(posedge clk) (v==1)").body
table("f561_empty_context", "F.5.6.1", "@(posedge clk) (v==1)",
      signals=[("v", 1)], horizon=1, context=[("v", 1)],
      actual=lambda samples, context, sel: prop_code(EMPTY_CLOCKED, samples, {}, strength="weak"),
      reference="""
        always @* begin
          reference_result=s_v_0 ? 8'd0 : 8'd16;
        end
      """,
      why="An unqualified clocked property starts with the empty local context, so the incoming "
          "context is not visible and the letter's v is read; the clock is inherited as true.",
      limitation="One scalar clock; the incoming-context bits are enumerated but never read.")


IMPLICATION_LOCAL = parse_spec("((v=a) ##1 b)[*1:2] |-> (v==1)").body
table("f561_implication", "F.5.6.1", "local implication",
      signals=[("a", 1), ("b", 1), ("v", 1)], horizon=2, context=[("v", 1)],
      actual=lambda samples, context, sel: prop_code(IMPLICATION_LOCAL, samples, context),
      reference="""
        always @* begin
          if (!s_b_1) reference_result=8'd32;
          else if (s_a_0) reference_result=8'd1;
          else reference_result=8'd17;
        end
      """,
      why="Every tight antecedent match and its output context must satisfy the consequent on "
          "the endpoint suffix with that output context.  The assignment v=a0 is carried into "
          "the consequent; the surviving match is the one-letter prefix.",
      limitation="Two-tick words; only one surviving antecedent multiplicity.")


DECLARATION_PROP = parse_spec("(v; (v==1))").body
table("f561_local_declaration", "F.5.6.1", "(v; (v==1))",
      signals=[("v", 1)], horizon=1, context=[("v", 1)],
      actual=lambda samples, context, sel: prop_code(DECLARATION_PROP, samples, context),
      reference="""
        always @* begin
          reference_result=s_v_0 ? 8'd0 : 8'd16;
        end
      """,
      why="A local property declaration is satisfied exactly when the operand is satisfied with "
          "the declared name removed from the incoming context; it is not the disabled relation.",
      limitation="One name, one tick.")


NOT_LOCAL = [prop_node("not (a)"), prop_node("not ((v==1))")]
table("f561_not", "F.5.6.1", "local not",
      signals=[("a", 1), ("v", 1)], horizon=1, context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: prop_code(NOT_LOCAL[sel], samples, context),
      reference="""
        reg local_v;
        always @* begin
          local_v=p_v ? c_v : s_v_0;
          if (sel==0) reference_result=s_a_0 ? 8'd16 : 8'd0;
          else reference_result=local_v ? 8'd16 : 8'd0;
        end
      """,
      why="not P holds on the dual word with the same input context, so a Boolean P is inverted "
          "at the same tick; parentheses preserve the relation.",
      limitation="Boolean operands only; the explicit dual-word construction is not built.")


STATUS_PROP = parse_spec("disable iff (d) ((a ##1 b))").body
STATUS_DISABLE = parse_spec("disable iff (d) ((a ##1 b))").disable
table("f561_status", "F.5.6.1", "pass/disabled/fail status",
      signals=[("a", 1), ("b", 1), ("d", 1)], horizon=2,
      actual=lambda samples, context, sel: top_disable_code(STATUS_PROP, STATUS_DISABLE, samples, context),
      reference="""
        always @* begin
          if (s_d_0) reference_result=8'd80;
          else if (!s_a_0) reference_result=8'd16;
          else if (s_b_1 && s_d_1) reference_result=8'd81;
          else reference_result=s_b_1 ? 8'd1 : 8'd16;
        end
      """,
      why="Top-level pass and disabled are mutually exclusive and a failure is neither; the "
          "single status code makes the three cases disjoint.",
      limitation="Same prefix+disabling fragment as f561_disabled; infinite top/bottom words "
          "are not constructed.")


STRONG_LOCAL = parse_spec("strong(a ##[1:$] b)").body
table("f561_strong", "F.5.6.1", "local strong",
      signals=[("a", 1), ("b", 1)], horizon=3,
      actual=lambda samples, context, sel: prop_code(STRONG_LOCAL, samples, context, "strong"),
      reference="""
        always @* begin
          if (!s_a_0) reference_result=8'd16;
          else if (s_b_1) reference_result=8'd1;
          else if (s_b_2) reference_result=8'd2;
          else reference_result=8'd79;
        end
      """,
      why="strong(R) needs some prefix 0..j with a tight match; without a witness the finite "
          "word leaves the strong property pending.",
      limitation="Finite three-tick words; no infinite suffix.")


TOP_PROP = [prop_node("(v==a)"), prop_node("(v; (v==a))")]
table("f561_top", "F.5.6.1", "top-level parentheses and local declaration",
      signals=[("a", 1), ("v", 1)], horizon=1, context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: prop_code(TOP_PROP[sel], samples, context),
      reference="""
        reg local_v;
        always @* begin
          local_v=p_v ? c_v : s_v_0;
          reference_result=(sel==0 ? local_v : s_v_0)==s_a_0 ? 8'd0 : 8'd16;
        end
      """,
      why="Plain and parenthesized properties preserve operand satisfaction; a top-level local "
          "declaration removes its name from the incoming context before evaluating the operand.",
      limitation="One tick; the disable-iff top rule is covered only by f561_disabled.")


WEAK_LOCAL = parse_spec("weak(a ##1 b)").body
table("f561_weak", "F.5.6.1", "local weak",
      signals=[("a", 1), ("b", 1)], horizon=3,
      actual=lambda samples, context, sel: prop_code(WEAK_LOCAL, samples, context),
      reference="""
        always @* begin
          if (!s_a_0) reference_result=8'd16;
          else if (!s_b_1) reference_result=8'd17;
          else reference_result=8'd63;
        end
      """,
      why="weak(R) requires every finite prefix extended with infinite top to satisfy strong(R); "
          "for the two-letter sequence the prefix ending at tick 1 already contains b1, so a0=1 "
          "with b1=0 fails there while a0=0 fails at the first prefix.",
      limitation="Infinite top is represented by a finite extension in the evaluator, not by an "
          "explicit top word in RTL.")


FINITE_LOCAL = [parse_spec("strong((v=a) ##[1:$] b)").body,
                parse_spec("weak((v=a) ##1 b)").body]
table("f562_finite", "F.5.6.2", "strong/weak finite-word views with locals",
      signals=[("a", 1), ("b", 1), ("v", 1)], horizon=3,
      context=[("v", 1)], selectors=1,
      actual=lambda samples, context, sel: prop_code(FINITE_LOCAL[sel], samples, context,
                                                     "strong" if sel == 0 else "weak"),
      reference="""
        always @* begin
          if (sel==0) begin
            if (s_b_1) reference_result=8'd1;
            else if (s_b_2) reference_result=8'd2;
            else reference_result=8'd79;
          end else reference_result=s_b_1 ? 8'd63 : 8'd17;
        end
      """,
      why="The weak/strong finite-word definitions are the F.5.3.2 ones with locals permitted: "
          "strong needs an actual tight prefix, weak holds on the finite word when every "
          "top-extended prefix can still match.",
      limitation="Three-tick words; top extension is finite in the evaluator.")


VACUITY_LOCAL = parse_spec("(v; (v==1) |-> b)").body
table("f563_vacuity", "F.5.6.3", "local nonvacuity",
      signals=[("v", 1), ("b", 1)], horizon=1, context=[("v", 1)],
      actual=lambda samples, context, sel: int(
          (lambda result: result.value is True and not result.vacuous)(
              ls.prop(VACUITY_LOCAL, samples, 0, context))),
      reference="""
        always @* begin
          reference_result=(s_v_0 && s_b_0) ? 8'd1 : 8'd0;
        end
      """,
      why="Local nonvacuity follows F.5.3.3; a local declaration evaluates nonvacuity with the "
          "declared name removed from the incoming context, so the antecedent reads the letter's "
          "v rather than the incoming context.",
      limitation="One tick; returns a nonvacuity Boolean rather than a status code.")


# ---------------------------------------------------------------------------
# F.6 past and future references


def history_code(samples, text, ticks, defaults):
    history = History(samples, defaults=defaults)
    expression = parse_spec(text).body
    if expression.op == "bool":
        expression = expression.args[0]
    code = 0
    for tick in ticks:
        code |= history.evaluate(expression, tick).integer() << tick
    return code


table("f6_extended", "F.6", "$past(v) at every letter",
      signals=[("v", 1)], horizon=3,
      actual=lambda samples, context, sel: history_code(samples, "$past(v)", range(3), {"v": Bits("0")}),
      reference="""
        always @* begin
          reference_result=(s_v_0<<1) | (s_v_1<<2);
        end
      """,
      why="An extended expression at a letter can depend on other letters: $past(v) at tick 0 "
          "uses the initial value, at tick 1 uses v0 and at tick 2 uses v1.  The letter-indexed "
          "notation is therefore interpreted with the full trace.",
      limitation="Three letters; 1-bit values; the initial value is the type default 0.")


MATCHED_SEQUENCE = parse_sequence("a ##1 b")
table("f61_triggered", "F.6.1", "T.triggered for T = a ##1 b",
      signals=[("a", 1), ("b", 1)], horizon=3,
      actual=lambda samples, context, sel: (
          (int(bool(ls.tight(MATCHED_SEQUENCE, samples, 0, 1, {}))) << 1)
          | (int(bool(ls.tight(MATCHED_SEQUENCE, samples, 1, 2, {}))) << 2)),
      reference="""
        always @* begin
          reference_result=(s_a_0 && s_b_1)<<1 | (s_a_1 && s_b_2)<<2;
        end
      """,
      why="T.triggered at j holds iff some 0<=i<=j tightly matches T on i..j from the empty "
          "context.  For the two-letter sequence only i=j-1 can match, so j=1 reads a0&b1 and "
          "j=2 reads a1&b2.",
      limitation="The case observes the Boolean; the outgoing-context replacement of passed "
          "names is not separately encoded.  Single clock.")


table("f61_matched", "F.6.1", "T.matched for T = a ##1 b and c = true",
      signals=[("a", 1), ("b", 1)], horizon=3,
      actual=lambda samples, context, sel: (
          int(bool(ls.tight(MATCHED_SEQUENCE, samples, 0, 1, {}))) << 2),
      reference="""
        always @* begin
          reference_result=(s_a_0 && s_b_1)<<2;
        end
      """,
      why="At j a clocked T.matched requires an earlier i<j where triggered holds with the same "
          "contexts and i+1..j tightly matches the first occurrence of the clock c.  With one "
          "always-true clock the first occurrence after i is the single next letter, so j=2 "
          "requires a trigger at i=1, which for T=a##1b is a0&b1.",
      limitation="Literal single-clock reading of the first occurrence of c; T is two letters "
          "and the word has three.  Multi-clock and context-replacing cases are not covered.")




table("f62_past_global", "F.6.2", "$past_gclk(v)",
      signals=[("v", 1)], horizon=3,
      actual=lambda samples, context, sel: history_code(
          samples, "$past_gclk(v)", range(3), {"v": Bits("1")}),
      reference="""
        always @* begin
          reference_result=1 | (s_v_0<<1) | (s_v_1<<2);
        end
      """,
      why="$past_gclk(e) at letter j>0 is e at j-1, the immediately preceding global clock "
          "tick; at j=0 it is e from the initial values (1).",
      limitation="Three letters; 1-bit values; the initial value is supplied as 1.")


table("f63_future", "F.6.3", "$future_gclk(v)",
      signals=[("v", 1)], horizon=3,
      actual=lambda samples, context, sel: (
          history_code(samples, "$future_gclk(v)", [0, 1], {"v": Bits("0")})),
      reference="""
        always @* begin
          reference_result=(s_v_1) | (s_v_2<<1);
        end
      """,
      why="$future_gclk(e) at letter j<|w|-1 is e at j+1, the next global clock tick; the "
          "value at the final letter is undefined and is not encoded.",
      limitation="Only the defined positions j=0,1 of a three-letter word are compared; the "
          "undefined final position is deliberately outside the table.")


# ---------------------------------------------------------------------------
# F.7 recursive properties


def _b(name):
    return Node("bool", (Node("name", value=name),))


def _c(name, *arguments):
    return Node("bool", (Node("call", tuple(arguments), name),))


def _and(left, right):
    return Node("and", (left, right))


def _or(left, right):
    return Node("or", (left, right))


def _not(value):
    return Node("not", (value,))


def _next(value, count=1):
    return Node("nexttime", (value,), count)


RECURSIVE = {
    "p": ls.PropertyDefinition("p", (), _or(_and(_b("a"), _next(_c("p"))), _b("b"))),
}


def _approx_prop(depth):
    return ls.approximation(RECURSIVE, "p", depth)


table("f7_approx_base", "F.7", "zero-fold approximation of p",
      signals=[("a", 1), ("b", 1)], horizon=2,
      actual=lambda samples, context, sel: prop_code(_approx_prop(0), samples, context),
      reference="""
        always @* reference_result=8'd32;
      """,
      why="The zero-fold approximation copies the property signature and replaces the body by "
          "true; the result is vacuous success at tick 0 for every word.",
      limitation="One recursive property and a two-letter word; signatures with formals are "
          "not separately varied.")


table("f7_approx_step", "F.7", "two-fold approximation of p",
      signals=[("a", 1), ("b", 1)], horizon=3,
      actual=lambda samples, context, sel: prop_code(_approx_prop(2), samples, context),
      reference="""
        always @* begin
          if (s_b_0) reference_result=8'd0;
          else if (!s_a_0) reference_result=8'd16;
          else if (s_b_1) reference_result=8'd1;
          else if (s_a_1) reference_result=8'd2;
          else reference_result=8'd17;
        end
      """,
      why="For k=2 the recursive instance is replaced by the k-1 approximation while the "
          "nonrecursive b instance keeps its body; p2 is b0 or (a0 and (b1 or (a1 and true))).",
      limitation="Three letters; the approximation depth and word length are finite.")


table("f7_all_approx", "F.7", "all positive-depth approximations of p",
      signals=[("a", 1), ("b", 1)], horizon=3,
      actual=lambda samples, context, sel: int(all(
          ls.prop(_approx_prop(depth), samples, 0, context).value is not False
          for depth in (1, 2, 3))),
      reference="""
        always @* begin
          reference_result=(s_b_0 || (s_a_0 && (s_b_1 || (s_a_1 && (s_b_2 || s_a_2))))) ? 8'd1 : 8'd0;
        end
      """,
      why="A recursive property including top holds with the local context exactly when every "
          "positive-depth approximation holds; the approximants are monotone, so checking "
          "depths 1..3 is the finite form of the conjunction.",
      limitation="Depths 1..3 only; the infinite conjunction is not built.")


DEPENDENCY = {
    "p": ls.PropertyDefinition("p", ("v",), _or(_and(_b("a"), _c("q", _c("s"))), _c("r"))),
    "q": ls.PropertyDefinition("q", ("w",), _and(_b("b"), _c("p", _b("b")))),
    "r": ls.PropertyDefinition("r", (), _b("c")),
    "s": ls.PropertyDefinition("s", (), _b("d")),
}


def _edge_mask(definitions):
    order = sorted(definitions)
    edges = ls.dependency_edges(definitions)
    return sum(1 << (order.index(left) * len(order) + order.index(right))
               for left, right in edges)


table("f7_dependency", "F.7", "property dependency graph",
      signals=[], selectors=0,
      actual=lambda samples, context, sel: _edge_mask(DEPENDENCY),
      reference="""
        always @* reference_result=32'd30;
      """,
      why="The graph has an edge p->q for the instance in p, p->r for the direct instance, "
          "p->s for the instance q(s) inside an actual argument of p, and q->p.  No other "
          "edge exists, giving mask 30 in the order p,q,r,s.",
      limitation="Four named properties; the actual-argument edge is a direct call, not an "
          "arbitrary expression tree.")


RECURSIVE_GROUP = {
    "p": ls.PropertyDefinition("p", (), _and(_b("a"), _next(_c("q"), 1))),
    "q": ls.PropertyDefinition("q", (), _and(_b("b"), _next(_c("p"), 2))),
    "r": ls.PropertyDefinition("r", (), _and(_b("c"), _next(_c("r"), 1))),
}


table("f7_recursive", "F.7", "recursive SCC and edge weights",
      signals=[], selectors=0,
      actual=lambda samples, context, sel: (
          sum(1 << ["p", "q", "r"].index(name)
              for name in ls.recursive_members(RECURSIVE_GROUP))
          | (ls.edge_weights(RECURSIVE_GROUP)[("p", "q")] << 3)
          | (ls.edge_weights(RECURSIVE_GROUP)[("q", "p")] << 6)
          | (ls.edge_weights(RECURSIVE_GROUP)[("r", "r")] << 9)),
      reference="""
        always @* reference_result=32'd655;
      """,
      why="p and q form a nontrivial strongly connected component and r is self-recursive, so "
          "all three are recursive members.  The p->q weight is one time step, q->p is two and "
          "r->r is one; the packed code is 7 | 1<<3 | 2<<6 | 1<<9 = 655.",
      limitation="Weights are nexttime counts in three small definitions; other temporal "
          "operators that also guarantee steps are not enumerated.")


ARGUMENT = {
    "p": ls.PropertyDefinition("p", ("v",), _c("p", _b("v"))),
    "q": ls.PropertyDefinition("q", ("v",),
                               _c("q", Node("binary", (_b("v"), Node("literal", value="1")), "+"))),
    "r": ls.PropertyDefinition("r", ("v",), _c("s", Node("literal", value="1"))),
    "s": ls.PropertyDefinition("s", ("w",), _b("a")),
}


table("f7_restriction_argument", "F.7", "recursive actual argument restriction",
      signals=[], selectors=0,
      actual=lambda samples, context, sel: sum(
          1 << ["p", "q", "r", "s"].index(name) for name in ls.argument_errors(ARGUMENT)),
      reference="""
        always @* reference_result=32'd2;
      """,
      why="p calls p(v), where v is a formal of the enclosing property (allowed); r calls "
          "s(1), which contains no enclosing formal (allowed); q calls q(v+1), which contains v "
          "but is neither a bare enclosing formal nor a called-property formal (invalid), so "
          "the error mask is bit 1.",
      limitation="A syntactic check over one formal per definition; type/local-variable "
          "declarations are not modelled.")


DISABLE_DEFS = {
    "p": ls.PropertyDefinition("p", (), _and(_b("a"), _next(_c("p"))), disable=True),
    "q": ls.PropertyDefinition("q", (), _b("b"), disable=True),
}
table("f7_restriction_disable", "F.7", "recursive declarations cannot use disable iff",
      signals=[], selectors=0,
      actual=lambda samples, context, sel: sum(
          1 << ["p", "q"].index(name) for _, name in ls.restriction_errors(DISABLE_DEFS)),
      reference="""
        always @* reference_result=32'd1;
      """,
      why="p is recursive and therefore may not use disable iff; q is nonrecursive and may, "
          "so only p is an error.",
      limitation="Two definitions; only the disable flag is checked.")


NOT_DEFS = {
    "p": ls.PropertyDefinition("p", (), _and(_b("a"), _next(_c("p")))),
    "q": ls.PropertyDefinition("q", (), _not(_c("p"))),
    "r": ls.PropertyDefinition("r", (), _not(_c("s"))),
    "s": ls.PropertyDefinition("s", (), _b("a")),
}
table("f7_restriction_not", "F.7", "not of a recursive instance",
      signals=[], selectors=0,
      actual=lambda samples, context, sel: sum(
          1 << ["p", "q", "r", "s"].index(name) for name in ls.not_errors(NOT_DEFS)),
      reference="""
        always @* reference_result=32'd2;
      """,
      why="q applies not to an instance of the recursive p, which is illegal; r applies not to "
          "the nonrecursive s, which is legal.  The error mask is bit 1.",
      limitation="Direct not operand with a reachable recursive call; nested property "
          "operators are traversed but not separately tested.")


TIME_GRAPH = {
    "positive": {
        "p": ls.PropertyDefinition("p", (), _and(_b("a"), _next(_c("q"), 1))),
        "q": ls.PropertyDefinition("q", (), _and(_b("b"), _next(_c("p"), 2))),
    },
    "zero": {
        "r": ls.PropertyDefinition("r", (), _and(_b("c"), _next(_c("r"), 0))),
    },
}
table("f7_restriction_time", "F.7", "every graph cycle has positive total weight",
      signals=[], selectors=1,
      actual=lambda samples, context, sel: ls.min_cycle_weight(
          TIME_GRAPH["positive" if sel == 0 else "zero"]),
      reference="""
        always @* reference_result=sel ? 0 : 3;
      """,
      why="The p<->q cycle has weights 1 and 2 and therefore total 3, which is strictly "
          "positive; the r self-loop has weight 0 and violates the restriction.",
      limitation="Only nexttime weights are counted; an empty cycle set is not distinguished "
          "from an unrestricted graph.")
