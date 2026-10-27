"""Independent RTL specifications from IEEE 1800-2023 clauses.

These monitors do not call the SVA parser, derivative engine or evaluator.
History bit zero is the latest consumed sample. Each sequence attempt begins
at the first sample; age is the number consumed, including zero for empty.
"""


def count(condition):
    return f"(({condition}) ? 32'd1 : 32'd0)"


SEQUENCES = {
    "delay_range": ("a ##[1:3] b", "ab", "16.9.1", {
        2: "h_a[1] && h_b[0]", 3: "h_a[2] && h_b[0]", 4: "h_a[3] && h_b[0]"}),
    "fusion": ("a ##0 b", "ab", "16.9.1", {1: "h_a[0] && h_b[0]"}),
    "empty": ("a[*0]", "a", "16.9.2.1", {0: "1"}),
    "empty_fusion": ("a[*0] ##0 b", "ab", "16.9.2.1", {}),
    "empty_left": ("a[*0] ##1 b", "ab", "16.9.2.1", {1: "h_b[0]"}),
    "empty_right": ("a ##1 b[*0]", "ab", "16.9.2.1", {1: "h_a[0]"}),
    "optional_empty": ("a[*0:1] ##1 b", "ab", "16.9.2.1", {
        1: "h_b[0]", 2: "h_a[1] && h_b[0]"}),
    "repetition": ("a[*1:3]", "a", "16.9.2", {
        1: "h_a[0]", 2: "h_a[1] && h_a[0]", 3: "h_a[2] && h_a[1] && h_a[0]"}),
    "sequence_repetition": ("(a ##1 b)[*1:2]", "ab", "16.9.2", {
        2: "h_a[1] && h_b[0]", 4: "h_a[3] && h_b[2] && h_a[1] && h_b[0]"}),
    "sequence_or_multiplicity": ("(a ##1 b) or (a ##1 b)", "ab", "16.9.7", {
        2: f"2 * {count('h_a[1] && h_b[0]')}"}),
    "sequence_and": ("(a ##1 b) and (c ##2 d)", "abcd", "16.9.5", {
        3: "h_a[2] && h_b[1] && h_c[2] && h_d[0]"}),
    "and_endpoint_pairs": ("(a ##[1:2] b) and (c ##2 d)", "abcd", "16.9.5", {
        3: f"{count('h_a[2] && h_c[2] && h_d[0]')} * ({count('h_b[1]')} + {count('h_b[0]')})"}),
    "intersect": ("(a ##[1:2] b) intersect (c ##2 d)", "abcd", "16.9.6", {
        3: "h_a[2] && h_b[0] && h_c[2] && h_d[0]"}),
    "first_match": ("first_match(a ##[1:3] b)", "ab", "16.9.8", {
        2: "h_a[1] && h_b[0]", 3: "h_a[2] && !h_b[1] && h_b[0]",
        4: "h_a[3] && !h_b[2] && !h_b[1] && h_b[0]"}),
    "first_match_tie": ("first_match((a ##[1:2] b) or (a ##2 c))", "abc", "16.9.8", {
        2: "h_a[1] && h_b[0]",
        3: f"{count('h_a[2] && !h_b[1]')} * ({count('h_b[0]')} + {count('h_c[0]')})"}),
    "throughout": ("x throughout (a ##[1:2] b)", "abx", "16.9.9", {
        2: "h_a[1] && h_b[0] && h_x[1] && h_x[0]",
        3: "h_a[2] && h_b[0] && h_x[2] && h_x[1] && h_x[0]"}),
    "within_endpoints": ("(x ##1 x) within (a ##3 b)", "abx", "16.9.10", {
        4: f"{count('h_a[3] && h_b[0]')} * ({count('h_x[3] && h_x[2]')} + {count('h_x[2] && h_x[1]')} + {count('h_x[1] && h_x[0]')})"}),
}


STREAMS = {
    "unbounded_repetition": ("a[*1:$]", "a", "16.9.2", """
      reg started=0, all_a=1;
      always @(posedge clk) begin started<=1; all_a<=all_a && letter[0]; end
      wire [31:0] reference_count = started && all_a;
    """),
    "unbounded_empty_repetition": ("a[*0:$]", "a", "16.9.2", """
      reg all_a=1;
      always @(posedge clk) all_a<=all_a && letter[0];
      wire [31:0] reference_count = all_a;
    """),
    "goto_two_then": ("a[->2] ##1 b", "ab", "16.9.2", """
      reg [1:0] seen=0;
      reg second=0;
      reg [31:0] reference_count=0;
      always @(posedge clk) begin
        if (letter[0] && seen<2) seen<=seen+1;
        second<=letter[0] && seen==1;
        reference_count<=second && letter[1];
      end
    """),
    "nonconsecutive_two": ("a[=2]", "a", "16.9.2", """
      reg [1:0] seen=0;
      always @(posedge clk) if (letter[0] && seen<3) seen<=seen+1;
      wire [31:0] reference_count = seen==2;
    """),
    "first_unbounded": ("first_match(a ##[1:$] b)", "ab", "16.9.8", """
      reg started=0, start_a=0, seen_b=0;
      reg [31:0] reference_count=0;
      always @(posedge clk) begin
        started<=1;
        if (!started) start_a<=letter[0];
        if (started && letter[1]) seen_b<=1;
        reference_count<=started && start_a && !seen_b && letter[1];
      end
    """),
}


