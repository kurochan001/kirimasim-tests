/*
:name: test_combined_compile_elaboration_results
:description: A combined invocation resolves a parameterized binding and detects a missing module
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_combined_compile_elaboration_results.expected
*/
`timescale 1ns/1ns
package phase_math;
  function automatic int adjusted(input int code);
    return code * 2 + 1;
  endfunction
endpackage

module phase_leaf #(parameter int CODE=3) (output wire [7:0] driven);
  import phase_math::*;
  localparam int RESOLVED = adjusted(CODE);
  assign driven = 8'(RESOLVED);
endmodule

module test_combined_compile_elaboration_results;
  wire [7:0] settled;
  generate
    if (1) begin : selected
`ifdef OBSERVE_UNBOUND_COMPONENT
      phase_missing u(settled);
`else
      phase_leaf #(.CODE(9)) u(settled);
`endif
    end
  endgenerate

  initial begin
    #1 $display("resolved port=%0d width=%0d", settled, $bits(settled));
    $finish(0);
  end
endmodule
