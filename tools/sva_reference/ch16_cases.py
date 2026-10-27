"""Formal cases for the remaining Chapter 16 SVA requirements.

Each entry is a finite table like the Annex F.5 tables: the ``actual`` side is
the existing tool implementation (``localsem`` for local variables, ``engine``
for unclocked property operators, ``clocking`` for the F.5.1.1/F.5.1.2 clock
rewrite), and the ``reference`` side is RTL written directly from the 16.x
clause text.  No reference calls the parser, the derivative engine, the local
semantics model or the evaluator.

The cases cover the requirements that the Annex F suite did not already pin
down: the 16.10 lost-flow rule, the 16.12.11 lower always bound, the 16.12
until/implies precedence level, the 16.13.3 adjoint identities and the
16.16.1 semantic-leading-clock rules that a single scalar clock can expose.
Cases needing two distinct clock expressions in a source property are limited
to the clock rewrite: the repository parser rejects a second clock control
(``Unsupported: multiple clock controls``), so those cases build the
F.5.1.1 syntax tree directly and state that limitation.
"""

from . import clocking as ck
from . import localsem as ls
from .engine import Engine
from .f_extra_common import table
from .parser import parse_sequence, parse_spec

STATUS = {"success": 0, "failure": 1, "vacuous": 2, "holds": 3, "pending": 4,
          "disabled": 5}


# ---------------------------------------------------------------------------
# shared helpers


def integers(samples):
    """Rows of Bits to rows of plain integers (clocking.py works on ints)."""
    return {name: [row[name].integer() for row in samples]
            for name in samples[0]}


def counts(node, clock, values, horizon):
    """Match counts per age, the F.5.1.1 streaming view of a sequence."""
    result = [0] * (horizon + 1)
    for end in ck._sequence_ends(node, clock, values, 0):
        age = end + 1
        if 0 <= age <= horizon:
            result[age] += 1
    return result


def pack(counts_list):
    """Two bits per age: at most two matches of a one-atom operand per age."""
    code = 0
    for age, amount in enumerate(counts_list):
        code |= (amount & 3) << (2 * age)
    return code


def earliest(node, clock, values, horizon):
    ends = ck._sequence_ends(node, clock, values, 0)
    return min(ends) if ends else 15


def attempt_code(expression, samples):
    attempt = Engine(samples).property(expression)
    return (STATUS[attempt.status] << 4) | (15 if attempt.tick is None
                                            else attempt.tick)


def class_code(node, samples, strength="weak"):
    """Success/witness=1, hold=2, failure=0 for a finite-word property."""
    result = ls.prop(node, samples, 0, {}, strength)
    if result.value is True:
        return 1
    if result.value is False:
        return 0
    return 2


# ---------------------------------------------------------------------------
# 16.10 local-variable flow


LOST = [parse_sequence("(v; ((v=b) ##1 d))"),
        parse_sequence("((v=b) ##1 d)")]


def lost_code(samples, context, sel):
    outgoing = ls.tight(LOST[sel], samples, 0, len(samples) - 1, dict(context))
    if not outgoing:
        return 0
    result = 1
    if "v" in outgoing[0]:
        result |= 2 | (outgoing[0]["v"].integer() << 2)
    return result


table("ch16_local_lost_flow", "16.10",
      "a local that does not flow out of a subsequence is unassigned at its end",
      signals=[("b", 1), ("d", 1)], horizon=2, context=[("v", 1)],
      selectors=1,
      actual=lost_code,
      reference="""
        always @* begin
          reference_result=0;
          if (sel==0) begin
            // (v; ((v=b) ##1 d)): the declaration ends with v restored to the
            // incoming value, so the inner assignment never flows out.
            if (s_d_1) begin
              reference_result=1;
              if (p_v) reference_result=1 | 2 | (c_v ? 4 : 0);
            end
          end else begin
            // ((v=b) ##1 d): without a declaration v flows out with the
            // assigned value.
            if (s_d_1) reference_result=1 | 2 | (s_b_0 ? 4 : 0);
          end
        end
      """,
      why="tight() returns the outgoing context at the composite end.  A local "
          "declaration removes its name from the inner context and restores the "
          "outer value, so the assignment inside the declaration is lost; with no "
          "outer value the name is absent (unassigned).  The undeclared variant "
          "shows the assigned value flowing out.",
      limitation="Two-tick words, one local, one-bit values.  Reading an "
                 "unassigned local is not modelled (the value would be X).")


