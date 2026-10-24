/*
:name: test_illegal_specify_path_source_variable_port
:description: The source of a module path has to be a net; an input port declared with var is a variable and cannot be one (IEEE 1800-2023 Section 30.4.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module path starts at the input port a, which is declared with var and so is a variable, not a net
:expected_stderr_regex: test_illegal_specify_path_source_variable_port\.sv:27:
*/
// IEEE 1800-2023 §30.4.1: the source of a module path shall be a net that is
// connected to an input or inout port. §23.2.2.3: an input port declared with
// the keyword var is a variable. The cell has the net input b and the variable
// input a; the path from b to y is legal, the path from a to y is not,
// although a is an input port. Icarus Verilog 13.0 and Verilator 5.052
// accept the design.

module test_illegal_specify_path_source_variable_port_cell (output wire y,
                                                            input var logic a,
                                                            input wire b);
  assign y = a & b;
  specify
    (b => y) = 2;
    (a => y) = 3;      // illegal: a is a variable, not a net
  endspecify
endmodule

module test_illegal_specify_path_source_variable_port;
  logic a = 0, b = 0;
  wire y;

  test_illegal_specify_path_source_variable_port_cell c (y, a, b);
endmodule
