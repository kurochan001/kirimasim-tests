/*
:name: test_blocking_delayed_target_after_index_change
:description: An intra assignment blocking delay saves the RHS but chooses the indexed destination on resumption (IEEE 1800-2023 Section 4.9.3)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.9.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_blocking_delayed_target_after_index_change.expected
*/
// IEEE 1800-2023 4.9.3: The data is sampled at entry; changing both the index
// and data during suspension distinguishes destination selection from RHS
// sampling.

module test_blocking_delayed_target_after_index_change;
  int a[2] = '{10, 20};
  int index = 0, source = 7;
  initial begin
    a[index] = #4 source;
    $display("array=%0d,%0d", a[0], a[1]);
  end
  initial begin #1 index = 1; source = 99; end
endmodule