# ---------------------------------------------------------------------------
# 16.12.11 always range


ALWAYS = ["always[0:2] a", "always[2:4] a", "always[0:$] a", "always[1:1] a"]


def always_code(samples, context, sel):
    return attempt_code(ALWAYS[sel], samples)


table("ch16_always_range", "16.12.11",
      "always[n:m] checks every existing tick in the range and does not require "
      "the upper ticks to exist",
      signals=[("a", 1)], horizon=3, selectors=2,
      actual=always_code,
      reference="""
        always @* begin
          reference_result=0;
          case(sel)
            0: begin
              // always[0:2] on three letters: the range is complete, so an
              // all-true range is a success at the last tick, not a hold.
              if (!s_a_0) reference_result=8'h10;
              else if (!s_a_1) reference_result=8'h11;
              else if (!s_a_2) reference_result=8'h12;
              else reference_result=8'h02;
            end
            1: begin
              // always[2:4]: only tick 2 exists; the missing 3 and 4 are not
              // required, so a true tick 2 holds.
              if (!s_a_2) reference_result=8'h12;
              else reference_result=8'h3f;
            end
            2: begin
              // always[0:$]: the unbounded upper bound leaves an open
              // obligation, so an all-true range holds.
              if (!s_a_0) reference_result=8'h10;
              else if (!s_a_1) reference_result=8'h11;
              else if (!s_a_2) reference_result=8'h12;
              else reference_result=8'h3f;
            end
            default: reference_result=s_a_1 ? 8'h01 : 8'h11;
          endcase
        end
      """,
      why="The lower bound 0 is included, so always[0:2] checks the evaluation "
          "tick as well.  A bounded range whose last tick exists decides at that "
          "tick, while a range that runs past the word or to $ keeps the "
          "unfinished obligation as a hold.  The four variants separate those "
          "four alignments.",
      limitation="Three-tick words; bounded ranges of length at most three.")


# ---------------------------------------------------------------------------
# 16.12 Table 16-3 precedence level 10


PRECEDENCE = [parse_spec("a until b until c").body,
              parse_spec("a implies b implies c").body]


def precedence_code(samples, context, sel):
    return (class_code(PRECEDENCE[0], samples)
            | (class_code(PRECEDENCE[1], samples) << 2))


table("ch16_precedence_right", "16.12",
      "until/s_until/until_with/s_until_with/implies associate to the right",
      signals=[("a", 1), ("b", 1), ("c", 1)], horizon=3, selectors=1,
      actual=precedence_code,
      reference="""
        wire [2:0] w_a={s_a_2,s_a_1,s_a_0};
        wire [2:0] w_b={s_b_2,s_b_1,s_b_0};
        wire [2:0] w_c={s_c_2,s_c_1,s_c_0};
        integer i;
        reg [5:0] inner;
        reg hit0, hit1, hit2, witness;
        reg [31:0] until_value, implies_value;
        always @* begin
          // a until b until c parses as a until (b until c).
          hit2 = w_c[2];
          hit1 = w_c[1] | (w_b[1] & w_c[2]);
          hit0 = w_c[0] | (w_b[0] & (w_c[1] | (w_b[1] & w_c[2])));
          inner[1] = w_c[2] | w_b[2];
          inner[3] = w_c[1] | (w_b[1] & inner[1]);
          inner[5] = w_c[0] | (w_b[0] & inner[3]);
          witness = hit0 | (w_a[0] & hit1) | (w_a[0] & w_a[1] & hit2);
          if (witness) until_value = 2'd1;
          else if ((inner[5] & ~hit0) | (w_a[0] & inner[3] & ~hit1)
                   | (w_a[0] & w_a[1] & inner[1] & ~hit2)
                   | (w_a[0] & w_a[1] & w_a[2])) until_value = 32'd2;
          else until_value = 2'd0;
          // a implies b implies c parses as a implies (b implies c).
          implies_value = (!w_a[0] | !w_b[0] | w_c[0]) ? 32'd1 : 32'd0;
          reference_result = until_value + implies_value*4;
        end
      """,
      why="Table 16-3 assigns right associativity to level 10.  The until "
          "variant separates a real right-operand witness from an unfinished "
          "left operand (hold), which the left-associated reading does not.  "
          "The implies variant is the Boolean reading a -> (b -> c), which "
          "differs from (a -> b) -> c whenever a is false and c is false.",
      limitation="One nested operator, three-tick words, weak until only.  The "
                 "s_until forms share the grammar entry and are not re-parsed.")


