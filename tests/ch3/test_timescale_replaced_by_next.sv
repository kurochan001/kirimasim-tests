/*
:name: test_timescale_replaced_by_next
:description: A `timescale directive applies to the design elements that follow it until the next `timescale directive replaces it (IEEE 1800-2023 Section 3.14.2.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.1 22.7 20.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timescale_replaced_by_next.expected
*/
// IEEE 1800-2023 §3.14.2.1: a `timescale directive sets the time unit and
// precision of the design elements after it that do not declare their own,
// until another `timescale directive is read. The first two modules below
// have a time unit of 1 ns and the third one of 10 ns. Each prints $time in
// its own unit (20.3.1): the delay of 2 in the third module ends at 20 ns,
// between the ends of the delays of 15 and 25 of the others.

`timescale 1ns / 1ns

module test_timescale_replaced_by_next_a;
  initial #15 $display("a: $time=%0d", $time);
endmodule

module test_timescale_replaced_by_next_b;
  initial #25 $display("b: $time=%0d", $time);
endmodule

`timescale 10ns / 1ns

module test_timescale_replaced_by_next_c;
  initial #2 $display("c: $time=%0d", $time);
endmodule

module test_timescale_replaced_by_next;
  test_timescale_replaced_by_next_a a();
  test_timescale_replaced_by_next_b b();
  test_timescale_replaced_by_next_c c();
  initial #3 $display("top: $time=%0d", $time);
endmodule
