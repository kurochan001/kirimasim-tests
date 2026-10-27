"""Formal cases for F.3.4.2.4/F.3.4.5/F.5.1.1 assignments and accept_on.

Each entry compares an executable reading of the clause with an independently
written RTL reference.  The RTL never calls the parser, ``localsem`` or the
derivative engine; it enumerates the clause's right-hand side (fusion,
nesting, clock transform, top/bottom extension) directly.

Word layout in ``table()`` is the one used by ``f56_cases``: every signal has
one sample per tick, then the incoming local context (presence bit plus value
per name), then the non-temporal inputs and the selector.
"""

from .f_extra_common import table  # noqa: F401  (registers into f_extra_common.TABLES)

from . import localsem as ls
from .parser import parse_sequence
from .values import Bits


TOP = Bits("1")
BOTTOM = Bits("0")


def pack_context(context, names, base=1):
    """Packed (presence, value) pairs, one 2-bit slot per name after ``base``."""
    code = base
    for index, name in enumerate(names):
        if name in context:
            code |= 1 << (2 * index + 1)
            code |= context[name].integer() << (2 * index + 2)
    return code


def _merge_unique(contexts):
    seen, result = set(), []
    for context in contexts:
        key = tuple(sorted((name, raw.bits) for name, raw in context.items()))
        if key not in seen:
            seen.add(key)
            result.append(context)
    return result


def materialize(word, names, tail, extra=4):
    """F.5.3.2 extension: append ``top`` or ``bottom`` letters to a word."""
    filler = TOP if tail == "top" else BOTTOM
    return list(word) + [{name: filler for name in names} for _ in range(extra)]


def match_exists(sequence, word, context):
    """A sequence matches the (possibly extended, finite) word from tick 0."""
    return any(ls.tight(sequence, word, 0, end, context) for end in range(len(word)))


# ---------------------------------------------------------------------------
# F.3.4.2.4  (R, v = e) is R ##0 (1, v = e); several assignments fuse in order


ASSIGN_SEQUENCE = parse_sequence("a ##1 b")
ASSIGN_LISTS = (
    (("v", "a"),),
    (("v", "a"), ("w", "v")),
    (("w", "v"), ("v", "a")),
    (("w", "v"),),
)


def assign_code(samples, context, sel):
    """Apply the listed assignments at the endpoint of R, in source order.

    This is the left-hand side of the clause: the assignment to ``v`` only
    happens when R has already matched, and the next assignment sees the
    context produced by the previous one (both ends are tick 1 because the
    fusion delay is zero).
    """
    end = len(samples) - 1
    code = 0
    for outgoing in ls.tight(ASSIGN_SEQUENCE, samples, 0, end, context):
        produced = dict(outgoing)
        for name, expression in ASSIGN_LISTS[sel]:
            produced[name] = ls.letter_values(samples[end], produced)[expression]
        code |= pack_context(produced, ["v", "w"])
    return code


table(
    "f342_assign_fusion",
    "F.3.4.2.4",
    "(a ##1 b, v = a[, w = v]) = (a ##1 b) ##0 (1, v = a) [##0 (1, w = v)]",
    signals=[("a", 1), ("b", 1), ("v", 1)], horizon=2,
    context=[("v", 1), ("w", 1)], selectors=2,
    actual=assign_code,
    reference="""
      reg matched, pv, vv, pw, ww;
      always @* begin
        matched = s_a_0 && s_b_1;
        pv = 0; vv = 0; pw = 0; ww = 0;
        if (matched) begin
          case(sel)
            0: begin
                 // (R, v=a) is R ##0 (1, v=a): one tick-1 assignment.
                 pv = 1; vv = s_a_1;
                 pw = p_w; ww = c_w;
               end
            1: begin
                 // (R, v=a, w=v): the second assignment reads the fused v.
                 pv = 1; vv = s_a_1;
                 pw = 1; ww = s_a_1;
               end
            2: begin
                 // (R, w=v, v=a): the second assignment still reads old v.
                 pw = 1; ww = p_v ? c_v : s_v_1;
                 pv = 1; vv = s_a_1;
               end
            default: begin
                 // A lone (R, w=v): v is not assigned, so w reads old v.
                 pv = p_v; vv = c_v;
                 pw = 1; ww = p_v ? c_v : s_v_1;
               end
          endcase
        end
        reference_result = matched | (pv<<1) | ((pv?vv:0)<<2)
                         | (pw<<3) | ((pw?ww:0)<<4);
      end
    """,
    why="The clause rewrites a sequence-match assignment into a zero-delay fusion "
        "with the one-letter sequence (1, v=e).  The left-hand model applies the "
        "assignments at the endpoint of R (tick 1): the value expression sees the "
        "endpoint letter and the context produced by R, and each later assignment "
        "sees the bindings of the earlier ones.  Variant 1 (v then w=v) therefore "
        "stores a1 into w, while variant 2 (w=v then v=a) stores the old v.  The "
        "RTL enumerates the fused right-hand side separately for the four listed "
        "variants, and both sides agree on every 12-bit input word.",
    limitation="Two ticks, one-bit values, R fixed to a ##1 b and at most two "
                "assignments; further assignments and other sequences follow the "
                "same successive-fusion rule but are not enumerated.",
)


