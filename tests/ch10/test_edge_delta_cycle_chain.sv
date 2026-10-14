/*
:name: test_edge_delta_cycle_chain
:description: A chain of continuous assignments, one with #0 delay, follows its source
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3 4.4.2.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_delta_cycle_chain.expected
*/
module edge_delta_cycle_chain;
  logic source = 0;
  logic mid;
  logic dest;

  assign mid = source;
  assign #0 dest = mid;

  // The checks wait #1: after #0, the resumed process and the update of the
  // #0 continuous assignment are both Inactive events in no defined order
  // (4.4.2.3, 4.7).

  initial begin
    #1;
    if (dest !== 0) begin
      $fatal(1, "Expected dest to follow source with zero delay (stage 1)");
    end

    source = 1;
    #1;
    if (dest !== 1) begin
      $fatal(1, "Expected dest to follow source with zero delay (stage 2)");
    end

    source = 0;
    #1;
    if (dest !== 0) begin
      $fatal(1, "Expected dest to follow source with zero delay (stage 3)");
    end

    $display("PASS: delta-cycle chain propagated updates immediately");
    $finish;
  end
endmodule
