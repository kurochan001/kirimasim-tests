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
