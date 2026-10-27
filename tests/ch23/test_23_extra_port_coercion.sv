/*
:name: test_23_extra_port_coercion
:description: A port declared as input but driven inside the module may be coerced to inout, so the value the module drives reaches the connected net outside (IEEE 1800-2023 Section 23.3.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_port_coercion.expected
*/
// IEEE 1800-2023 §23.3.3.1: a port declared as input but used as an output
// or inout may be coerced to inout. The module pc declares its port w as an
// input and drives it with a continuous assignment, which uses the port as
// an output. The connection at the instance is the net x, so after coercion
// the value 1 that pc drives is the value of x.
// The expected output follows the standard. Icarus Verilog 13.0 coerces the
// port and also prints a warning; Verilator 5.052 rejects the assignment to
// the input instead.

module pc(input wire w);
  assign w = 1'b1;
endmodule

module test_23_extra_port_coercion;
  wire x;
  pc u(.w(x));

  initial #1 $display("x=%b", x);
endmodule
