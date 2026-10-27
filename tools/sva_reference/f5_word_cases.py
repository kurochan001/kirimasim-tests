"""Formal cases for the F.2 model and F.3.2/F.3.3/F.5 word operations.

Each entry is a finite equivalence check exported by ``formal.table_model``:
a packed input word is enumerated exhaustively in one combinational ``case``
and the result of the executable model in this module is compared with an
independently written RTL reference.

The word alphabet used by the operational cases has four letters:

* ``0`` -- bottom (satisfies no Boolean expression),
* ``1`` -- top (satisfies every Boolean expression),
* ``2`` -- the proposition-set letter ``{}`` (no atomic proposition holds),
* ``3`` -- the proposition-set letter ``{a}`` (the atom ``a`` holds).

F.5 also permits any subset of the atomic propositions; ``f5_alphabet`` uses a
three-bit encoding of the full alphabet over ``{a,b}`` (four subsets plus top
and bottom), so the two unused codes are outside the alphabet.

Every case is finite: words have at most three letters, infinite words are
represented by a finite prefix (noted in the limitation), and none of the
reference RTL reads the parser, the evaluator or the derivative engine.
"""

import re

from .f_extra_common import table  # noqa: F401  (registers into f_extra_common.TABLES)
from .parser import LOCAL_TYPES, Unsupported, parse_sequence


# letter encoding shared by the operational word cases
BOTTOM, TOP, EMPTY, ATOM = 0, 1, 2, 3


def _letters(word, count=3, width=2):
    return [(word >> (width * index)) & ((1 << width) - 1) for index in range(count)]


def _sat(letter, name="a"):
    """Boolean satisfaction of a letter (F.5 PLACEHOLDERS)."""
    if letter == TOP:
        return True
    if letter == BOTTOM:
        return False
    return letter == (ATOM if name == "a" else EMPTY)


# ---------------------------------------------------------------------------
# F.5 alphabet, dual, index, subword, placeholders


def _alphabet_class(code):
    """(category, proposition-membership) for one three-bit alphabet code.

    category: 0 bottom, 1 top, 2 proposition-set letter, 3 invalid/absent.
    membership: the subset mask over ``{a,b}`` for a proposition letter.
    """
    if code == 0:
        return 0, 3
    if code == 1:
        return 1, 3
    if code < 6:
        return 2, code - 2
    return 3, 3


def f5_alphabet_actual(samples, context, selector, values):
    word = [(values["W"] >> (3 * index)) & 7 for index in range(3)]
    valid, categories, memberships = 1, [], []
    for index in range(3):
        if index < selector:
            category, membership = _alphabet_class(word[index])
            valid &= int(category != 3)
        else:
            category, membership = 3, 3
        categories.append(category)
        memberships.append(membership)
    return (selector | (valid << 2)
            | (categories[0] << 3) | (categories[1] << 5) | (categories[2] << 7)
            | (memberships[0] << 9) | (memberships[1] << 11) | (memberships[2] << 13))


table(
    "f5_alphabet", "F.5", "words over subsets of {a,b} plus top and bottom",
    inputs=[("W", 9)], selectors=2,
    actual=f5_alphabet_actual,
    reference="""
      wire [2:0] a0=i_W[2:0], a1=i_W[5:3], a2=i_W[8:6];
      wire use0=sel>0, use1=sel>1, use2=sel>2;
      wire valid=(!use0 || a0<3'd6) && (!use1 || a1<3'd6) && (!use2 || a2<3'd6);
      wire [1:0] c0 = !use0 ? 2'd3 : (a0==0 ? 2'd0 : (a0==1 ? 2'd1 : (a0<6 ? 2'd2 : 2'd3)));
      wire [1:0] c1 = !use1 ? 2'd3 : (a1==0 ? 2'd0 : (a1==1 ? 2'd1 : (a1<6 ? 2'd2 : 2'd3)));
      wire [1:0] c2 = !use2 ? 2'd3 : (a2==0 ? 2'd0 : (a2==1 ? 2'd1 : (a2<6 ? 2'd2 : 2'd3)));
      wire [1:0] m0 = (use0 && a0>=2 && a0<6) ? (a0-3'd2) : 2'd3;
      wire [1:0] m1 = (use1 && a1>=2 && a1<6) ? (a1-3'd2) : 2'd3;
      wire [1:0] m2 = (use2 && a2>=2 && a2<6) ? (a2-3'd2) : 2'd3;
      always @* reference_result={17'd0,m2,m1,m0,c2,c1,c0,valid,sel};
    """,
    why="F.5 words are finite sequences of letters, each letter a subset of the "
        "atomic propositions or one of top/bottom.  With atoms {a,b} the alphabet "
        "has 2^2+2 = 6 letters; the three-bit encoding has eight codes, so codes "
        "6 and 7 must be rejected.  Lengths 0..3 are enumerated and every "
        "in-word letter is classified as bottom, top or a proposition subset.",
    limitation="Two atomic propositions, words up to three letters.  An infinite "
               "word is only represented by a finite prefix; no infinite object is "
               "constructed and length is not unbounded.",
)


