/*
:name: test_negative_pulse_cancelled
:description: When the trailing edge of a pulse on a path output would come before its leading edge, the leading edge is cancelled and the output does not change; showcancelled makes such a pulse show as x instead (IEEE 1800-2023 Section 30.7.4.2)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7.4.2 30.7.4 30.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_negative_pulse_cancelled.expected
*/
// IEEE 1800-2023 §30.7.4.2: with unequal rise and fall delays, the trailing
// edge of a narrow pulse can be scheduled before its leading edge. Normally
// the leading edge is then cancelled, and as the output starts and ends at the
// same value, it does not change at all. With a showcancelled declaration for
// the path output, the pulse shows as x instead. Both cells rise after 5 and
// fall after 1, and a is 1 from 10 to 12, so the rise would come at 15 and
// the fall at 13. y_plain never changes; y_shown goes to x for a while and
// ends at 0. When exactly the x starts depends on the pulse style, so the
// test only notes whether it came.
//
// Icarus Verilog 13.0 leaves y_shown unchanged as well.

`timescale 1ns/1ns

module test_negative_pulse_cancelled_plain (input a, output y);
  buf (y, a);
  specify
    (a => y) = (5, 1);
  endspecify
endmodule

module test_negative_pulse_cancelled_shown (input a, output y);
  buf (y, a);
  specify
    showcancelled y;
    (a => y) = (5, 1);
  endspecify
endmodule

module test_negative_pulse_cancelled;
  logic a = 0;
  wire y_plain, y_shown;
  int plain_changes = 0;
  bit shown_x = 0;

  test_negative_pulse_cancelled_plain p(a, y_plain);
  test_negative_pulse_cancelled_shown s(a, y_shown);

  always @(y_plain) if ($time > 5) plain_changes++;
  always @(y_shown) if (y_shown === 1'bx && $time > 5) shown_x = 1;

  initial begin
    #10 a = 1;
    #2 a = 0;
    #18 $display("plain: %0d changes, ends at %b; shown: went to x %0d, ends at %b",
                 plain_changes, y_plain, shown_x, y_shown);
  end
endmodule