# Property result bytes: success=0x0t, failure=0x1t, vacuous=0x2t,
# holds=0x3f, pending=0x4f. t is the zero-based deciding tick.
PROPERTIES = {}
for name, operator in [("implication_overlap", "|->"), ("implication_nonoverlap", "|=>"),
                       ("followed_overlap", "#-#"), ("followed_nonoverlap", "#=#")]:
    followed = operator in {"#-#", "#=#"}
    tick = 2 if operator in {"|=>", "#=#"} else 1
    PROPERTIES[name] = {"expression": f"(a ##1 b) {operator} c", "signals": "abc", "horizon": 3,
        "clause": "16.12.7/16.12.9/16.14.5", "reference": f"""
          always @* begin
            if (!a[0]) reference_result=8'd{16 if followed else 32};
            else if (!b[1]) reference_result=8'd{17 if followed else 33};
            else reference_result=c[{tick}] ? 8'd{tick} : 8'd{16+tick};
          end
        """}
PROPERTIES["empty_consequent"] = {"expression": "a |-> (b[*0] ##1 c)", "signals": "abc", "horizon": 1,
    "clause": "16.9.2.1/16.12.7", "reference": "always @* reference_result=!a[0] ? 8'd32 : c[0] ? 8'd0 : 8'd16;"}
PROPERTIES["empty_antecedent"] = {"expression": "a[*0] |=> b", "signals": "ab", "horizon": 1,
    "clause": "16.12.7", "reference": "always @* reference_result=b[0] ? 8'd0 : 8'd16;"}
for operator in ["until", "s_until", "until_with", "s_until_with"]:
    with_rhs = operator.endswith("_with")
    PROPERTIES[operator] = {"expression": f"a {operator} b", "signals": "ab", "horizon": 3,
        "clause": "16.12.12/F.3.4.3.8", "reference": f"""
          integer i;
          reg decided;
          always @* begin
            reference_result=8'd{79 if operator.startswith('s_') else 63};
            decided=0;
            for (i=0; i<3; i=i+1) if (!decided) begin
              if ({'!a[i]' if with_rhs else 'b[i]'}) begin
                reference_result={'16+i' if with_rhs else 'i'}; decided=1;
              end else if ({'b[i]' if with_rhs else '!a[i]'}) begin
                reference_result={'i' if with_rhs else '16+i'}; decided=1;
              end
            end
          end
        """}
for strong in [False, True]:
    prefix = "s_" if strong else ""
    PROPERTIES[prefix + "nexttime_end"] = {"expression": prefix + "nexttime[2] a", "signals": "a", "horizon": 2,
        "clause": "16.12.10/F.3.4.3.9", "reference": f"always @* reference_result=8'd{79 if strong else 63};"}
    PROPERTIES[prefix + "eventually_end"] = {"expression": prefix + "eventually[1:2] a", "signals": "a", "horizon": 2,
        "clause": "16.12.13/F.3.4.3.9", "reference": f"always @* reference_result=a[1] ? 8'd1 : 8'd{79 if strong else 63};"}
    PROPERTIES[prefix + "always_end"] = {"expression": prefix + "always[1:2] a", "signals": "a", "horizon": 2,
        "clause": "16.12.11/F.3.4.3.9", "reference": f"always @* reference_result=!a[1] ? 8'd17 : 8'd{79 if strong else 63};"}