def _dual(letter):
    return {BOTTOM: TOP, TOP: BOTTOM}.get(letter, letter)


def f5_dual_actual(samples, context, selector, values):
    word = _letters(values["W"])
    length = values["L"]
    dual = [_dual(word[index]) if index < length else 0 for index in range(3)]
    return length | (dual[0] << 2) | (dual[1] << 4) | (dual[2] << 6)


table(
    "f5_dual", "F.5", "dual word",
    inputs=[("W", 6), ("L", 2)],
    actual=f5_dual_actual,
    reference="""
      wire [1:0] l0=i_W[1:0], l1=i_W[3:2], l2=i_W[5:4];
      wire [1:0] d0 = (i_L>0) ? ((l0==0)?2'd1:(l0==1)?2'd0:l0) : 2'd0;
      wire [1:0] d1 = (i_L>1) ? ((l1==0)?2'd1:(l1==1)?2'd0:l1) : 2'd0;
      wire [1:0] d2 = (i_L>2) ? ((l2==0)?2'd1:(l2==1)?2'd0:l2) : 2'd0;
      always @* reference_result={24'd0,d2,d1,d0,i_L};
    """,
    why="The dual word swaps top and bottom at every letter and leaves the two "
        "proposition-set letters {} and {a} unchanged.  The packed result shows "
        "the length, the three dual letters and the empty-word boundary L=0.",
    limitation="Alphabet bottom/top/{} /{a}; words up to three letters.",
)


def f5_index_actual(samples, context, selector, values):
    word = _letters(values["W"])
    length, index = values["L"], values["I"]
    suffix_length = length - index if index < length else 0
    suffix = [word[index + offset] if index + offset < length else 0
              for offset in range(3)]
    return (suffix_length | (suffix[0] << 2) | (suffix[1] << 4) | (suffix[2] << 6))


table(
    "f5_index", "F.5", "suffix w^i..",
    inputs=[("W", 6), ("L", 2), ("I", 3)],
    actual=f5_index_actual,
    reference="""
      wire [3:0] len4={2'b00,i_L};
      wire [3:0] base={1'b0,i_I};
      wire [1:0] slen=(base<len4) ? (len4-base) : 2'd0;
      wire [1:0] s0=(base<len4) ? ((i_W>>(2*base))&3) : 2'd0;
      wire [1:0] s1=(base+1<len4) ? ((i_W>>(2*(base+1)))&3) : 2'd0;
      wire [1:0] s2=(base+2<len4) ? ((i_W>>(2*(base+2)))&3) : 2'd0;
      always @* reference_result={24'd0,s2,s1,s0,slen};
    """,
    why="Letters are zero-indexed and the suffix starting at i removes the first "
        "i letters.  For i=0 the whole word is returned, for i=length the suffix "
        "is empty, and for i>length (i is three bits, length at most three) the "
        "suffix is also empty.  The packed result carries both the suffix length "
        "and the suffix letters, so the i=j boundary is observable.",
    limitation="Alphabet bottom/top/{} /{a}; words up to three letters; indices "
               "0..7 cover i=0, 0<i<length, i=length and i>length only.",
)