# ---------------------------------------------------------------------------
# 16.13.3 adjoint rules for clock scope


def adjoint_code(nodes, samples):
    values = integers(samples)
    horizon = len(samples)
    clock = [1] * horizon
    left, right = (earliest(node, clock, values, horizon) for node in nodes)
    return left | (right << 4)


ADJOINT_ONE = [
    # @(c) x ##1 y |=> @(d) z
    ("cat", ("clock", "c", ("cat", ("bool", "x"), ("bool", "y"), 1)),
     ("clock", "d", ("bool", "y")), 1),
    # @(c) x |=> y |=> @(d) z
    ("cat", ("clock", "c", ("bool", "x")),
     ("cat", ("clock", "c", ("bool", "y")),
      ("clock", "d", ("bool", "y")), 1), 1),
]


table("ch16_adjoint_one", "16.13.3",
      "@(c) x ##1 y |=> @(d) z equals @(c) x |=> y |=> @(d) z",
      signals=[("c", 1), ("d", 1), ("x", 1), ("y", 1)],
      horizon=3,
      actual=lambda samples, context, sel: adjoint_code(ADJOINT_ONE, samples),
      reference="""
        wire [2:0] w_c={s_c_2,s_c_1,s_c_0};
        wire [2:0] w_d={s_d_2,s_d_1,s_d_0};
        wire [2:0] w_x={s_x_2,s_x_1,s_x_0};
        wire [2:0] w_y={s_y_2,s_y_1,s_y_0};
        integer i, t0, u0, du, v0;
        always @* begin
          t0=-1; u0=-1; du=-1; v0=-1;
          // the first c tick is the leading clock of the antecedent
          for (i=0;i<3;i=i+1) if (t0<0 && w_c[i]) t0=i;
          if (t0>=0 && w_x[t0])
            // y must hold at the next c tick
            for (i=0;i<3;i=i+1) if (i>t0 && u0<0 && w_c[i]) u0=i;
          if (u0>=0 && w_y[u0])
            // z must hold at the first d tick after that
            for (i=0;i<3;i=i+1) if (i>u0 && du<0 && w_d[i]) begin
              du=i; if (w_y[i]) v0=i;
            end
          reference_result=(v0<0) ? 15 : v0;
          reference_result=reference_result + reference_result*16;
        end
      """,
      why="Both spellings must give the same attempt: x on the c alignment, y "
          "on the next c tick, z on the first d tick after y.  The two halves of "
          "the result come from the two independent F.5.1.1 rewrites and are "
          "compared with the same clause-derived loop.",
      limitation="A second clock control is rejected by the parser, so the "
                 "F.5.1.1 trees are built directly; three-tick words; z is "
                 "instantiated by the same atom as y to keep the word at 12 "
                 "bits.")


ADJOINT_ZERO = [
    # @(c) x ##0 y |=> @(d) z
    ("cat", ("clock", "c", ("cat", ("bool", "x"), ("bool", "y"), 0)),
     ("clock", "d", ("bool", "z")), 1),
    # @(c) x |-> y |=> @(d) z
    ("cat", ("clock", "c", ("bool", "x")),
     ("cat", ("clock", "c", ("bool", "y")),
      ("clock", "d", ("bool", "z")), 1), 0),
]


