/*
:name: test_illegal_clocking_signal_dynamic_array_element
:description: a clocking signal cannot designate an element of a dynamic array, whose references are restricted to procedural blocks (IEEE 1800-2023 Sections 14.3 and 6.21)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.3 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clockvar bv is associated with da[0], an element of the dynamic array da, which may be referenced only in procedural blocks
:expected_stderr_regex: test_illegal_clocking_signal_dynamic_array_element\.sv:40:
*/
// IEEE 1800-2023 §14.3: it shall be illegal for a clocking signal to designate
// a variable restricted to a procedural block (6.21). §6.21: references to
// automatic variables and to elements of dynamically sized arrays are limited
// to procedural blocks; a static variable, even one declared in a named
// block, may be referenced hierarchically. The expression after = in a
// clocking item (14.5) is outside any procedural block, so it cannot name the
// element da[0] of the dynamic array da. The clockvar m names a module
// variable, which is legal, and the procedural $display of da[0] is legal.
// Icarus Verilog 13.0 does not support clocking blocks; the errors it reports
// do not count.

`timescale 1ns/1ns

module test_illegal_clocking_signal_dynamic_array_element;
  logic clk = 0;
  int m = 0;
  int da[];

  initial begin
    da = new[1];
    #1 da[0] = 1;
  end
  initial #2 $display("da[0]=%0d", da[0]);

  clocking cb @(posedge clk);
    input m;
    input bv = da[0];   // illegal
  endclocking
endmodule