def f5_subword_actual(samples, context, selector, values):
    word = _letters(values["W"])
    length, start, stop = values["L"], values["I"], values["J"]
    defined = int(start <= stop < length)
    count = stop - start + 1 if defined else 0
    pieces = [word[start + offset] if defined and start + offset <= stop else 0
              for offset in range(3)]
    return (defined | (count << 1) | (pieces[0] << 3)
            | (pieces[1] << 5) | (pieces[2] << 7))


table(
    "f5_subword", "F.5", "subword w^{i..j}",
    inputs=[("W", 6), ("L", 2), ("I", 2), ("J", 2)],
    actual=f5_subword_actual,
    reference="""
      wire [2:0] ii={1'b0,i_I}, jj={1'b0,i_J}, ll={1'b0,i_L};
      wire defined=(ii<=jj) && (jj<ll);
      wire [1:0] count=defined ? (jj-ii+1) : 2'd0;
      wire [1:0] s0=(defined && (ii<=jj)) ? ((i_W>>(2*ii))&3) : 2'd0;
      wire [1:0] s1=(defined && (ii+1<=jj)) ? ((i_W>>(2*(ii+1)))&3) : 2'd0;
      wire [1:0] s2=(defined && (ii+2<=jj)) ? ((i_W>>(2*(ii+2)))&3) : 2'd0;
      always @* reference_result={23'd0,s2,s1,s0,count,defined};
    """,
    why="For i<=j the subword deletes all letters before i and after j, and when "
        "i<=j<length it contains both endpoints.  The table covers i=j (one "
        "letter), i<j, j=length-1 (last letter included) and the out-of-range "
        "cases i>j and j>=length, where the subword is not defined.",
    limitation="Alphabet bottom/top/{} /{a}; words up to three letters, so "
               "subwords longer than three letters are not representable.",
)


def f5_placeholders_actual(samples, context, selector, values):
    letter = values["X"]
    if letter == BOTTOM:
        truths = [False, False, False, False]
    elif letter == TOP:
        truths = [True, True, True, True]
    else:
        a = letter == ATOM
        truths = [a, not a, a or not a, a and not a]
    return sum(int(value) << index for index, value in enumerate(truths))


table(
    "f5_placeholders", "F.5", "Boolean satisfaction of the three letter kinds",
    inputs=[("X", 2)],
    actual=f5_placeholders_actual,
    reference="""
      wire [3:0] all_true=4'b1111, all_false=4'b0000;
      wire [3:0] empty_set=4'b0110;   // a=0: !a, a||!a
      wire [3:0] atom_set=4'b0101;    // a=1: a, a||!a
      wire [3:0] ref=(i_X==0) ? all_false :
                     (i_X==1) ? all_true :
                     (i_X==2) ? empty_set : atom_set;
      always @* reference_result={28'd0,ref};
    """,
    why="Boolean satisfaction of a proposition-set letter is the ordinary "
        "evaluation under its atomic propositions; top satisfies every Boolean "
        "expression, including a&&!a, and bottom satisfies none, including "
        "a||!a.  The four packed bits are the results for a, !a, a||!a and "
        "a&&!a, so the two placeholders cannot be confused with {} or {a}.",
    limitation="One atomic proposition and four representative Boolean "
               "expressions; arbitrary expressions are not enumerated.",
)


# ---------------------------------------------------------------------------
# F.2 model, attempts and transform


def _model_code(values):
    word = _letters(values["W"])
    a = [_sat(letter, "a") for letter in word]
    not_a = [_sat(letter, "n") for letter in word]

    # 0: Boolean property a at tick 0.
    r0 = (0 << 4) if a[0] else (1 << 4)
    # 1: strong(a ##1 a ##1 a ##1 a) on a three-letter word: bottom cannot
    #    supply the missing fourth letter, so this is a failure.
    r1 = 1 << 4
    # 2: weak(a ##1 a ##1 a ##1 a): every prefix followed by infinite top must
    #    still match; the three prefixes require a at ticks 0, 1 and 2.
    r2 = (0 << 4) if all(a) else (1 << 4)
    # 3: (a ##1 a) |-> !a.  No antecedent match is vacuous; a match requires
    #    a at ticks 0 and 1 and evaluates !a on the endpoint suffix.
    if not (a[0] and a[1]):
        r3 = 2 << 4
    elif not_a[1]:
        r3 = 0
    else:
        r3 = 1 << 4
    return r0 | (r1 << 8) | (r2 << 16) | (r3 << 24)