table("ch16_adjoint_zero", "16.13.3",
      "@(c) x ##0 y |=> @(d) z equals @(c) x |-> y |=> @(d) z",
      signals=[("c", 1), ("d", 1), ("x", 1), ("y", 1), ("z", 1)],
      horizon=2,
      actual=lambda samples, context, sel: adjoint_code(ADJOINT_ZERO, samples),
      reference="""
        wire [1:0] w_c={s_c_1,s_c_0};
        wire [1:0] w_d={s_d_1,s_d_0};
        wire [1:0] w_x={s_x_1,s_x_0};
        wire [1:0] w_y={s_y_1,s_y_0};
        wire [1:0] w_z={s_z_1,s_z_0};
        integer i, t0, du, v0;
        always @* begin
          t0=-1; du=-1; v0=-1;
          for (i=0;i<2;i=i+1) if (t0<0 && w_c[i]) t0=i;
          // fusion and overlapping implication both test y on x's tick
          if (t0>=0 && w_x[t0] && w_y[t0])
            for (i=0;i<2;i=i+1) if (i>t0 && du<0 && w_d[i]) begin
              du=i; if (w_z[i]) v0=i;
            end
          reference_result=(v0<0) ? 15 : v0;
          reference_result=reference_result + reference_result*16;
        end
      """,
      why="Fusion checks y on the same c tick as x, and overlapping implication "
          "checks y on the antecedent end tick, so both forms send z to the "
          "first d tick after x.  A disagreement in either half fails the "
          "equality.",
      limitation="Two-tick words; the clocked trees are built directly because "
                 "the parser rejects a second clock control.")


# ---------------------------------------------------------------------------
# 16.16.1 semantic leading clock


PREFIX = [
    # @(c1) a: a clock-free sequence gets c1 as its leading clock
    ("clock", "c1", ("bool", "a")),
    # @(c1) @(c2) a: the inner prefix keeps c2, the outer finds no inherited clock
    ("clock", "c1", ("clock", "c2", ("bool", "a"))),
    # @(c1) (a or @(c2) a): inherited is replaced by c1 in the left operand and
    # c2 survives in the right operand, so the set is the union {c1, c2}
    ("clock", "c1", ("or", ("bool", "a"), ("clock", "c2", ("bool", "a")))),
]


def prefix_code(samples, context, sel):
    values = integers(samples)
    horizon = len(samples)
    clock = values["c1"]
    return sum(earliest(node, clock, values, horizon) << (4 * index)
               for index, node in enumerate(PREFIX))


table("ch16_lead_prefix", "16.16.1",
      "prefix replaces inherited with its clock and otherwise keeps the operand set",
      signals=[("c1", 1), ("c2", 1), ("a", 1)], horizon=3,
      actual=prefix_code,
      reference="""
        wire [2:0] w_c1={s_c1_2,s_c1_1,s_c1_0};
        wire [2:0] w_c2={s_c2_2,s_c2_1,s_c2_0};
        wire [2:0] w_a={s_a_2,s_a_1,s_a_0};
        integer i, t1, t2;
        reg [31:0] e0, e1, e2;
        always @* begin
          t1=-1; t2=-1; e0=15; e1=15;
          for (i=0;i<3;i=i+1) begin
            // @(c1) a and @(c1) @(c2) a take the first tick of their own clock
            if (t1<0 && w_c1[i]) begin t1=i; if (w_a[i]) e0=i; end
            if (t2<0 && w_c2[i]) begin t2=i; if (w_a[i]) e1=i; end
          end
          // the union of the two leading clocks gives the earlier of the two
          e2 = ((e0<e1) ? e0 : e1);
          reference_result=e0 + e1*16 + e2*256;
        end
      """,
      why="A clock-free sequence under @(c1) has the leading clock c1, and an "
          "inner @(c2) on a clock-free operand keeps c2 because there is no "
          "inherited clock left for the outer prefix to replace.  The third "
          "variant has one clock-free and one explicitly clocked operand, so "
          "the inherited clock is replaced only in the left operand and the "
          "two clocks coexist.",
      limitation="Only two clock signals and one nesting level; the multi-clock "
                 "sources are built as F.5.1.1 trees because the parser rejects "
                 "multiple clock controls.  The union rule is exercised on "
                 "sequence or, not on property and.")