# F.3.4.3 property-operator rewrites. The reference for each case is the
# expanded right-hand side written as an independent truth table over the whole
# finite word; it never calls the evaluator. a[k] is the sample at tick k.
F343_PROPERTIES = {
    # assert property uses the weak default for a bare sequence: an unfinished
    # candidate that is still viable holds on the finite word ({3f}), not pending.
    "f343_default_strength": {
        "expression": "a ##[1:$] b", "signals": "ab", "horizon": 2, "clause": "F.3.4.3.1",
        "reference": """
          always @* begin
            if (!a[0]) reference_result=8'd16;
            else if (b[1]) reference_result=8'd1;
            else reference_result=8'd63;
          end
        """},
    # p iff q = (p implies q) and (q implies p); p and q are both (x ##1 b).
    "f343_iff": {
        "expression": "(a ##1 b) iff (c ##1 b)", "signals": "abc", "horizon": 2,
        "clause": "F.3.4.3.2", "reference": """
          always @* begin
            if (a[0]==c[0]) reference_result=a[0] ? 8'd1 : 8'd0;
            else reference_result=b[1] ? 8'd17 : 8'd1;
          end
        """},
    # p implies q = not p or q; p is (a ##1 b), q is the current boolean c.
    "f343_implies": {
        "expression": "(a ##1 b) implies c", "signals": "abc", "horizon": 2,
        "clause": "F.3.4.3.2", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'd0;
            else if (c[0]) reference_result=8'd0;
            else reference_result=b[1] ? 8'd17 : 8'd1;
          end
        """},
    # (S ##1 @(1) 1) |-> Q with one clock: @(1) consumes exactly one tick, so a
    # match of a ##[1:2] b ending at t checks c at t+1.
    "f343_clocked_nonoverlap": {
        "expression": "(a ##[1:2] b) |=> c", "signals": "abc", "horizon": 4,
        "clause": "F.3.4.3.3", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'd32;
            else if (!b[1] && !b[2]) reference_result=8'd34;
            else if (b[1] && !b[2]) reference_result=c[2] ? 8'd2 : 8'd18;
            else if (!b[1] && b[2]) reference_result=c[3] ? 8'd3 : 8'd19;
            else if (!c[2]) reference_result=8'd18;
            else if (!c[3]) reference_result=8'd19;
            else reference_result=8'd3;
          end
        """},
    # if (b) P = b |-> P: false guard is vacuous.
    "f343_if": {
        "expression": "if (a) (b ##1 c)", "signals": "abc", "horizon": 2,
        "clause": "F.3.4.3.4", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'd32;
            else if (!b[0]) reference_result=8'd16;
            else reference_result=c[1] ? 8'd1 : 8'd17;
          end
        """},
    # (b |-> P1) and (weak(b) or P2): when b is false the first conjunct is
    # vacuous and weak(b) fails, so the conjunction reduces to P2.
    "f343_if_else": {
        "expression": "if (a) (b ##1 c) else (c ##1 b)", "signals": "abc", "horizon": 2,
        "clause": "F.3.4.3.4", "reference": """
          always @* begin
            if (a[0]) begin
              if (!b[0]) reference_result=8'd16;
              else reference_result=c[1] ? 8'd1 : 8'd17;
            end else begin
              if (!c[0]) reference_result=8'd16;
              else reference_result=b[1] ? 8'd1 : 8'd17;
            end
          end
        """},
    # case equality on the selector; the absent default is the vacuous default.
    "f343_case_single": {
        "expression": "case (a) 1'b0: (b ##1 c); endcase", "signals": "abc", "horizon": 2,
        "clause": "F.3.4.3.5", "reference": """
          always @* begin
            if (a[0]) reference_result=8'd32;
            else if (!b[0]) reference_result=8'd16;
            else reference_result=c[1] ? 8'd1 : 8'd17;
          end
        """},
    # Two labels in the first item shadow the repeated label in the second item;
    # matching is in source order and falls through to the default item.
    "f343_case_default": {
        "expression": "case ({a,b,c}) 3'b000, 3'b001: (c ##1 a); 3'b001, 3'b010: (b ##1 c); default: (a ##1 b); endcase",
        "signals": "abc", "horizon": 2, "clause": "F.3.4.3.5", "reference": """
          always @* begin
            if (!a[0] && !b[0]) begin
              if (!c[0]) reference_result=8'd16;
              else reference_result=a[1] ? 8'd1 : 8'd17;
            end else if (!a[0] && b[0] && !c[0]) begin
              if (!b[0]) reference_result=8'd16;
              else reference_result=c[1] ? 8'd1 : 8'd17;
            end else begin
              if (!a[0]) reference_result=8'd16;
              else reference_result=b[1] ? 8'd1 : 8'd17;
            end
          end
        """},
    # A signed label 2'sb10 compares by case equality (bit pattern), not by
    # signed value, so it matches the unsigned selector pattern 10.
    "f343_case_specify": {
        "expression": "case ({a,b}) 2'sb10: (c ##1 a); default: (b ##1 c); endcase",
        "signals": "abc", "horizon": 2, "clause": "F.3.4.3.5", "reference": """
          always @* begin
            if (a[0] && !b[0]) begin
              if (!c[0]) reference_result=8'd16;
              else reference_result=a[1] ? 8'd1 : 8'd17;
            end else begin
              if (!b[0]) reference_result=8'd16;
              else reference_result=c[1] ? 8'd1 : 8'd17;
            end
          end
        """},
    # always p = p until 0: no failure and no witness on a finite word holds.
    "f343_always_until": {
        "expression": "always a", "signals": "a", "horizon": 3, "clause": "F.3.4.3.8",
        "reference": """
          always @* begin
            if (!a[0]) reference_result=8'd16;
            else if (!a[1]) reference_result=8'd17;
            else if (!a[2]) reference_result=8'd18;
            else reference_result=8'd63;
          end
        """},
    # s_eventually p = not always(not p): a witness succeeds, no witness is pending.
    "f343_eventually_not_always": {
        "expression": "s_eventually a", "signals": "a", "horizon": 3, "clause": "F.3.4.3.8",
        "reference": """
          always @* begin
            if (a[0]) reference_result=8'd0;
            else if (a[1]) reference_result=8'd1;
            else if (a[2]) reference_result=8'd2;
            else reference_result=8'd79;
          end
        """},
    # p s_until q = (p until q) and s_eventually q.
    "f343_strong_until": {
        "expression": "a s_until b", "signals": "ab", "horizon": 3, "clause": "F.3.4.3.8",
        "reference": """
          always @* begin
            if (b[0]) reference_result=8'd0;
            else if (!a[0]) reference_result=8'd16;
            else if (b[1]) reference_result=8'd1;
            else if (!a[1]) reference_result=8'd17;
            else if (b[2]) reference_result=8'd2;
            else if (!a[2]) reference_result=8'd18;
            else reference_result=8'd79;
          end
        """},
    # p until_with q = p until (p and q); no witness with p holding is a weak hold.
    "f343_until_with": {
        "expression": "a until_with b", "signals": "ab", "horizon": 3, "clause": "F.3.4.3.8",
        "reference": """
          always @* begin
            if (a[0] && b[0]) reference_result=8'd0;
            else if (!a[0]) reference_result=8'd16;
            else if (a[1] && b[1]) reference_result=8'd1;
            else if (!a[1]) reference_result=8'd17;
            else if (a[2] && b[2]) reference_result=8'd2;
            else if (!a[2]) reference_result=8'd18;
            else reference_result=8'd63;
          end
        """},
    # p s_until_with q = p s_until (p and q); the strong form is pending when
    # p holds throughout but p and q never coincide.
    "f343_strong_until_with": {
        "expression": "a s_until_with b", "signals": "ab", "horizon": 3, "clause": "F.3.4.3.8",
        "reference": """
          always @* begin
            if (a[0] && b[0]) reference_result=8'd0;
            else if (!a[0]) reference_result=8'd16;
            else if (a[1] && b[1]) reference_result=8'd1;
            else if (!a[1]) reference_result=8'd17;
            else if (a[2] && b[2]) reference_result=8'd2;
            else if (!a[2]) reference_result=8'd18;
            else reference_result=8'd79;
          end
        """},
    # always[m:$] p = nexttime[m] always p with m=1.
    "f343_always_infinite": {
        "expression": "always[1:$] a", "signals": "a", "horizon": 3, "clause": "F.3.4.3.9",
        "reference": """
          always @* begin
            if (!a[1]) reference_result=8'd17;
            else if (!a[2]) reference_result=8'd18;
            else reference_result=8'd63;
          end
        """},
    # always[m:m] p = nexttime[m] p with m=1.
    "f343_always_point": {
        "expression": "always[1:1] a", "signals": "a", "horizon": 3, "clause": "F.3.4.3.9",
        "reference": "always @* reference_result=a[1] ? 8'd1 : 8'd17;"},
    # eventually[m:m] p = nexttime[m] p with m=1.
    "f343_eventually_point": {
        "expression": "eventually[1:1] a", "signals": "a", "horizon": 3, "clause": "F.3.4.3.9",
        "reference": "always @* reference_result=a[1] ? 8'd1 : 8'd17;"},
    # nexttime[2] p = nexttime nexttime[1] p.
    "f343_next_positive": {
        "expression": "nexttime[2] a", "signals": "a", "horizon": 3, "clause": "F.3.4.3.9",
        "reference": "always @* reference_result=a[2] ? 8'd2 : 8'd18;"},
    # nexttime[0] p = 1 |-> p.
    "f343_next_zero": {
        "expression": "nexttime[0] a", "signals": "a", "horizon": 2, "clause": "F.3.4.3.9",
        "reference": "always @* reference_result=a[0] ? 8'd0 : 8'd16;"},
    # s_nexttime p = not nexttime not p, applied to the temporal p = a ##1 b.
    "f343_strong_next": {
        "expression": "s_nexttime (a ##1 b)", "signals": "ab", "horizon": 3,
        "clause": "F.3.4.3.9", "reference": """
          always @* begin
            if (!a[1]) reference_result=8'd17;
            else reference_result=b[2] ? 8'd2 : 8'd18;
          end
        """},
    # s_eventually[m:$] p = s_nexttime[m] s_eventually p with m=1.
    "f343_strong_eventually_infinite": {
        "expression": "s_eventually[1:$] a", "signals": "a", "horizon": 3,
        "clause": "F.3.4.3.9", "reference": """
          always @* begin
            if (a[1]) reference_result=8'd1;
            else if (a[2]) reference_result=8'd2;
            else reference_result=8'd79;
          end
        """},
}
PROPERTIES.update(F343_PROPERTIES)


# F.3.4.2 sequence-rewrite cases (IEEE 1800-2023 Annex F, F.3.4.2.1-F.3.4.2.4)
# and the remaining F.5.2 sequence-semantics cases. Each entry pairs the
# left-hand syntax with an independent RTL reference that implements the
# right-hand expansion; no entry calls the parser, derivative engine or
# evaluator. Finite languages use per-age match counts over the h_* shift
# registers (h[0] is the latest sample and an attempt starts at the first
# sample, so the leftmost operand of a concatenation sits at the oldest
# history bit of that age). Languages with an unbounded tail are STREAMS: the
# reference is a streaming state machine, not an age table, because their
# match count does not fall to zero after a fixed age.
F342_SEQUENCES = {
    # R[*m:m] = R[*m] with m=2: exactly two consecutive a samples.
    "f342_single_range": ("a[*2:2]", "a", "F.3.4.2.1", {
        2: "h_a[1] && h_a[0]"}),
    # R1 ##m R2 = R1 ##1 1[*m-1] ##1 R2 with m=3: a, then one ANY for the
    # first ##1, two ANY samples for 1[*2], one ANY for the second ##1, then
    # b, i.e. the four-letter word a,?,?,b.
    "f342_concat_fixed": ("a ##3 b", "ab", "F.3.4.2.2", {
        4: "h_a[3] && h_b[0]"}),
    # R1 ##[0:0] R2 = fusion R1 ##0 R2: a single letter satisfying both.
    "f342_concat_zero": ("a ##[0:0] b", "ab", "F.3.4.2.2", {
        1: "h_a[0] && h_b[0]"}),
    # ##[m:n] R = 1[*m:n] ##1 R with m=1, n=2: b is the last letter of a word
    # of two or three letters.
    "f342_prefix_finite": ("##[1:2] b", "b", "F.3.4.2.2", {
        2: "h_b[0]", 3: "h_b[0]"}),
    # ##m R = 1[*m] ##1 R with m=2: three letters ending in b.
    "f342_prefix_fixed": ("##2 b", "b", "F.3.4.2.2", {
        3: "h_b[0]"}),
    # R1 ##[0:n] R2 = fusion or R1 ##[1:n] R2 with n=2: age 1 is the fusion,
    # age 2 is delay 1 and age 3 is delay 2.
    "f342_zero_finite": ("a ##[0:2] b", "ab", "F.3.4.2.2", {
        1: "h_a[0] && h_b[0]",
        2: "h_a[1] && h_b[0]",
        3: "h_a[2] && h_b[0]"}),
    # A Boolean sequence tightly matches exactly one letter that satisfies the
    # Boolean; the parentheses must not change the tight satisfaction.
    "f52_boolean": ("((a) && (!b))", "ab", "F.5.2", {
        1: "h_a[0] && !h_b[0]"}),
    # A sequence is degenerate exactly when no nonempty finite word tightly
    # satisfies it. Fusion of two empty repetition operands has no letter to
    # share, so no word, not even the empty word, matches.
    "f52_nonempty_word": ("a[*0] ##0 b[*0]", "ab", "F.5.2", {}),
}
SEQUENCES.update(F342_SEQUENCES)


F342_STREAMS = {
    # R[+] = R[*1:$]: after at least one consumed sample every letter is a.
    "f342_plus": ("a[+]", "a", "F.3.4.2.1", """
      reg started=0, all_a=1;
      always @(posedge clk) begin started<=1; all_a<=all_a && letter[0]; end
      wire [31:0] reference_count = started && all_a;
    """),
    # R[*] is the null repetition or R[*1:$]: the empty word and every all-a
    # word.
    "f342_star": ("a[*]", "a", "F.3.4.2.1", """
      reg all_a=1;
      always @(posedge clk) all_a<=all_a && letter[0];
      wire [31:0] reference_count = all_a;
    """),
    # R[*m:$] = R[*m-1] ##1 R[*1:$] with m=2: two or more a samples and every
    # sample is a.
    "f342_positive_unbounded": ("a[*2:$]", "a", "F.3.4.2.1", """
      reg [1:0] seen=0;
      reg all_a=1;
      always @(posedge clk) begin
        if (seen<2) seen<=seen+letter[0];
        all_a<=all_a && letter[0];
      end
      wire [31:0] reference_count = seen>=2 && all_a;
    """),
    # ##[*] R = ##[0:$] R: any nonempty word whose last letter satisfies R.
    "f342_prefix_star": ("##[*] b", "b", "F.3.4.2.2", """
      reg last_b=0;
      always @(posedge clk) last_b<=letter[0];
      wire [31:0] reference_count = last_b;
    """),
    # ##[+] R = ##[1:$] R: at least one leading sample and then R at the last
    # letter, so the word has two or more letters.
    "f342_prefix_plus": ("##[+] b", "b", "F.3.4.2.2", """
      reg [1:0] ticks=0;
      reg last_b=0;
      always @(posedge clk) begin
        if (ticks<2) ticks<=ticks+1;
        last_b<=letter[0];
      end
      wire [31:0] reference_count = ticks>=2 && last_b;
    """),
    # ##[m:$] R = 1[*m:$] ##1 R with m=2: three or more letters ending in b.
    "f342_prefix_unbounded": ("##[2:$] b", "b", "F.3.4.2.2", """
      reg [1:0] ticks=0;
      reg last_b=0;
      always @(posedge clk) begin
        if (ticks<3) ticks<=ticks+1;
        last_b<=letter[0];
      end
      wire [31:0] reference_count = ticks>=3 && last_b;
    """),
    # R1 ##[0:$] R2 = fusion or R1 ##[1:$] R2: the attempt starts at the first
    # sample, so a must be that first letter and b the last letter; delay 0 is
    # the one-letter fusion of the two.
    "f342_zero_unbounded": ("a ##[0:$] b", "ab", "F.3.4.2.2", """
      reg started=0, first_a=0, last_b=0;
      always @(posedge clk) begin
        if (!started) first_a<=letter[0];
        last_b<=letter[1];
        started<=1;
      end
      wire [31:0] reference_count = first_a && last_b;
    """),
    # b[->m:n] = (!b[*0:$] ##1 b)[*m:n] with m=2, n=3: exactly two or three a
    # samples, the last of which is the final letter.
    "f342_goto_finite": ("a[->2:3]", "a", "F.3.4.2.3", """
      reg [2:0] seen=0;
      reg last_a=0;
      always @(posedge clk) begin
        if (seen<4) seen<=seen+letter[0];
        last_a<=letter[0];
      end
      wire [31:0] reference_count = last_a && seen>=3'd2 && seen<=3'd3;
    """),
    # b[->m:$] = (!b[*0:$] ##1 b)[*m:$] with m=2: two or more a samples and
    # the final letter is a.
    "f342_goto_unbounded": ("a[->2:$]", "a", "F.3.4.2.3", """
      reg [2:0] seen=0;
      reg last_a=0;
      always @(posedge clk) begin
        if (seen<4) seen<=seen+letter[0];
        last_a<=letter[0];
      end
      wire [31:0] reference_count = last_a && seen>=3'd2;
    """),
    # b[=m:n] = b[->m:n] ##1 !b[*0:$] with m=1, n=2: one or two a samples and
    # any, possibly empty, run of !a after the last one.
    "f342_nonconsecutive_finite": ("a[=1:2]", "a", "F.3.4.2.3", """
      reg [2:0] seen=0;
      always @(posedge clk) if (seen<4) seen<=seen+letter[0];
      wire [31:0] reference_count = seen>=3'd1 && seen<=3'd2;
    """),
    # b[=m:$] = b[->m:$] ##1 !b[*0:$] with m=2: two or more a samples.
    "f342_nonconsecutive_unbounded": ("a[=2:$]", "a", "F.3.4.2.3", """
      reg [2:0] seen=0;
      always @(posedge clk) if (seen<4) seen<=seen+letter[0];
      wire [31:0] reference_count = seen>=3'd2;
    """),
}
STREAMS.update(F342_STREAMS)


# F.5.2 CLOCKED: a clocked sequence has the same tight satisfaction as its
# unclocked rewrite. The reference is the unclocked sequence property result
# over the same single-clock sample word.
F52_PROPERTIES = {
    "f52_clocked": {
        "expression": "@(posedge clk) (a ##1 b)", "signals": "ab", "horizon": 2,
        "clause": "F.5.2", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'd16;
            else reference_result=b[1] ? 8'd1 : 8'd17;
          end
        """},
}
PROPERTIES.update(F52_PROPERTIES)


