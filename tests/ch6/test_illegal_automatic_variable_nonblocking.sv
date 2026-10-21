/*
:name: test_illegal_automatic_variable_nonblocking
:description: An automatic variable cannot be written with a nonblocking assignment (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 10.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a nonblocking assignment writes a variable declared automatic
:expected_stderr_regex: test_illegal_automatic_variable_nonblocking\.sv:25:
*/
// IEEE 1800-2023 §6.21 and §10.4.2: automatic variables shall not be written
// with nonblocking assignments, whose update can come after the variable has
// gone with its block.
// Icarus Verilog 13.0 does not support automatic variables in a static block
// and stops on the declaration.

`timescale 1ns/1ns

module test_illegal_automatic_variable_nonblocking;
  initial begin
    automatic int count = 0;
    count <= 1;   // illegal: nonblocking assignment to an automatic variable
    #1 $display("count=%0d", count);
  end
endmodule