DELAY = [
    # ( @(c1) a ) ##1 ( @(c2) b )
    ("cat", ("clock", "c1", ("bool", "a")),
     ("clock", "c2", ("bool", "b")), 1),
    # ( @(c1) a ) ##0 ( @(c2) b )
    ("cat", ("clock", "c1", ("bool", "a")),
     ("clock", "c2", ("bool", "b")), 0),
]


def delay_code(samples, context, sel):
    values = integers(samples)
    horizon = len(samples)
    clock = values["c1"]
    return sum(pack(counts(node, clock, values, horizon)) << (8 * index)
               for index, node in enumerate(DELAY))


table("ch16_lead_seq_delay", "16.16.1",
      "m1 ##1 m2 and m1 ##0 m2 have the semantic leading clock of m1",
      signals=[("c1", 1), ("c2", 1), ("a", 1), ("b", 1)], horizon=3,
      actual=delay_code,
      reference="""
        wire [2:0] w_c1={s_c1_2,s_c1_1,s_c1_0};
        wire [2:0] w_c2={s_c2_2,s_c2_1,s_c2_0};
        wire [2:0] w_a={s_a_2,s_a_1,s_a_0};
        wire [2:0] w_b={s_b_2,s_b_1,s_b_0};
        integer i, t0, u;
        reg [31:0] one, zero;
        always @* begin
          one=0; zero=0; t0=-1;
          // the leading clock admits the attempt only at its first tick
          for (i=0;i<3;i=i+1) if (t0<0 && w_c1[i]) t0=i;
          if (t0>=0 && w_a[t0]) begin
            // ##1: b on the first c2 tick after m1 ends
            u=-1;
            for (i=0;i<3;i=i+1) if (i>t0 && u<0 && w_c2[i]) u=i;
            if (u>=0 && w_b[u]) one[2*(u+1) +: 2]=2'd1;
            // ##0: b on the first c2 tick at or after m1 ends
            u=-1;
            for (i=0;i<3;i=i+1) if (i>=t0 && u<0 && w_c2[i]) u=i;
            if (u>=0 && w_b[u]) zero[2*(u+1) +: 2]=2'd1;
          end
          reference_result=one + zero*256;
        end
      """,
      why="The leading clock of a delay concatenation is the leading clock of "
          "the left operand, so the attempt starts on a c1 tick.  The right "
          "operand then runs on its own c2 alignment; ##1 starts the search "
          "after the left end and ##0 at the left end.  The per-age counts make "
          "both alignments observable.",
      limitation="Two clocks, one-bit atoms, three-tick words; built as an "
                 "F.5.1.1 tree because the parser rejects multiple clocks.")


OUTER = [
    # q under an incoming clock c
    ("bool", "a"),
    # the same q with an explicit @(c)
    ("clock", "c", ("bool", "a")),
]


def outer_code(samples, context, sel):
    values = integers(samples)
    horizon = len(samples)
    clock = values["c"]
    return sum(pack(counts(node, clock, values, horizon)) << (8 * index)
               for index, node in enumerate(OUTER))


table("ch16_lead_outer_clock", "16.16.1",
      "an inherited clock denotes the incoming outer clock: q under c equals @(c) q",
      signals=[("c", 1), ("a", 1)], horizon=3,
      actual=outer_code,
      reference="""
        wire [2:0] w_c={s_c_2,s_c_1,s_c_0};
        wire [2:0] w_a={s_a_2,s_a_1,s_a_0};
        integer i, t;
        reg [31:0] hit;
        always @* begin
          hit=0; t=-1;
          for (i=0;i<3;i=i+1) if (t<0 && w_c[i]) begin
            t=i;
            if (w_a[i]) hit[2*(i+1) +: 2]=2'd1;
          end
          reference_result=hit + hit*256;
        end
      """,
      why="Both halves apply the same rule: skip to the first tick where the "
          "outer clock c is true and test a there.  The first half leaves the "
          "clock implicit (inherited) and the second spells out @(c); any "
          "difference between the inherited and explicit paths shows up as a "
          "half that disagrees with the clause-derived loop.",
      limitation="One clock and one atom; three-tick words.  Clock identity for "
                 "value-equal but distinct clock expressions is outside a "
                 "single-clock model.")
