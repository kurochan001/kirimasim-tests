/*
:name: test_coverage_database_storage_profiles
:description: Complementary cover property hits can be retrieved from separate database entries
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.5 40.3.2.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_database_storage_profiles.expected
*/
module test_coverage_database_storage_profiles;
  timeunit 1ns;
  timeprecision 1ns;

  bit clock, selected;
  low_path: cover property (@(posedge clock) !selected);
  high_path: cover property (@(posedge clock) selected);

  initial begin
    selected = $test$plusargs("high");
    repeat (3) begin
      #1 clock = 1;
      #1 clock = 0;
    end
`ifdef CHECK_NATIVE_COVERAGE_STORAGE
    begin
      string entry;
      int saved, merged;
      entry = selected ? "db/south" : "db/north";
      saved = $coverage_save(`SV_COV_ASSERTION, entry);
      merged = $coverage_merge(`SV_COV_ASSERTION, entry);
      $display("standard save=%0d merge=%0d", saved, merged);
    end
`endif
    $display("selected=%0d", selected);
    $finish(0);
  end
endmodule
