/*
:name: test_vpi_per_file_units_iterate_same_named_locals_separately
:description: VPI traverses two compilation-unit scopes and reads the local values independently
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 37.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_per_file_units_iterate_same_named_locals_separately.expected
:files: vpi_per_file_unit_anchor.sv
:args: --compilation-unit=per-file
:vpi_c: @test_vpi_per_file_units_iterate_same_named_locals_separately.c
*/
int unit_marker = 57;

module test_vpi_per_file_units_iterate_same_named_locals_separately;
  vpi_per_file_unit_peer peer();

  initial begin
    #1;
    $display("peer=%0d local=%0d", peer.observed, $unit::unit_marker);
    $vt_check_units;
  end
endmodule
