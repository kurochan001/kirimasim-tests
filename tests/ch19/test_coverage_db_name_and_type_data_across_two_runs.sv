/*
:name: test_coverage_db_name_and_type_data_across_two_runs
:description: A selected coverage database can carry the cumulative values of two covergroup types into another run
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.9 19.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_db_name_and_type_data_across_two_runs.expected
*/
module test_coverage_db_name_and_type_data_across_two_runs;
  bit [1:0] four_value;
  bit two_value;
  covergroup four_values;
    point: coverpoint four_value { bins values[] = {0, 1, 2, 3}; }
  endgroup
  covergroup two_values;
    point: coverpoint two_value { bins values[] = {0, 1}; }
  endgroup

  four_values first;
  two_values second;
  initial begin
    first = new;
    second = new;
    if ($test$plusargs("load_named_database")) begin
      $load_coverage_db("chosen_coverage.json");
    end else begin
      if ($test$plusargs("save_named_database")) begin
        $set_coverage_db_name("unused_coverage.json");
        $set_coverage_db_name("chosen_coverage.json");
      end
      four_value = 2;
      two_value = 1;
      first.sample();
      second.sample();
    end
    $display("four=%.2f two=%.2f", four_values::get_coverage(), two_values::get_coverage());
  end
endmodule
