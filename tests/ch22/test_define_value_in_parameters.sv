/*
:name: test_define_value_in_parameters
:description: Macros defined by a tool option expand inside parameter values, widths and generate conditions (IEEE 1800-2023 Section 22.5.1)
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1 6.20.2 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:defines: DEPTH=4 WIDE
:expected_stdout: @test_define_value_in_parameters.expected
*/
// IEEE 1800-2023 §22.5.1: a macro use is replaced by the macro text before the
// code is parsed, so DEPTH, defined as 4 by the runner (:defines:), can be part
// of a parameter value (§6.20.2) and of a width, and the defined macro WIDE
// chooses a branch of a generate if (§27.5) through `ifdef.

module test_define_value_in_parameters;
  localparam int D = `DEPTH * 2;
  logic [`DEPTH * 4 - 1:0] bus;
`ifdef WIDE
  localparam int MODE = 1;
`else
  localparam int MODE = 0;
`endif
  if (MODE == 1) begin : g_wide
    initial $display("wide: D=%0d bits=%0d", D, $bits(bus));
  end else begin : g_narrow
    initial $display("narrow: D=%0d bits=%0d", D, $bits(bus));
  end
endmodule