table(
    "f2_model", "F.2", "finite trace versus concurrent assertions",
    inputs=[("W", 6)],
    actual=lambda samples, context, selector, values: _model_code(values),
    reference="""
      wire [1:0] l0=i_W[1:0], l1=i_W[3:2], l2=i_W[5:4];
      wire a0=(l0==1)||(l0==3), a1=(l1==1)||(l1==3), a2=(l2==1)||(l2==3);
      wire n1=(l1==1)||(l1==2);
      wire [7:0] r0 = a0 ? 8'd0 : 8'd16;
      wire [7:0] r1 = 8'd16;
      wire [7:0] r2 = (a0&&a1&&a2) ? 8'd0 : 8'd16;
      wire [7:0] r3 = !(a0&&a1) ? 8'd32 : (n1 ? 8'd0 : 8'd16);
      always @* reference_result={r3,r2,r1,r0};
    """,
    why="A trace is a sequence of letters, each an atomic-proposition set or an "
        "extension placeholder.  The four packed results evaluate (0) a Boolean "
        "property, (1) a sequence property strongly (infinite bottom extension), "
        "(2) the same sequence weakly (infinite top extension) and (3) an "
        "overlapping implication.  Strong fails because bottom cannot complete "
        "the fourth letter; weak succeeds only when every prefix can be "
        "completed by top; the implication is vacuous when the antecedent never "
        "matches.  Trace construction from scheduling is deliberately outside "
        "this table.",
    limitation="Three-letter traces, one atomic proposition, four assertion "
               "shapes.  Finite/infinite traces are represented by a finite word "
               "with top or bottom extension; scheduling and clock generation are "
               "not modelled.",
)


def _attempts_code(values):
    word = _letters(values["W"])
    a = [_sat(letter, "a") for letter in word]
    code = 0
    for start in range(4):
        if start + 1 < 3 and a[start] and a[start + 1]:
            result = (0 << 4) | (start + 1)
        else:
            result = (1 << 4) | start
        code |= result << (8 * start)
    return code


table(
    "f2_attempts", "F.2", "independent attempts at each starting clock",
    inputs=[("W", 6)],
    actual=lambda samples, context, selector, values: _attempts_code(values),
    reference="""
      wire [1:0] l0=i_W[1:0], l1=i_W[3:2], l2=i_W[5:4];
      wire a0=(l0==1)||(l0==3), a1=(l1==1)||(l1==3), a2=(l2==1)||(l2==3);
      wire [7:0] r0=(a0&&a1) ? 8'd1 : 8'd16;
      wire [7:0] r1=(a1&&a2) ? 8'd2 : 8'd17;
      wire [7:0] r2=8'd18;
      wire [7:0] r3=8'd19;
      always @* reference_result={r3,r2,r1,r0};
    """,
    why="Each starting letter of the continuously monitored assertion begins a "
        "separate attempt of a ##1 a.  The four packed fields are the results of "
        "the attempts at ticks 0, 1, 2 and the empty start 3; they are computed "
        "independently and therefore differ across starts (for example a at 0 "
        "and 2 but not 1 gives success at start 1 only).  Starts 2 and 3 fail "
        "because the finite trace plus bottom extension has no second letter.",
    limitation="One two-letter sequence and a three-letter trace; the procedural "
               "queue order of 16.14.6 and overlapping attempts are outside the "
               "F.2 equations and are not modelled.",
)


# A tiny closed term language for the F.2 transform pipeline.  Terms are
# ('a',), ('nota',), ('atom', name), ('cat', left, right), ('call', name, arg),
# ('decl', name, init, body), ('bind', name, init, body) and ('clock', name, body).
_TRANSFORM_CALLS = {"S": ("x", ("cat", ("a",), ("atom", "x")))}
_TRANSFORM_SOURCES = (
    ("call", "S", ("a",)),
    ("decl", "v", ("nota",), ("cat", ("v", "v"), ("a",))),
    ("clock", "c", ("cat", ("a",), ("clock", "c", ("nota",)))),
)


