/*
:name: test_signed_port_extension_uses_local_declaration
:description: A port value is extended according to its own declaration rather than its connected actual signedness (IEEE 1800-2023 Section 23.3.3.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_signed_port_extension_uses_local_declaration.expected
*/
// IEEE 1800-2023 23.3.3.8: The connected bits agree but signed and unsigned
// formals extend differently when read inside their respective modules.

module signed_port_leaf(input signed [3:0] data, output [7:0] result);
  assign result = data;
endmodule
module unsigned_port_leaf(input [3:0] data, output [7:0] result);
  assign result = data;
endmodule
module test_signed_port_extension_uses_local_declaration;
  bit signed [3:0] actual = -2;
  wire [7:0] signed_result, unsigned_result;
  signed_port_leaf s(actual, signed_result);
  unsigned_port_leaf u(actual, unsigned_result);
  initial #1 $display("signed=%h unsigned=%h", signed_result, unsigned_result);
endmodule
