/*
:name: test_timescale_child_units_in_parent
:description: A delay in a module with a time unit of 10ns lasts ten times as long as the same delay in a module with 1ns, and each module reports $time in its own unit (IEEE 1800-2023 Section 22.7)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.7 3.14.2.3 20.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timescale_child_units_in_parent.expected
*/
// IEEE 1800-2023 §22.7: `timescale sets the time unit of the design elements
// that follow it. The child has a unit of 10ns, so its #3 lasts 30ns, and its
// $time says 3 (20.3.1); the parent has a unit of 1ns and sees the event that
// the child triggers then at its time 30. The child prints before it
// triggers the event, so the order of the lines is fixed.

`timescale 10ns/1ns
module test_timescale_child_units_in_parent_child;
  event done;

  initial begin
    #3;
    $display("child: time=%0d realtime=%0.1f", $time, $realtime);
    -> done;
  end
endmodule

`timescale 1ns/1ns
module test_timescale_child_units_in_parent;
  test_timescale_child_units_in_parent_child c();

  initial begin
    #3 $display("parent: time=%0d", $time);
    @(c.done) $display("parent: time=%0d after the child's event", $time);
  end
endmodule
