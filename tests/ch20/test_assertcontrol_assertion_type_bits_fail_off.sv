/*
:name: test_assertcontrol_assertion_type_bits_fail_off
:description: the assertion_type argument of $assertcontrol selects concurrent (1), simple immediate (2), observed deferred immediate (4) and final deferred immediate (8) assertions, values can be OR-ed, and without it all types are selected (IEEE 1800-2023 Section 20.11)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.11 16.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assertcontrol_assertion_type_bits_fail_off.expected
*/
// IEEE 1800-2023 §20.11, Table 20-6: assertion_type 1 selects concurrent
// assertions, 2 simple immediate, 4 observed deferred immediate and 8 final
// deferred immediate assertions (16 to 128 select expect statements and
// violation reports); OR-ed values select several types, and the default is
// 255, all of them. control_type 9 (FailOff) stops the fail actions of the
// selected assertions and 8 (FailOn) enables them again.
// In each phase every assertion fails once: the simple immediate one at
// once, the observed deferred one in the Reactive region and the final
// deferred one in the Postponed region of the same step (§16.4), and the
// concurrent one at the next clock tick; each fail action prints a line.
// Before a phase $assertcontrol(9, mask) turns off the fail actions of the
// selected types, and after it $assertcontrol(8) turns all of them on
// again. The masks are none, 1, 2, 4, 8, 10 (2|8), 5 (1|4) and no mask at
// all.
// Icarus Verilog 13.0 does not support concurrent and deferred assertions.

`timescale 1ns/1ns

module test_assertcontrol_assertion_type_bits_fail_off;
  logic clk = 0;
  logic a = 1;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  a_c: assert property (@(posedge clk) a) else $display("  concurrent failed");

  task automatic fire();
    a_si: assert (a) else $display("  simple immediate failed");
    a_od: assert #0 (a) else $display("  observed deferred failed");
    a_fd: assert final (a) else $display("  final deferred failed");
  endtask

  task automatic phase(string name);
    $display("%s:", name);
    a = 0;
    fire();
    #10 a = 1;
    $assertcontrol(8);
  endtask

  initial begin
    phase("none");
    $assertcontrol(9, 1);
    phase("mask 1");
    $assertcontrol(9, 2);
    phase("mask 2");
    $assertcontrol(9, 4);
    phase("mask 4");
    $assertcontrol(9, 8);
    phase("mask 8");
    $assertcontrol(9, 10);
    phase("mask 10");
    $assertcontrol(9, 5);
    phase("mask 5");
    $assertcontrol(9);
    phase("no mask");
    $finish;
  end
endmodule
