/*
:name: test_illegal_implicit_name_port_missing_with_default
:description: A .name connection whose name is not declared in the instantiating module is an error and declares no implicit net, even when the input port has a default value (IEEE 1800-2023 Section 23.3.2.3)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.2.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the .rst connection of u names rst, which the instantiating module does not declare, although the port rst has a default value
:expected_stderr_regex: test_illegal_implicit_name_port_missing_with_default\.sv:28:
*/
// IEEE 1800-2023 §23.3.2.3: an implicit .name port connection needs a
// signal of that name in the instantiating module. It never declares an
// implicit net (as a named connection .rst(rst) to an undeclared rst would
// under the default net type wire), and the default value of an input port is
// not used in its place: the missing name is an error. A port with a default
// is left unconnected with an empty .name(), as the ports rst and mode of the
// instance ok are; only the .rst of u is wrong.

module nmd_child(input logic clk, input logic rst = 1'b0, input logic mode = 1'b1);
endmodule

module test_illegal_implicit_name_port_missing_with_default;
  logic clk = 1'b0;
  nmd_child ok (.clk, .rst(), .mode());
  nmd_child u (.clk, .rst, .mode());   // illegal: no rst is declared here
endmodule
