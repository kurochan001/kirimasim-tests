/*
:name: test_extern_module_named_parameter_binding
:description: An extern module prototype permits an instance before the matching implementation with a parameter override (IEEE 1800-2023 Section 23.5)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_module_named_parameter_binding.expected
*/
// IEEE 1800-2023 23.5: The implementation must match the external declaration
// and apply the instance parameter when computing its port expression.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

extern module external_leaf #(parameter int W = 3) (input bit [W-1:0] a,
                                                   output bit [W-1:0] y);
module test_extern_module_named_parameter_binding;
  wire [4:0] y;
  external_leaf #(.W(5)) u(5'b10101, y);
  initial #1 $display("value=%b width=%0d", y, $bits(y));
endmodule
module external_leaf #(parameter int W = 3) (input bit [W-1:0] a,
                                            output bit [W-1:0] y);
  assign y = ~a;
endmodule
