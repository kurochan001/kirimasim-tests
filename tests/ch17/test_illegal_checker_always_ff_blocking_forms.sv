/*
:name: test_illegal_checker_always_ff_blocking_forms
:description: A checker always_ff may contain selection, loops, subroutine calls, let declarations and immediate, deferred and concurrent assertions and assign with nonblocking assignments, but not a blocking assignment (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always_ff procedure of the checker writes the checker variable acc with the blocking assignment acc = 0, although 17.5 allows blocking assignments only in always_comb and always_latch
:expected_stderr_regex: test_illegal_checker_always_ff_blocking_forms\.sv:(51|59|72):
*/
// IEEE 1800-2023 §17.5: checker always procedures may contain blocking
// assignments only in always_comb and always_latch; always_ff may contain
// selection and loop statements, subroutine calls, immediate, deferred and
// concurrent assertions and let declarations, with nonblocking assignments.
// The always_comb and always_latch procedures below use blocking assignments,
// and the always_ff procedure uses a selection, a loop, a call of the
// automatic function inc, the let both, an immediate assertion, a deferred
// assertion and a concurrent assertion with nonblocking assignments. Its last
// statement is the blocking assignment acc = 0, which is illegal in
// always_ff, so the design is illegal. The rest of the checker and the module
// are legal. Icarus Verilog 13.0 has no checkers, and Verilator 5.052 does
// not implement the deferred assertion, so the expected rejection follows the
// clause alone.

`timescale 1ns/1ns

checker cb_always (input logic clk, input logic a, input logic b,
                   output int n, output bit o, output bit l);
  int acc = 0;
  bit lat = 1'b0;

  function automatic int inc (int x);
    return x + 1;
  endfunction

  let both = a && b;

  always_comb begin
    o = both;
    if (both) o = b;
    for (int i = 0; i < 1; i++) o = o | a;
  end

  always_latch begin
    if (a) l = b;
  end

  always_ff @(posedge clk) begin
    let nxt = acc + 1;
    if (a) acc <= inc(nxt);
    else acc <= acc - 1;
    for (int i = 0; i < 2; i++) acc <= acc + i;
    a1: assert (a || !a);
    a2: assert #0 (b || !b);
    a3: assert property (@(posedge clk) a |=> b);
    acc = 0;   // illegal: blocking assignment in always_ff
  end

  assign n = acc;
endchecker : cb_always

module test_illegal_checker_always_ff_blocking_forms;
  logic clk = 1'b0;
  logic a = 1'b1;
  logic b = 1'b1;
  int n;
  bit o, l;

  cb_always u_cb (.clk(clk), .a(a), .b(b), .n(n), .o(o), .l(l));

  always #5 clk = ~clk;

  initial #20 $finish;
endmodule
