/*
:name: test_coverage_assertion_success_counts
:description: Assertion coverage counts an assertion as covered once it has succeeded, so of three assertions only the one that passes adds to $coverage_get, while $coverage_get_max counts all three (IEEE 1800-2023 Section 40.2.2)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.2.2 40.3.2.3 40.3.2.2 40.3.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_assertion_success_counts.expected
*/
// IEEE 1800-2023 §40.2.2: the primitive of assertion coverage is one
// assertion, covered when it has had at least one success; over an instance
// the coverage number is the sum of its primitives. §40.3.2.2 and §40.3.2.3:
// $coverage_get_max counts the coverable items and $coverage_get those covered
// so far.
//
// The instance u has three assertions. a_never is clocked by a signal that
// never rises, so it is never attempted. a_fail checks a bit that is always 0,
// so each of its four attempts fails, and its fail action counts them.
// a_pass checks a bit that is always 1, so each attempt succeeds. The clock
// rises at 5, 15, 25 and 35. Before the first edge no assertion has succeeded;
// at 40 only a_pass has, so one of the three items is covered. Which parts of
// a design have assertion coverage depends on the tool (40.3.2.1), so the
// numbers are checked only where a start of assertion coverage of u at time 0
// gives SV_COV_OK. A tool that counted attempts would cover a_fail too, and one
// that counted successes would give 4 instead of 1.

`timescale 1ns/1ns

module test_coverage_assertion_success_counts_unit(input logic clk);
  logic quiet = 1'b0;
  bit on = 1'b1, off = 1'b0;
  int fails = 0;

  a_never: assert property (@(posedge quiet) on);
  a_fail: assert property (@(posedge clk) off) else fails++;
  a_pass: assert property (@(posedge clk) on);
endmodule

module test_coverage_assertion_success_counts;
  logic clk = 0;
  int started, max0, cur0, max1, cur1;

  test_coverage_assertion_success_counts_unit u(.clk(clk));

  always #5 clk = ~clk;

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  initial begin
    started = $coverage_control(`SV_COV_START, `SV_COV_ASSERTION, `SV_COV_MODULE, u);
    #1;
    max0 = $coverage_get_max(`SV_COV_ASSERTION, `SV_COV_MODULE, u);
    cur0 = $coverage_get(`SV_COV_ASSERTION, `SV_COV_MODULE, u);
    #39;
    max1 = $coverage_get_max(`SV_COV_ASSERTION, `SV_COV_MODULE, u);
    cur1 = $coverage_get(`SV_COV_ASSERTION, `SV_COV_MODULE, u);
    $display("start is not ERROR: %s", yes_no(started != `SV_COV_ERROR));
    $display("fail actions of a_fail: %0d", u.fails);
    $display("with assertion coverage started, the maximum is the 3 assertions: %s",
             yes_no(started != `SV_COV_OK || (max0 == 3 && max1 == 3)));
    $display("with assertion coverage started, none is covered before the first edge: %s",
             yes_no(started != `SV_COV_OK || cur0 == 0));
    $display("with assertion coverage started, only the assertion that succeeded is covered: %s",
             yes_no(started != `SV_COV_OK || cur1 == 1));
    $finish;
  end
endmodule