# ---------------------------------------------------------------------------
# F.3.4.5  multiple local declarations = source-order nesting


DECL_SEQUENCE = parse_sequence("(x = v) ##1 (y = w)")
DECL_LISTS = (
    (("v", "a"), ("w", "v")),
    (("v", None), ("w", "a")),
    (("v", "a"), ("w", None)),
    (("w", "v"), ("v", "a")),
)


def declare_nested(declarations, word, start, end, context):
    """Nest the declarations in source order, keeping optional initializers."""
    if not declarations:
        return ls.tight(DECL_SEQUENCE, word, start, end, context)
    name, initializer = declarations[0]
    outer = context.get(name)
    inner = dict(context)
    inner.pop(name, None)
    if initializer is not None:
        # The initializer is evaluated once at the declaration point; it sees
        # the letters of the start tick and the declarations already nested
        # outside it (but not the name being declared).
        inner[name] = ls.letter_values(word[start], inner)[initializer]
    results = []
    for outgoing in declare_nested(declarations[1:], word, start, end, inner):
        produced = dict(outgoing)
        produced.pop(name, None)
        if outer is not None:
            produced[name] = outer
        results.append(produced)
    return _merge_unique(results)


def declaration_code(samples, context, sel):
    end = len(samples) - 1
    code = 0
    for outgoing in declare_nested(DECL_LISTS[sel], samples, 0, end, context):
        code |= (1
                 | (1 << 1) | (outgoing["x"].integer() << 2)
                 | (1 << 3) | (outgoing["y"].integer() << 4)
                 | (0 if "v" not in outgoing else
                    (1 << 5) | (outgoing["v"].integer() << 6))
                 | (0 if "w" not in outgoing else
                    (1 << 7) | (outgoing["w"].integer() << 8)))
    return code


table(
    "f345_declaration_nest",
    "F.3.4.5",
    "(int v = a, w = v; (x = v) ##1 (y = w)) = (int v = a; (int w = v; "
    "(x = v) ##1 (y = w)))",
    signals=[("a", 1), ("v", 1), ("w", 1)], horizon=2,
    context=[("v", 1), ("w", 1)], selectors=2,
    actual=declaration_code,
    reference="""
      reg px, xx, py, yy, pv, vv, pw, ww;
      always @* begin
        // The body (x = v) ##1 (y = w) always matches: both operands are
        // assignments.  Only the initial values of the declarations differ.
        px = 1; py = 1; pv = p_v; vv = c_v; pw = p_w; ww = c_w;
        case(sel)
          0: begin
               // v = a, then w = v reads the declared v.
               xx = s_a_0; yy = s_a_0;
             end
          1: begin
               // v has no initializer, so the body reads the letter v;
               // w = a keeps its initializer.
               xx = s_v_0; yy = s_a_0;
             end
          2: begin
               // w has no initializer, so the body reads the letter w at the
               // tick where the second assignment occurs (tick 1).
               xx = s_a_0; yy = s_w_1;
             end
          default: begin
               // w is declared first: w = v still sees the outer v, then
               // v = a binds the inner v.
               xx = s_a_0; yy = p_v ? c_v : s_v_0;
             end
        endcase
        reference_result = 1 | (px<<1) | ((px?xx:0)<<2)
                         | (py<<3) | ((py?yy:0)<<4)
                         | (pv<<5) | ((pv?vv:0)<<6)
                         | (pw<<7) | ((pw?ww:0)<<8);
      end
    """,
    why="F.3.4.5 says a list of local declarations is equivalent to nesting "
        "them in source order, with initializers preserved.  The left-hand model "
        "nests one declaration at a time; the initializer of a later declaration "
        "therefore sees the bindings of earlier ones, while an uninitialized "
        "declaration hides the incoming value.  The outer v and w are restored "
        "when each scope closes, and the body's assignments to x and y survive.  "
        "Variant 2 shows that an uninitialized w stays hidden, so the body reads "
        "the sampled w at the tick of the assignment; variant 3 reverses the "
        "source order and shows that w then reads the outer v instead of the "
        "freshly initialized inner v.",
    limitation="Sequence category only (not property declarations), two ticks, "
                "one-bit values, two declarations, initializers limited to a "
                "letter or a previously visible name; type declarations are not "
                "distinguished from untyped ones.",
)


