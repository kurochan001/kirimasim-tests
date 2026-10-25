/*
:name: test_checker_body_declaration_kinds
:description: A checker body may hold a rand data declaration, a function, a nested checker and its instance, an assertion item declaration of each kind, a covergroup and its instance, a genvar, a clocking declaration, a default clocking, a default disable iff and an empty declaration, and each declaration keeps its value (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.2 17.7 A.1.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_checker_body_declaration_kinds.expected
*/
// IEEE 1800-2023 17.2 and A.1.8: checker_or_generate_item_declaration is one
// of a data declaration with an optional rand, a function declaration, a
// nested checker declaration, an assertion item declaration, a covergroup
// declaration, a genvar declaration, a clocking declaration, a default
// clocking, a default disable iff, or an empty semicolon. The body of
// cb_decls holds these (the nested checker is in
// test_checker_rand_and_nested_checker):
//   - the data declaration rf = 3,
//   - the function twice,
//   - a sequence, a property and a let as assertion item declarations,
//   - the covergroup cg and its instance cgi, sampling d at the clock,
//   - a genvar, the clocking block cb, default clocking cb, a default
//     disable iff that no value of d triggers, and an empty semicolon.
// An always_ff procedure adds inc to cnt and computes
// seen = twice(d) + rf + dflt at each rising edge, so every declaration
// contributes to a printed number: cnt = 2, seen = 2 + 3 + 5 = 10.
//
// Icarus Verilog 13.0 has no checkers. Verilator 5.052 produces these values.

checker cb_decls (
  input  logic clk,
  input  logic d,
  input  int dflt,
  input  int inc,
  output int cnt,
  output int seen
);
  int rf = 3;
  genvar g;

  function automatic int twice(int x);
    return 2 * x;
  endfunction

  sequence s_one;
    d == 1'b1;
  endsequence

  property p_one;
    @(posedge clk) d |=> d;
  endproperty

  let is_high = (d == 1'b1);

  clocking cb @(posedge clk);
    input d;
  endclocking

  default clocking cb;
  default disable iff (d != 1'b0 && d != 1'b1);
  ;

  covergroup cg @(posedge clk);
    coverpoint d;
  endgroup

  cg cgi = new;

  always_ff @(posedge clk) begin
    cnt <= cnt + inc;
    seen <= twice(d) + rf + dflt;
  end
endchecker

module test_checker_body_declaration_kinds;
  logic clk = 1'b0;
  logic d = 1'b1;
  int cnt = 0, seen;

  cb_decls u_cb (.clk(clk), .d(d), .dflt(5), .inc(1), .cnt(cnt), .seen(seen));

  initial begin
    #2 clk = 1'b1;
    #2 clk = 1'b0;
    #2 clk = 1'b1;
    #2 $display("cnt=%0d seen=%0d", cnt, seen);
  end
endmodule
