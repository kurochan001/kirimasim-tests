/*
:name: test_23_extra_port_coercion
:description: A port declared as input but driven inside the module may be coerced to inout, so the net outside either takes the value the module drives or stays undriven, and no other value is allowed (IEEE 1800-2023 Section 23.3.3.1)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_23_extra_port_coercion.expected
*/
// IEEE 1800-2023 §23.3.3.1: a port declared as input but used as an output
// or inout may be coerced to inout; if it is not coerced, a warning shall be
// issued. Coercion is therefore a permission, not a requirement. The module pc
// declares its port w as an input and drives it with a continuous assignment,
// which uses the port as an output. The connection at the instance is the net
// x, which has no other driver. If the port is coerced, x is the 1 that pc
// drives; if it is not, x stays z. The test accepts either value and rejects
// 0 and x, which neither reading gives.
// Icarus Verilog 13.0 coerces the port and also prints a warning. Verilator
// 5.052 rejects the assignment to the input, which a test cannot accept.

module pc(input wire w);
  assign w = 1'b1;
endmodule

module test_23_extra_port_coercion;
  wire x;
  pc u(.w(x));

  initial #1
    if (x === 1'b1 || x === 1'bz) $display("x is 1 or z");
    else $display("x=%b", x);
endmodule
