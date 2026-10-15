/*
:name: test_edge_wor_wand
:description: wor and wand nets resolve two constant drivers
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.3 4.4.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_edge_wor_wand.expected
*/
module edge_wor_wand;
  wor  w;
  wand a;

  assign w = 1'b0;
  assign w = 1'b1;
  assign a = 1'b1;
  assign a = 1'b0;

  initial begin
    #0;
    if (w !== 1'b1) $fatal(1, "wor resolution should produce 1");
    if (a !== 1'b0) $fatal(1, "wand resolution should produce 0");
    $display("PASS: wor/wand resolution verified");
    $finish;
  end
endmodule
