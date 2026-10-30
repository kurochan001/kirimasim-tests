/*
:name: test_A_extra_tf_dims
:description: A tf port declaration takes a nonempty comma-separated list of tf variable identifiers, each with a port name and zero or more variable dimensions, so a packed port and an unpacked array port keep their declared shapes (IEEE 1800-2023 Sections 13.3 and A.2.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 A.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_tf_dims.expected
*/
// IEEE 1800-2023 A.2.3, list_of_tf_variable_identifiers: the list is one or
// more comma-separated entries, and each entry is a port_identifier, zero or
// more variable_dimension and an optional "= expression" initializer. The
// tf port declaration below lists the packed port a and the unpacked array
// port b of two elements.
// The ports have no initializer: §13.5.3 allows a default argument value
// only in an ANSI style declaration, and only for a singular argument, so an
// initializer in this list would make the design illegal.
//
// The task adds a, b[0] and b[1]: 4 + 1 + 2 = 7. Icarus Verilog 13.0 does
// not support unpacked dimensions on a subroutine port, so the expected
// output is recorded with the 5.052 release of Verilator.

module test_A_extra_tf_dims;
  int o;

  task old;
    input logic [3:0] a, b[2];
    output int c;
    c = a + b[0] + b[1];
  endtask

  initial begin
    old(4, '{1, 2}, o);
    $display("%0d", o);
  end
endmodule
