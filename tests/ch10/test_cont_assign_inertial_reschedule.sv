/*
:name: test_cont_assign_inertial_reschedule
:description: when the right-hand side of a delayed continuous assignment changes before an earlier change has reached the net, a value equal to the net is not scheduled again, and a different value is scheduled after the delay of its own transition, counted from the new change (IEEE 1800-2023 Section 10.3.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cont_assign_inertial_reschedule.expected
*/
// IEEE 1800-2023 §10.3.3: when a right-hand operand changes before an
// earlier change has propagated, the right-hand side is evaluated again; if
// it differs from the value scheduled, the scheduled change is removed. If
// the new value equals the current value of the left-hand side, nothing is
// scheduled; otherwise a delay is computed from the current left-hand value,
// the new right-hand value and the delays of the statement, and the new
// value is scheduled that long after the new change.
//
// v = q with delay 4:
//   t=20 q 0 -> 1, t=22 q -> 0: the new value is the current value of v, so
//   v never changes (sampled 0 at 25 and 27).
//   t=32 q 0 -> 1, t=34 q -> 2: v becomes 2 at 38, four units after the
//   second change; it is never 1, and it is still 0 at 36.
// y = p with delays (3, 6), y = 5:
//   t=44 p -> 0 would fall at 50; t=46 p -> 7: from the current y = 5 to 7
//   is a rise, so y becomes 7 at 49 and is never 0.

`timescale 1ns/1ns
module test_cont_assign_inertial_reschedule;
  logic [3:0] q = 4'd0, p = 4'd5;
  wire [3:0] v, y;

  assign #4 v = q;
  assign #(3, 6) y = p;

  always @(v) if ($time >= 20) $display("t=%0t v=%0d", $time, v);
  always @(y) if ($time >= 20) $display("t=%0t y=%0d", $time, y);

  initial begin
    #20 q = 1;
    #2 q = 0;
    #10 q = 1;
    #2 q = 2;
    #10 p = 0;
    #2 p = 7;
    #10 $finish;
  end

  initial begin
    #25 $display("t=%0t sample v=%0d", $time, v);
    #2 $display("t=%0t sample v=%0d", $time, v);
    #9 $display("t=%0t sample v=%0d", $time, v);
    #12 $display("t=%0t sample y=%0d", $time, y);
    #3 $display("t=%0t sample y=%0d", $time, y);
  end
endmodule
