/*
:name: test_interconnect_primitive_terminal
:description: An interconnect net connected to a primitive terminal is treated as a scalar wire, so a gate can drive it and a module port can read it (IEEE 1800-2023 Section 23.3.3.7.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7.2 6.6.8 23.3.3.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_primitive_terminal.expected
*/
// IEEE 1800-2023 §6.6.8: an interconnect net can express net port and
// terminal connections. §23.3.3.7.2: connected to a primitive terminal, it is
// treated as though it connected to a scalar wire. The output terminal of a
// not gate drives t, and the reader, whose port merges with t (23.3.3.7.1),
// sees the inverted 1, that is 0.

module test_interconnect_primitive_terminal_reader(input wire logic i);
  initial #1 $display("%m sees %b", i);
endmodule

module test_interconnect_primitive_terminal;
  interconnect t;

  not g(t, 1'b1);
  test_interconnect_primitive_terminal_reader r(t);
endmodule
