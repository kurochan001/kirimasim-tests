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
