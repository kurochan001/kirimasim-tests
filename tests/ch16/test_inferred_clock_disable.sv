/*
:name: test_inferred_clock_disable
:description: Formal arguments of a property that default to $inferred_clock and $inferred_disable take the default clocking and the default disable condition where the property is asserted, unless the instance gives actual arguments (IEEE 1800-2023 Section 16.14.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.7 16.15 14.12 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inferred_clock_disable.expected
*/
// IEEE 1800-2023 §16.14.7: the property p_next has a clock argument that
// defaults to $inferred_clock and a disable argument that defaults to
// $inferred_disable. In a_inferred they are replaced by what holds where the
// assertion is: the default clocking, posedge clk1 (14.12), and the default
// disable condition rst (16.15). a_given passes posedge clk2 and 1'b0 instead.
// a is always 1 and b always 0, so each attempt that is not disabled fails one
// tick of its clock later. clk1 ticks at 5, 15 and 25: the attempt at 5 is
// disabled, as rst is 1 until 12 (16.12), and the one at 15 fails at 25. clk2
// ticks at 7, 17 and 27, and both of those attempts fail by 30.

`timescale 1ns/1ns

module test_inferred_clock_disable;
  logic clk1 = 0, clk2 = 0, a = 1, b = 0, rst = 1;
  int f_inferred = 0, f_given = 0;

  default clocking @(posedge clk1); endclocking
  default disable iff rst;

  property p_next(x, y, ck = $inferred_clock, dis = $inferred_disable);
    @(ck) disable iff (dis) x |=> y;
  endproperty

  a_inferred: assert property (p_next(a, b)) else f_inferred++;
  a_given: assert property (p_next(a, b, posedge clk2, 1'b0)) else f_given++;

  always #5 clk1 = ~clk1;

  initial begin
    #2;
    forever #5 clk2 = ~clk2;
  end

  initial begin
    #12 rst = 0;
    #18 $display("%0d: inferred %0d failure(s), given %0d failure(s)", $time, f_inferred, f_given);
    $finish;
  end
endmodule