# F.5.3.1 top-level property satisfaction.  a[k]/b[k]/c[k]/d[k] is the sample
# at tick k.  Codes are status<<4 | deciding tick: success=0t, failure=1t,
# vacuous=2t, holds=3f, pending=4f, disabled=5t.  Each reference is written
# directly from the clause and never calls the parser, engine or evaluator.
# Optional spec fields are handled in formal.property_model:
#   kind       assert property (default), assume property or cover property
#   starts     all (every enabled position) or any (some position)
#   enable     signal that must be 1 for a start to be enabled
#   assume     assumption expressions; a word is feasible when all pass
#   infeasible pass/fail result when the word violates an assumption
#   current    supply Observed snapshots so disable iff can be evaluated
F531_PROPERTIES = {
    # not P holds iff the dual word does not satisfy P.  For the decidable
    # sequence a ##1 b the dual action is just value negation at the same tick.
    "f531_not": {
        "expression": "not (a ##1 b)", "signals": "ab", "horizon": 2,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (a[0] && b[1]) reference_result=8'h11;
            else if (a[0]) reference_result=8'h01;
            else reference_result=8'h00;
          end
        """},
    # Property or: disjunction of the two operand satisfactions on this word.
    # Each a ##1 b operand decides at tick 1 with a[0] as its guard; a missing
    # operand fails at tick 0, so a disjunction of two failures decides at the
    # later of the two failure ticks.
    "f531_boolean_or": {
        "expression": "(a ##1 b) or (c ##1 d)", "signals": "abcd", "horizon": 2,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if ((a[0] && b[1]) || (c[0] && d[1])) reference_result=8'h01;
            else if (a[0] || c[0]) reference_result=8'h11;
            else reference_result=8'h10;
          end
        """},
    # Property and: conjunction on the same word.  A false operand decides at
    # its own failure tick, so the first false tick wins; both true decide at 1.
    "f531_boolean_and": {
        "expression": "(a ##1 b) and (c ##1 d)", "signals": "abcd", "horizon": 2,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (a[0] && b[1] && c[0] && d[1]) reference_result=8'h01;
            else if (!a[0] || !c[0]) reference_result=8'h10;
            else reference_result=8'h11;
          end
        """},
    # Parentheses preserve satisfaction and, with one sampled clock, the
    # clocked property uses the same Tp as the unclocked rewrite.  This word
    # model has a clock occurrence at every tick, so @(posedge clk) adds no
    # extra guard here (documented limitation).
    "f531_clock_paren": {
        "expression": "@(posedge clk) (((a) ##1 (b)))", "signals": "ab", "horizon": 2,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'h10;
            else if (b[1]) reference_result=8'h01;
            else reference_result=8'h11;
          end
        """},
    # strong(R): some tightly matching prefix 0..j within the word.  With the
    # unbounded tail a ##[1:$] b, no b by the last tick leaves no strong
    # witness, so the finite word is pending (4f), not a weak hold.
    "f531_strong": {
        "expression": "strong(a ##[1:$] b)", "signals": "ab", "horizon": 3,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'h10;
            else if (b[1]) reference_result=8'h01;
            else if (b[2]) reference_result=8'h02;
            else reference_result=8'h4f;
          end
        """},
    # weak(R): every prefix followed by infinite top satisfies strong(R).  On a
    # finite word with no match the top continuation can still match later, so
    # the result is a neutral hold (3f) rather than pending.
    "f531_weak": {
        "expression": "weak(a ##[1:$] b)", "signals": "ab", "horizon": 3,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'h10;
            else if (b[1]) reference_result=8'h01;
            else if (b[2]) reference_result=8'h02;
            else reference_result=8'h3f;
          end
        """},
    # assume property uses the same word-satisfaction as the corresponding
    # assert property form; only the directive kind differs.
    "f531_assume": {
        "expression": "a ##1 b", "signals": "ab", "horizon": 2,
        "kind": "assume property", "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'h10;
            else if (b[1]) reference_result=8'h01;
            else reference_result=8'h11;
          end
        """},
    # always unqualified assert: pass (or disabled) at every enabled position.
    # Declarative enable is true; every start 0..horizon-1 is checked.  The
    # first failing position gives the failure tick, otherwise the last passing
    # position gives the success tick.
    "f531_always": {
        "expression": "a", "signals": "a", "horizon": 3, "starts": "all",
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'h10;
            else if (!a[1]) reference_result=8'h11;
            else if (!a[2]) reference_result=8'h12;
            else reference_result=8'h02;
          end
        """},
    # initial-clocked assert checks the first c occurrence; with a single
    # sampled clock that occurrence is position 0, so only start 0 is checked.
    "f531_initial_clock": {
        "expression": "@(posedge clk) (a ##1 b)", "signals": "ab", "horizon": 2,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!a[0]) reference_result=8'h10;
            else if (b[1]) reference_result=8'h01;
            else reference_result=8'h11;
          end
        """},
    # always cover: at least one enabled starting position has a pass witness.
    # Disabled alone is insufficient, so no pass witness is a failure even if
    # every attempt is unfinished or disabled.
    "f531_cover": {
        "expression": "a", "signals": "a", "horizon": 3,
        "kind": "cover property", "starts": "any", "clause": "F.5.3.1", "reference": """
          always @* begin
            if (a[0]) reference_result=8'h00;
            else if (a[1]) reference_result=8'h01;
            else if (a[2]) reference_result=8'h02;
            else reference_result=8'h12;
          end
        """},
    # Procedural enable is outside this declarative harness; g models the
    # enabled-position set.  Every enabled start must pass, and an empty
    # enabled set is vacuously satisfied.
    "f531_enable": {
        "expression": "a", "signals": "ag", "horizon": 3, "starts": "all",
        "enable": "g", "clause": "F.5.3.1", "reference": """
          always @* begin
            if (g[0] && !a[0]) reference_result=8'h10;
            else if (g[1] && !a[1]) reference_result=8'h11;
            else if (g[2] && !a[2]) reference_result=8'h12;
            else if (g[2]) reference_result=8'h02;
            else if (g[1]) reference_result=8'h01;
            else if (g[0]) reference_result=8'h00;
            else reference_result=8'h0f;
          end
        """},
    # A word is feasible iff it satisfies every assumption.  An assertion must
    # hold on every feasible word; a word violating g is vacuously pass.
    "f531_global": {
        "expression": "a", "signals": "ag", "horizon": 1,
        "assume": ["g"], "infeasible": "pass", "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!g[0]) reference_result=8'h0f;
            else if (a[0]) reference_result=8'h00;
            else reference_result=8'h10;
          end
        """},
    # Cover on an assumption-constrained set needs a feasible pass witness; an
    # empty feasible set (this word violates g) cannot supply one.
    "f531_feasible": {
        "expression": "a", "signals": "ag", "horizon": 1,
        "assume": ["g"], "infeasible": "fail", "clause": "F.5.3.1", "reference": """
          always @* begin
            if (!g[0]) reference_result=8'h1f;
            else if (a[0]) reference_result=8'h00;
            else reference_result=8'h10;
          end
        """},
    # Pass and disabled are mutually exclusive; fail means neither.  A disable
    # at the first position disables the attempt before the boolean a decides,
    # while a disable after the pass at position 0 cannot retract that pass.
    "f531_status": {
        "expression": "disable iff (d) (a)", "signals": "ad", "horizon": 2,
        "current": True, "clause": "F.5.3.1", "reference": """
          always @* begin
            if (d[0]) reference_result=8'h50;
            else if (a[0]) reference_result=8'h00;
            else reference_result=8'h10;
          end
        """},
    # disable iff is disabled when a disable occurs and the prefix before its
    # first occurrence passes under infinite top but not under infinite bottom.
    # For a ##[1:2] b each prefix at or before the last needed tick has that
    # property, so the first disable before the deciding tick disables.  A
    # failure that decided earlier is not retroactively disabled.  Parentheses
    # around the property preserve the result.
    "f531_disabled": {
        "expression": "disable iff (d) (((a) ##[1:2] (b)))", "signals": "abd", "horizon": 3,
        "current": True, "clause": "F.5.3.1", "reference": """
          always @* begin
            if (d[0]) reference_result=8'h50;
            else if (!a[0]) reference_result=8'h10;
            else if (d[1]) reference_result=8'h51;
            else if (b[1]) reference_result=8'h01;
            else if (d[2]) reference_result=8'h52;
            else if (b[2]) reference_result=8'h02;
            else reference_result=8'h12;
          end
        """},
    # Plain top-level properties use the underlying property semantics and
    # parentheses preserve them.  A pass before the first disable is retained;
    # a disable before the deciding tick makes the attempt disabled rather than
    # pass.  The pass-on-prefix-then-infinite-bottom branch is not modelled
    # (see limitation in the note).
    "f531_top_pass": {
        "expression": "disable iff (d) (((a) ##1 (b)))", "signals": "abd", "horizon": 2,
        "current": True, "clause": "F.5.3.1", "reference": """
          always @* begin
            if (d[0]) reference_result=8'h50;
            else if (!a[0]) reference_result=8'h10;
            else if (d[1]) reference_result=8'h51;
            else if (b[1]) reference_result=8'h01;
            else reference_result=8'h11;
          end
        """},
    # Neutral satisfaction on a nonempty finite word without local variables:
    # a until b with no b witness holds (3f) rather than failing or pending.
    "f531_domain": {
        "expression": "a until b", "signals": "ab", "horizon": 3,
        "clause": "F.5.3.1", "reference": """
          always @* begin
            if (b[0]) reference_result=8'h00;
            else if (!a[0]) reference_result=8'h10;
            else if (b[1]) reference_result=8'h01;
            else if (!a[1]) reference_result=8'h11;
            else if (b[2]) reference_result=8'h02;
            else if (!a[2]) reference_result=8'h12;
            else reference_result=8'h3f;
          end
        """},
}
PROPERTIES.update(F531_PROPERTIES)