# ---------------------------------------------------------------------------
# F.5.1.1  Ts(local sampling assignment) = Ts(1,c) ##0 assignment


SAMPLING_CLOCK = [("v", "a"), ("w", "v")]


def sampling_code(samples, context, sel):
    """First inherited-clock letter, then apply the assignment on that letter."""
    age = next((tick for tick in range(len(samples))
                if samples[tick]["c"].integer()), None)
    if age is None:
        return 0
    name, expression = SAMPLING_CLOCK[sel]
    produced = dict(context)
    produced[name] = ls.letter_values(samples[age], produced)[expression]
    code = age + 1
    for index, local in enumerate(["v", "w"]):
        if local in produced:
            code |= 1 << (4 + 2 * index)
            code |= produced[local].integer() << (5 + 2 * index)
    return code


table(
    "f511_sampling_assign",
    "F.5.1.1",
    "Ts((v = a), c) = Ts(1, c) ##0 (v = a)",
    signals=[("c", 1), ("a", 1), ("v", 1)], horizon=3,
    context=[("v", 1)], selectors=1,
    actual=sampling_code,
    reference="""
      wire [1:0] age = s_c_0 ? 2'd0 : s_c_1 ? 2'd1 : s_c_2 ? 2'd2 : 2'd3;
      reg pv, vv, pw, ww;
      always @* begin
        pv = p_v; vv = c_v; pw = 0; ww = 0;
        if (age == 2'd3) begin
          // Ts(1,c) has no ending letter when c is false on the whole word.
          reference_result = 0;
        end else begin
          case(sel)
            0: begin
                 // Ts(1,c) ends on the first c letter; the fused assignment
                 // then stores a sampled on that same letter.
                 pv = 1;
                 vv = (age == 2'd0) ? s_a_0 : (age == 2'd1) ? s_a_1 : s_a_2;
               end
            default: begin
                 // The fused assignment to w reads v with the clock-letter
                 // context: an incoming v wins over the sampled letter v.
                 pw = 1;
                 ww = p_v ? c_v :
                      (age == 2'd0) ? s_v_0 : (age == 2'd1) ? s_v_1 : s_v_2;
               end
          endcase
          reference_result = (age + 2'd1) | (pv<<4) | ((pv?vv:0)<<5)
                           | (pw<<6) | ((pw?ww:0)<<7);
        end
      end
    """,
    why="Ts of a local sampling assignment is defined as the clock transform of "
        "the constant 1 fused (##0) with the assignment.  Ts(1,c) consumes the "
        "leading !c letters and ends on the first letter where c holds; the "
        "assignment is applied to that same letter, so its expression is sampled "
        "there and its name is added to the outgoing local context.  If c never "
        "holds, Ts(1,c) has no ending and the assignment contributes nothing.  "
        "The RTL implements Ts(1,c) as the first-c index and then the fused "
        "assignment; the left-hand model evaluates the assignment directly on "
        "that index.",
    limitation="Three ticks, one clock and one-bit values; only the assignment "
                "forms (v=a) and (w=v) are enumerated.  The surrounding "
                "concatenation/repetition distribution is covered by the "
                "existing f51_ts_* cases.",
)


# ---------------------------------------------------------------------------
# F.5.3.1  accept_on(b) P with infinite-top prefix extension


ACCEPT_SEQUENCE = parse_sequence("a ##[1:2] b")
ACCEPT_NAMES = ["a", "b", "d"]


