/*
:name: test_setuphold_and_recrem_shift_the_same_violation_window
:description: Positive and mixed-sign limits give setuphold and recrem the same centered or shifted violation windows
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9 31.9.1 31.3.3 31.3.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_setuphold_and_recrem_shift_the_same_violation_window.expected
*/
// Run with negative timing checks enabled (31.9.4).
`timescale 1ns/1ns
module shift_check #(parameter int LEFT = 6, RIGHT = 6)
                    (input wire reference, probe, output reg sh = 0, rr = 0);
  specify
    $setuphold(posedge reference, posedge probe, LEFT, RIGHT, sh);
    $recrem(posedge reference, posedge probe, LEFT, RIGHT, rr);
  endspecify
endmodule

module test_setuphold_and_recrem_shift_the_same_violation_window;
  bit reference;
  bit [0:9] data_edges;
  wire [0:9] central_sh, central_rr, before_sh, before_rr, after_sh, after_rr;

  for (genvar idx = 0; idx < 10; idx++) begin : checks
    shift_check #(6, 6) centered(reference, data_edges[idx], central_sh[idx], central_rr[idx]);
    shift_check #(12, -5) before_ref(reference, data_edges[idx], before_sh[idx], before_rr[idx]);
    shift_check #(-5, 12) after_ref(reference, data_edges[idx], after_sh[idx], after_rr[idx]);
  end

  initial begin
    #28 data_edges[0] = 1;  // The three limits are measured from reference time 40.
    #2 data_edges[1] = 1;
    #3 data_edges[2] = 1;
    #2 data_edges[3] = 1;
    #2 data_edges[4] = 1;
    #5 data_edges[5] = 1;
    #3 data_edges[6] = 1;
    #3 data_edges[7] = 1;
    #2 data_edges[8] = 1;
    #2 data_edges[9] = 1;
  end

  initial begin
    #40 reference = 1;
    #30;
    $display("centered: setuphold=%b recrem=%b", central_sh, central_rr);
    $display("before: setuphold=%b recrem=%b", before_sh, before_rr);
    $display("after: setuphold=%b recrem=%b", after_sh, after_rr);
    $finish(0);
  end
endmodule