# F.5.3.3 nonvacuity.  Each entry is a finite-word property; actual_result is
# the one-bit F.5.3.3 relation computed by sva_reference.nonvacuity, while the
# reference is written directly from the clause bullet and never calls the
# parser, engine, evaluator or nonvacuity module.  a[k] is the sample at tick k.
NONVACUITY = {
    # Base: strong(R) and weak(R) are nonvacuous; parentheses and not preserve
    # nonvacuity.  The conjunction of two negated sequence properties is
    # therefore nonvacuous on every word, independently of their truth.
    "f533_base_strong_weak_not": {
        "expression": "(not (strong(a ##1 b))) and (not (weak(c ##1 d)))",
        "signals": "abcd", "horizon": 2, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-BASE",
        "reference": "always @* reference_result=1'b1;"},
    # Boolean implication equation: nonvacuous iff the antecedent is true and
    # both the antecedent evaluation and the consequent evaluation are
    # nonvacuous.  The antecedent here is the Boolean a; the consequent is the
    # overlapping implication whose nonvacuity is c[0] && d[1].
    "f533_booleans_implies": {
        "expression": "(a) implies ((c ##1 d) |-> e)",
        "signals": "acde", "horizon": 2, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-BOOLEANS",
        "reference": "always @* reference_result=a[0] && c[0] && d[1];"},
    # Nonvacuity is separate from satisfaction.  For (a ##[1:2] b) |-> c the
    # relation is a[0] && (b[1] || b[2]) and ignores c and the consequent
    # truth; a[0]=0 is a vacuous pass and a match with c false is a
    # nonvacuous failure.  The two tight antecedent endpoints also exercise
    # the F.5.3.3 implication "there exists an endpoint" rule.
    "f533_nonvacuity_separate": {
        "expression": "(a ##[1:2] b) |-> c",
        "signals": "abc", "horizon": 3, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-NONVACUITY",
        "reference": "always @* reference_result=a[0] && (b[1] || b[2]);"},
    # until: exists an in-word suffix with either operand nonvacuous and every
    # earlier suffix satisfies left and not right.  Both operands are
    # overlapping implications, so their suffix nonvacuity is a[i] and
    # nexttime(c |-> d) has nonvacuity c[i+1]; the earlier-suffix guard is
    # (!a[j] || b[j]) && c[j+1] && !d[j+1].
    "f533_until_operands": {
        "expression": "(a |-> b) until nexttime (c |-> d)",
        "signals": "abcd", "horizon": 3, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-UNTIL",
        "reference": """
          wire g0=(!a[0]||b[0]) && c[1] && !d[1];
          wire g1=(!a[1]||b[1]) && c[2] && !d[2];
          always @* reference_result=(a[0]||c[1])
            || (g0 && (a[1]||c[2])) || (g0 && g1 && a[2]);
        """},
    # always: exists an in-word suffix whose operand is nonvacuous while every
    # earlier suffix satisfies it.  For a |-> b, nonvacuity at i is a[i] and
    # satisfaction at j is (!a[j] || b[j]).
    "f533_always_guard": {
        "expression": "always (a |-> b)",
        "signals": "ab", "horizon": 3, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-ALWAYS",
        "reference": """
          wire g0=!a[0]||b[0];
          wire g1=!a[1]||b[1];
          always @* reference_result=a[0] || (g0 && a[1])
            || (g0 && g1 && a[2]);
        """},
    # s_eventually: exists an in-word suffix whose operand is nonvacuous while
    # every earlier suffix satisfies not operand.  For a |-> b, not-operand
    # truth at j is a[j] && !b[j].
    "f533_eventually_guard": {
        "expression": "s_eventually (a |-> b)",
        "signals": "ab", "horizon": 3, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-EVENTUALLY",
        "reference": """
          wire n0=a[0] && !b[0];
          wire n1=a[1] && !b[1];
          always @* reference_result=a[0] || (n0 && a[1])
            || (n0 && n1 && a[2]);
        """},
    # nexttime uses suffix index 1, not any other suffix.  The operand's
    # nonvacuity at suffix 1 is a[1] && b[2], the antecedent match starting at
    # tick 1; a[0] && b[1] would be the wrong (index 0) match.
    "f533_nexttime_index": {
        "expression": "nexttime ((a ##1 b) |-> c)",
        "signals": "abc", "horizon": 3, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-NEXT-TEXT",
        "reference": "always @* reference_result=a[1] && b[2];"},
    # disable iff: the operand is nonvacuous and either no abort occurs or an
    # abort-free prefix already settles the operand.  strong(a ##1 b) fails on
    # a bottom extension and is satisfied by a top extension until its match
    # is complete, so a prefix of one letter settles only when a[0] is false.
    # An abort at tick 1 therefore forces vacuity exactly when a[0] is true;
    # an abort at tick 0 always does.  (accept_on/reject_on are outside the
    # supported parser subset.)
    "f533_abort_disable_iff": {
        "expression": "disable iff (r) (strong(a ##1 b))",
        "signals": "abr", "horizon": 2, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-ABORT",
        "reference": "always @* reference_result=(!r[0]) && (!r[1] || !a[0]);"},
    # Nonvacuous satisfaction is satisfaction and nonvacuity.  s_nexttime is a
    # derived operator: s_nexttime P = not nexttime not P.  On this word its
    # nonvacuity is a[1] and its satisfaction is (!a[1] || b[1]), so the
    # conjunction is a[1] && b[1].
    "f533_nonvacuous_satisfaction": {
        "expression": "s_nexttime (a |-> b)",
        "signals": "ab", "horizon": 2, "clause": "F.5.3.3",
        "requirement": "SV2023-F.5.3.3-EXTRACT-NONVACUOUS-SATISFACTION",
        "mode": "satisfaction",
        "reference": "always @* reference_result=a[1] && b[1];"},
}
