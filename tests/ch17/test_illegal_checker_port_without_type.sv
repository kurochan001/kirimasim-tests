/*
:name: test_illegal_checker_port_without_type
:description: A checker port with an explicit direction cannot omit its type (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the first checker port names the direction input but no type
:expected_stderr_regex: test_illegal_checker_port_without_type\.sv:26:
*/
// IEEE 1800-2023 17.2: a checker port that has an explicit direction qualifier
// shall also have a type; it is an error to omit the type of such a port. The
// port a below names input and no type, so the declaration is not legal. A port
// without a type is allowed only when it also omits the direction, so that the
// type of the previous port can be inferred. The rest of the design is legal.
// The 5.052 release supports the unit-level checker but accepts the port
// without a type, and Icarus Verilog 13.0 does not support checkers at all, so
// neither release produces the expected result.

`timescale 1ns/1ns

checker no_type_port(
    input a,
    output logic y);
  assign y = a;
endchecker : no_type_port

module test_illegal_checker_port_without_type;
  logic v = 1'b1;
  logic y;

  no_type_port u(.a(v), .y(y));

  initial #1 $display("y=%b", y);
endmodule
