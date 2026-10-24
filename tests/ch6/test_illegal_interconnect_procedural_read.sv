/*
:name: test_illegal_interconnect_procedural_read
:description: An interconnect net that connects two ports cannot be read in procedural code (IEEE 1800-2023 Section 6.6.8)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure reads the interconnect net n as an argument of $display
:expected_stderr_regex: test_illegal_interconnect_procedural_read\.sv:34:
*/
// IEEE 1800-2023 §6.6.8: an interconnect net only expresses port and terminal
// connections; it shall not be used in any procedural context. Here n
// connects the output of one child to the input of another, which is legal
// (23.3.3.7.1); the initial procedure that passes n to $display is the only
// error.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release do not support
// interconnect and stop at its declaration, which does not count.

module test_illegal_interconnect_procedural_read_src (output wire logic o);
  assign o = 1'b1;
endmodule

module test_illegal_interconnect_procedural_read_dst (input wire logic i);
endmodule

module test_illegal_interconnect_procedural_read;
  interconnect n;
  test_illegal_interconnect_procedural_read_src s(.o(n));
  test_illegal_interconnect_procedural_read_dst d(.i(n));

  initial #1 $display("n=%b", n);   // illegal: n is an interconnect net
endmodule
