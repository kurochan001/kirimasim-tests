/*
:name: test_ch9_extra_initial_always_no_order
:description: initial and always procedures all begin execution at time zero with no implied order between them, so either order of their first statements is accepted (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch9_extra_initial_always_no_order.expected
*/
// IEEE 1800-2023 §9.2: initial and always procedures all start at time zero,
// and the standard defines no order between them. A test that assumed that
// every initial procedure runs before every always procedure would be wrong.
//
// Two initial procedures and one always procedure each record their start.
// When the #0 initial resumes, all three have started; the always procedure
// is blocked at its event control, which is still part of its execution. The
// order variable holds 12 if the always procedure ran after the first
// initial procedure and 21 if it ran before, and the test accepts both: it
// prints only whether the observed order is one of the two permitted ones.
// No output depends on which order the tool chooses.

`timescale 1ns/1ns

module test_ch9_extra_initial_always_no_order;
  event e;
  int initial_ran = 0;
  int always_ran = 0;
  int order = 0;

  initial begin
    initial_ran = 1;
    order = order * 10 + 1;
  end

  always begin
    always_ran = 1;
    order = order * 10 + 2;
    @e;
  end

  initial begin
    #0;
    $display("both_started=%0d", initial_ran && always_ran);
    $display("order_is_one_of_two=%0d", (order == 12) || (order == 21));
    #1 $finish;
  end
endmodule
