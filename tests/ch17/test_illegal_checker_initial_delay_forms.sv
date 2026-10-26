/*
:name: test_illegal_checker_initial_delay_forms
:description: A checker initial procedure accepts let declarations, immediate, deferred and concurrent assertions and an event control, but not a delay control (IEEE 1800-2023 Section 17.5)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure of the checker ends with the delay control #1, which is not an event control and is not one of the statements 17.5 permits there
:expected_stderr_regex: test_illegal_checker_initial_delay_forms\.sv:(29|35|46):
*/
// IEEE 1800-2023 §17.5: an initial procedure in a checker body may contain
// let declarations, immediate, deferred and concurrent assertions, and a
// procedural timing control statement that uses an event control only. The
// procedure below declares a let, waits with @(posedge clk), and contains an
// immediate assertion, a deferred assertion and a concurrent assertion, all
// of which are permitted; it then uses the delay control #1, which is a
// procedural timing control statement but not an event control, so the design
// is illegal. The rest of the checker and the module are legal. Icarus
// Verilog 13.0 has no checkers and Verilator 5.052 accepts the delay control,
// so the expected rejection follows the clause alone.

`timescale 1ns/1ns

checker cb_init (input logic a, input logic b, input logic clk,
                 output bit o);
  initial begin
    let inv = !a;
    @(posedge clk);
    assert (inv == !a);
    assert #0 (b == b);
    a1: assert property (@(posedge clk) a |=> b);
    #1;   // illegal: a delay control in a checker initial procedure
  end
  assign o = a;
endchecker : cb_init

module test_illegal_checker_initial_delay_forms;
  logic clk = 1'b0;
  logic a = 1'b1;
  logic b = 1'b1;
  bit o;

  cb_init u_cb (.a(a), .b(b), .clk(clk), .o(o));

  always #5 clk = ~clk;

  initial #30 $finish;
endmodule