def _subst(term, mapping):
    op = term[0]
    if op in {"a", "nota", "v"}:
        return term
    if op == "atom":
        return mapping.get(term[1], term)
    if op == "cat":
        return ("cat", _subst(term[1], mapping), _subst(term[2], mapping))
    if op in {"call", "clock"}:
        return (op, term[1], _subst(term[2], mapping))
    if op in {"decl", "bind"}:
        return (op, term[1], _subst(term[2], mapping), _subst(term[3], mapping))
    raise Unsupported(f"transform does not cover {op}")


def _flatten(term):
    op = term[0]
    if op in {"a", "nota", "atom", "v"}:
        return term
    if op == "call":
        formal, body = _TRANSFORM_CALLS[term[1]]
        return _flatten(_subst(body, {formal: term[2]}))
    if op == "cat":
        return ("cat", _flatten(term[1]), _flatten(term[2]))
    if op == "clock":
        return ("clock", term[1], _flatten(term[2]))
    if op in {"decl", "bind"}:
        return (op, term[1], _flatten(term[2]), _flatten(term[3]))
    raise Unsupported(f"flatten does not cover {op}")


def _eliminate(term):
    op = term[0]
    if op in {"a", "nota", "atom", "v"}:
        return term
    if op == "decl":
        # F.4.3: an initialized declaration becomes declaration assignment
        # execution at the same position, leaving an uninitialized scope.
        return ("bind", term[1], _eliminate(term[2]), _eliminate(term[3]))
    if op == "cat":
        return ("cat", _eliminate(term[1]), _eliminate(term[2]))
    if op == "clock":
        return ("clock", term[1], _eliminate(term[2]))
    if op == "bind":
        return (op, term[1], _eliminate(term[2]), _eliminate(term[3]))
    raise Unsupported(f"eliminate does not cover {op}")


def _clocks(term, inherited=None):
    op = term[0]
    if op == "clock":
        name = term[1]
        if name == inherited:
            # F.2: a nested control equal to the inherited clock is redundant.
            return _clocks(term[2], inherited)
        return ("clock", name, _clocks(term[2], name))
    if op == "cat":
        return ("cat", _clocks(term[1], inherited), _clocks(term[2], inherited))
    if op in {"decl", "bind"}:
        return (op, term[1], _clocks(term[2], inherited), _clocks(term[3], inherited))
    return term


def _eval_expr(term, word, position):
    if term[0] == "nota":
        return _sat(word[position], "n") if position < len(word) else True
    return _sat(word[position], "a") if position < len(word) else False


def _eval_prop(term, word, position, environment):
    op = term[0]
    if op in {"a", "atom"}:
        if position >= len(word):
            return False, position
        return _sat(word[position], "a"), position
    if op == "nota":
        if position >= len(word):
            return True, position
        return _sat(word[position], "n"), position
    if op == "v":
        return environment.get(term[1], 0) == 1, position
    if op == "cat":
        left, left_end = _eval_prop(term[1], word, position, environment)
        right, right_end = _eval_prop(term[2], word, left_end + 1, environment)
        return left and right, right_end
    if op == "call":
        formal, body = _TRANSFORM_CALLS[term[1]]
        return _eval_prop(_subst(body, {formal: term[2]}), word, position, environment)
    if op in {"decl", "bind"}:
        inner = dict(environment)
        inner[term[1]] = int(_eval_expr(term[2], word, position))
        return _eval_prop(term[3], word, position, inner)
    if op == "clock":
        return _eval_prop(term[2], word, position, environment)
    raise Unsupported(f"evaluation does not cover {op}")


def _prop_code(result):
    value, end = result
    return (0 << 4) | end if value else (1 << 4)


def _recursive_value(word, tick, depth):
    """p = a and nexttime p, unrolled to ``depth`` further letters."""
    if tick >= len(word) or depth == 0:
        return True
    return _sat(word[tick], "a") and _recursive_value(word, tick + 1, depth - 1)