def accept_code(samples, context, sel):
    """P holds, or an abort letter's preceding prefix + infinite top holds P."""
    assert not context
    aborts = [row["d"].integer() for row in samples]
    # First branch: P on the finite word, read through the bottom extension
    # (F.5.3.2 strong view), so no top letter can rescue it.
    if match_exists(ACCEPT_SEQUENCE, materialize(samples, ACCEPT_NAMES, "bottom"), {}):
        return 3
    for index in range(len(samples)):
        if not aborts[index]:
            continue
        prefix = materialize(samples[:index], ACCEPT_NAMES, "top")
        if match_exists(ACCEPT_SEQUENCE, prefix, {}):
            return 1 | (index << 2)
    return 0


table(
    "f531_accept_extension",
    "F.5.3.1",
    "accept_on(d) (a ##[1:2] b) on a three-letter word",
    signals=[("a", 1), ("b", 1), ("d", 1)], horizon=3,
    actual=accept_code,
    reference="""
      always @* begin
        if (s_a_0 && (s_b_1 || s_b_2))
          // P holds on the word itself (delay 1 or 2).
          reference_result = 32'd3;
        else if (s_d_0)
          // Empty prefix followed by top: top plays both a and b.
          reference_result = 32'd1;
        else if (s_a_0 && s_d_1)
          // Prefix a0 followed by top: top is the b one tick later.
          reference_result = 32'd5;
        else if (s_a_0 && s_d_2)
          // Prefix a0 b1 followed by top: delay 1 uses b1, delay 2 uses top.
          reference_result = 32'd9;
        else
          reference_result = 32'd0;
      end
    """,
    why="The accept_on definition is a disjunction: either the operand holds on "
        "the finite word, or some letter i in 0..|w|-1 satisfies the abort "
        "condition and the prefix strictly before i, followed by infinite top, "
        "satisfies the operand.  With P = a ##[1:2] b and three letters, the i=0 "
        "empty prefix is extended entirely with top so it always matches, while "
        "i=1 and i=2 both reduce to a0 because the top letter can play b within "
        "the allowed delay.  The "
        "RTL enumerates those three positions and the direct branch; the "
        "left-hand model searches the positions in order.",
    limitation="Three ticks, one-bit signals, P fixed to a bounded sequence and "
                "evaluated with the strong finite view (w followed by bottom) "
                "for the direct branch; the full neutral relation over arbitrary "
                "properties is not constructed.  The deciding branch/index is "
                "part of the result code.",
)


# ---------------------------------------------------------------------------
# F.5.3.2  weak = top extension, strong = bottom extension


EXTENSION_SEQUENCE = parse_sequence("a ##[1:2] b")
EXTENSION_NAMES = ["a", "b"]


def extension_code(samples, context, sel):
    if context:
        raise AssertionError("the extension table has no local context")
    word = list(samples)[:sel]
    weak = match_exists(EXTENSION_SEQUENCE, materialize(word, EXTENSION_NAMES, "top"), {})
    strong = match_exists(EXTENSION_SEQUENCE, materialize(word, EXTENSION_NAMES, "bottom"), {})
    return int(weak) | (int(strong) << 1)


table(
    "f532_finite_extension",
    "F.5.3.2",
    "weak/strong satisfaction of a ##[1:2] b by words of length 0..3",
    signals=[("a", 1), ("b", 1)], horizon=3, selectors=2,
    actual=extension_code,
    reference="""
      reg weak, strong;
      always @* begin
        case(sel)
          0: begin
               // Empty word: top makes a0 and the delay-1 b true; bottom
               // makes the b false.
               weak = 1; strong = 0;
             end
          1: begin
               // One letter: the only real letter is a0; top can supply b,
               // bottom cannot.
               weak = s_a_0; strong = 0;
             end
          2: begin
               // Two letters: weak is a0 (top after b1), strong needs b1.
               weak = s_a_0; strong = s_a_0 && s_b_1;
             end
          default: begin
               // Three letters: the delay is bounded by two, so top can no
               // longer supply b; weak and strong both need b1 or b2.
               weak = s_a_0 && (s_b_1 || s_b_2);
               strong = s_a_0 && (s_b_1 || s_b_2);
             end
        endcase
        reference_result = weak | (strong<<1);
      end
    """,
    why="F.5.3.2 defines weak satisfaction of a finite word as neutral "
        "satisfaction after appending infinite top, and strong satisfaction as "
        "neutral satisfaction after appending infinite bottom.  The selector "
        "chooses the word length 0,1,2,3 (the empty word is the length-0 case).  "
        "For a ##[1:2] b, top can play the b only within the two allowed delays: "
        "weak is true for the empty word, a0 for length 1, a0 for length 2 (top "
        "is the delay-2 b) and a0&(b1|b2) for length 3.  Bottom makes the b "
        "false, so strong needs a real b: b1 for length 2, and b1 or b2 for "
        "length 3.",
    limitation="Word lengths 0..3 with two one-bit signals; the infinite "
                "extensions are materialised as four extra top/bottom letters, "
                "which decides this bounded sequence exactly.  Unbounded "
                "temporal operators and four-state values are out of scope.",
)


