/*
:name: test_pla_sync_snapshot_versus_async_update
:description: Synchronous logic arrays keep a snapshot until called again while an asynchronous array follows changed inputs (IEEE 1800-2023 Section 20.16.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16.1 20.16.2 20.16.3 20.16.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pla_sync_snapshot_versus_async_update.expected
*/
// IEEE 1800-2023 20.16.1 20.16.2 20.16.3 20.16.4: The same two-bit AND
// personality drives synchronous and asynchronous outputs; an OR plane
// separately verifies complemented and omitted inputs.
// Oracle checks: Icarus Verilog 13.0 does not reproduce the clause-derived
// output. The 5.052 release is a two-state engine and is not used as the oracle
// here.

module test_pla_sync_snapshot_versus_async_update;
  logic [0:1] personality[0:1], plane[0:1];
  logic [0:1] inputs = 2'b10;
  wire [0:1] asynchronous;
  logic [0:1] synchronous, plane_result;
  initial begin
    personality[0] = 2'b10; personality[1] = 2'b11;
    plane[0] = 2'b0z; plane[1] = 2'bz1;
    $async$and$array(personality, inputs, asynchronous);
    $sync$and$array(personality, inputs, synchronous);
    $sync$or$plane(plane, inputs, plane_result);
    #1 $display("initial=%b,%b plane=%b", asynchronous, synchronous, plane_result);
    inputs = 2'b01;
    #1 $display("changed=%b,%b plane=%b", asynchronous, synchronous, plane_result);
    $sync$and$array(personality, inputs, synchronous);
    $sync$or$plane(plane, inputs, plane_result);
    #1 $display("called_again=%b,%b plane=%b", asynchronous, synchronous, plane_result);
  end
endmodule