def f2_transform_actual(samples, context, selector, values):
    word = _letters(values["W"])
    if selector == 3:
        # F.7: a recursive property holds iff every positive-depth
        # approximation holds; on a three-letter word depths 1..3 are enough.
        before = _recursive_value(word, 0, len(word))
        after = all(_recursive_value(word, 0, depth)
                    for depth in range(1, len(word) + 1))
        code = (0 << 4) | (len(word) - 1) if before else (1 << 4)
        return (code << 8) | code
    source = _TRANSFORM_SOURCES[selector]
    before = _prop_code(_eval_prop(source, word, 0, {}))
    transformed = _clocks(_eliminate(_flatten(source)))
    after = _prop_code(_eval_prop(transformed, word, 0, {}))
    return (after << 8) | before


table(
    "f2_transform", "F.2", "flatten, declaration elimination and clock rewriting",
    inputs=[("W", 6)], selectors=2,
    actual=f2_transform_actual,
    reference="""
      wire [1:0] l0=i_W[1:0], l1=i_W[3:2], l2=i_W[5:4];
      wire a0=(l0==1)||(l0==3), a1=(l1==1)||(l1==3), a2=(l2==1)||(l2==3);
      wire n0=(l0==1)||(l0==2), n1=(l1==1)||(l1==2);
      wire [7:0] source = (sel==0) ? ((a0&&a1) ? 8'd1 : 8'd16) :
                         (sel==1) ? ((n0&&a1) ? 8'd1 : 8'd16) :
                         (sel==2) ? ((a0&&n1) ? 8'd1 : 8'd16) :
                                    ((a0&&a1&&a2) ? 8'd2 : 8'd16);
      always @* reference_result={16'd0,source,source};
    """,
    why="The table evaluates a small finite syntax before and after the F.2 "
        "pipeline.  Form 0 is the named sequence instance S(a) with S(x)=a ##1 x, "
        "flattened to a ##1 a.  Form 1 is the initialized local declaration "
        "(bit v = !a; (v==1) ##1 a), whose declaration assignment is eliminated "
        "into an assignment at the declaration position.  Form 2 is "
        "@(posedge c)(a ##1 @(posedge c)!a), where the inner identical clock "
        "control is determined redundant and removed.  Form 3 is the recursive "
        "property p = a and nexttime p, evaluated by the conjunction of the "
        "positive-depth F.7 approximations.  The two packed fields are the "
        "transformed and source evaluations; both must equal the RTL source "
        "semantics, so the equality shows preservation for these witnesses.",
    limitation="Four finite syntax forms over a three-letter trace with one "
               "always-true clock.  Type-dependent variable semantics, multi-clock "
               "determination and full flattening of arbitrary formals are not "
               "enumerated; recursion is unrolled only to the word length.",
)


# ---------------------------------------------------------------------------
# F.3.2 abstract grammar symbols and F.3.3 notation


SYMBOL_FORMS = (
    "a",
    "a && !b",
    "a ##1 b",
    "int",
    "bit [3:0]",
    "(int v; a)",
    "(v = a + 1)",
    "(v; a)",
)
B_MASK, T_MASK, V_MASK, E_MASK = 1, 2, 4, 8
_TYPE_WORDS = "|".join(sorted(LOCAL_TYPES))


def _has_assignment(node):
    if node.op == "assign":
        return True
    return any(_has_assignment(argument) for argument in node.args)


def symbol_mask(text):
    """Classify one abstract-syntax form by the F.3.2 meta-symbols it uses."""
    bare = re.fullmatch(r"\s*(\w+)\s*(?:\[[^\]]*\])?\s*", text)
    if bare and bare.group(1) in LOCAL_TYPES:
        return T_MASK
    mask = 0
    if re.search(rf"\b(?:{_TYPE_WORDS})\s+[A-Za-z_]\w*\s*;", text):
        mask |= T_MASK | V_MASK
    elif re.search(r"\(\s*[A-Za-z_]\w*\s*;", text):
        mask |= V_MASK
    if re.search(r"\(\s*[A-Za-z_]\w*\s*=", text):
        mask |= V_MASK | E_MASK
    if not _has_assignment(parse_sequence(text)):
        mask |= B_MASK
    return mask


