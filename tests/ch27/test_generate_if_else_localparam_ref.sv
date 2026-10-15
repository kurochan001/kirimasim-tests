/*
:name: test_generate_if_else_localparam_ref
:description: Hierarchical references to localparams in named if-else generate blocks
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5 23.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_if_else_localparam_ref.expected
*/
// Hierarchical references to localparams in named if-else generate blocks
module gen_ifelse #(parameter USE_ELSE=0) (output int Pval);
  generate
    if (USE_ELSE) begin : G1
      localparam int P = 7;
      assign Pval = P;
    end else begin : G0
      localparam int P = 5;
      assign Pval = P;
    end
  endgenerate
endmodule

module test_generate_if_else_localparam_ref;
  int p0, p1;
  gen_ifelse #(.USE_ELSE(0)) u0(.Pval(p0));
  gen_ifelse #(.USE_ELSE(1)) u1(.Pval(p1));
  initial begin
    #1;
    if (u0.G0.P !== 5) $fatal(1, "G0.P mismatch");
    if (u1.G1.P !== 7) $fatal(1, "G1.P mismatch");
    if (p0 != 5 || p1 != 7) $fatal(1, "Pval mismatch");
    $display("TEST PASSED: generate if/else localparam reference");
    $finish;
  end
endmodule