# ---------------------------------------------------------------------------
# F.5.6.1  local accept_on keeps L0 in the second branch


LOCAL_ACCEPT_SEQUENCE = parse_sequence("(v == 0) ##1 b")
LOCAL_ACCEPT_NAMES = ["b", "d", "v"]


def local_accept_code(samples, context, sel):
    """Same rule with L0, plus the local first-branch no-abort condition."""
    aborts = [row["d"].integer() for row in samples]
    if (match_exists(LOCAL_ACCEPT_SEQUENCE,
                     materialize(samples, LOCAL_ACCEPT_NAMES, "bottom"), context)
            and not any(aborts)):
        return 3
    for index in range(len(samples)):
        if not aborts[index]:
            continue
        prefix = materialize(samples[:index], LOCAL_ACCEPT_NAMES, "top")
        if match_exists(LOCAL_ACCEPT_SEQUENCE, prefix, context):
            return 1 | (index << 2)
    return 0


table(
    "f561_accept_context",
    "F.5.6.1",
    "w, L0 |= accept_on(d) ((v == 0) ##1 b)",
    signals=[("b", 1), ("d", 1), ("v", 1)], horizon=3,
    context=[("v", 1)],
    actual=local_accept_code,
    reference="""
      // incoming L0: p_v says whether v is bound, c_v is its value.  The
      // sampled letter v is only used when L0 does not bind v.
      wire veff = p_v ? c_v : s_v_0;
      always @* begin
        if (!veff && s_b_1 && !s_d_0 && !s_d_1 && !s_d_2)
          // Direct branch: the operand holds and no letter aborts.
          reference_result = 32'd3;
        else if (p_v && !c_v && s_d_0)
          // Abort at tick 0: the empty prefix is all top.  Only an L0 that
          // binds v to 0 can make (v==0) true there; without L0 the top
          // letter v=1 would fail, so this branch needs p_v/c_v directly.
          reference_result = 32'd1;
        else if (!veff && s_d_1)
          // Abort at tick 1: prefix w0 followed by top, evaluated under L0.
          reference_result = 32'd5;
        else if (!veff && s_b_1 && s_d_2)
          // Abort at tick 2: prefix w0 w1 followed by top, under L0.  The
          // sequence fixes b one tick after the prefix start, so the top
          // extension cannot supply it: b1 must already be real.
          reference_result = 32'd9;
        else
          reference_result = 32'd0;
      end
    """,
    why="The local accept_on rule has two branches.  The direct branch needs the "
        "operand to hold under L0 and no letter of the word to satisfy the abort "
        "expression.  The abort branch takes a letter i where d holds and asks "
        "the prefix before i, followed by infinite top, to satisfy the operand "
        "under the same incoming context L0 (not the empty context).  With "
        "P = (v==0) ##1 b, the top letter of an extension is overridden by L0 "
        "when L0 binds v.  An abort at tick 0 has only the empty prefix, so it "
        "rescues exactly when p_v is set and c_v is 0; a tick-1 abort reads the "
        "sampled v0 through L0 when it is not bound; a tick-2 abort additionally "
        "needs the real b at tick 1 because the delay is fixed at one.  Leaving "
        "L0 out of the second branch would let the top letter v=1 into (v==0) "
        "and change the tick-0 branch in particular.",
    limitation="Three ticks, one local name and one-bit values; P is a fixed "
                "bounded sequence.  The first branch uses the strong finite view "
                "(bottom extension) and the abort branch the top extension; a "
                "general recursive neutral-satisfaction engine is not built.  "
                "The result code also records which branch/position decided.",
)