table(
    "f32_symbols", "F.3.2", "b/t/v/e classification of representative forms",
    selectors=3,
    actual=lambda samples, context, selector: symbol_mask(SYMBOL_FORMS[selector]),
    reference="""
      always @* begin
        case(sel)
          0,1,2: reference_result=8'd1;   // b
          3,4:   reference_result=8'd2;   // t
          5:     reference_result=8'd7;   // t, v, b
          6:     reference_result=8'd12;  // v, e
          default: reference_result=8'd5; // v, b
        endcase
      end
    """,
    why="The abstract grammar uses b for Boolean, t for type, v for local variable "
        "and e for expression.  The eight forms classify as: bare/combined "
        "Boolean sequences use b; a bare type or a ranged type uses t; "
        "(int v; a) uses t, v and b; (v = a + 1) uses v and e; (v; a) uses v and b. "
        "The actual side parses each form and inspects the resulting nodes; the "
        "reference is an independent category table.",
    limitation="Eight representative productions, not the whole grammar.  The "
               "classification is by role in the printed form; ambiguous uses of "
               "an identifier as both v and b are not enumerated.",
)


NOTATION_SYMBOLS = (
    "b", "t", "v", "c", "e",
    "R", "S", "P", "Q", "T", "U",
    "r", "s", "p", "q", "A",
    "i", "j", "k", "m", "n",
    # the five-bit selector has 32 codes; the remaining codes repeat the
    # nonnegative-integer symbol so that the enumeration is total
    "n", "n", "n", "n", "n", "n", "n", "n", "n", "n", "n",
)
NOTATION_BITS = {
    "bool": 1, "type": 2, "local": 4, "free": 8, "expr": 16,
    "unclocked_sequence": 32, "clocked_sequence": 64,
    "ordinary_property": 128, "top_property": 256,
    "either_sequence": 512, "either_property": 1024,
    "assertion": 2048, "index": 4096,
}


def notation_mask(symbol):
    if symbol in "btvce":
        return {"b": 1, "t": 2, "v": 4, "c": 8, "e": 16}[symbol]
    if symbol == "R":
        return NOTATION_BITS["unclocked_sequence"]
    if symbol == "S":
        return NOTATION_BITS["clocked_sequence"]
    if symbol in "PQ":
        return NOTATION_BITS["ordinary_property"]
    if symbol in "TU":
        return NOTATION_BITS["top_property"]
    if symbol in "rs":
        return NOTATION_BITS["either_sequence"]
    if symbol in "pq":
        return NOTATION_BITS["either_property"]
    if symbol == "A":
        return NOTATION_BITS["assertion"]
    return NOTATION_BITS["index"]


NOTATION_REFERENCE = (
    1, 2, 4, 8, 16,      # b t v c e
    32, 64,              # R S
    128, 128,            # P Q
    256, 256,            # T U
    512, 512,            # r s
    1024, 1024,          # p q
    2048,                # A
    4096, 4096, 4096, 4096, 4096,  # i j k m n
    4096, 4096, 4096, 4096, 4096, 4096, 4096, 4096, 4096, 4096, 4096,
)


def _sel_case(constants, width):
    body = " ".join(f"{index}: reference_result={width}'d{value};"
                    for index, value in enumerate(constants))
    return f"always @* begin reference_result=0; case(sel) {body} endcase end"


table(
    "f33_notation", "F.3.3", "notation categories for meta-symbols",
    selectors=5,
    actual=lambda samples, context, selector: notation_mask(NOTATION_SYMBOLS[selector]),
    reference=_sel_case(NOTATION_REFERENCE, 16),
    why="The notation distinguishes Boolean (b), type (t), local variable (v), "
        "free checker variable (c) and expression (e); R and S are unclocked and "
        "clocked sequences; P and Q ordinary properties; T and U top-level "
        "properties; r,s and p,q allow either clocking category; A is an "
        "assertion; i,j,k,m,n are nonnegative integers.  The classifier returns "
        "one category bit per symbol and the independent RTL table states the "
        "same category assignment.",
    limitation="Twenty-one meta-symbols, not every lexical form in the notation; "
               "the five-bit selector's remaining eleven codes repeat the "
               "nonnegative-integer symbol.  The table classifies the printed "
               "meta-symbols; Greek and subscripted variants and integer "
               "arithmetic are outside it.",
)
