/*
:name: test_19_extra_option_cross_num_print_missing
:description: The instance option cross_num_print_missing starts at zero and holds an assigned count (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_19_extra_option_cross_num_print_missing.expected
*/
// IEEE 1800-2023 §19.7: option.cross_num_print_missing is an instance option
// of a covergroup and a cross whose default is 0. It gives the number of
// missing cross bins to save and print. The test reads the default of a new
// covergroup and then assigns 5 and reads it back. The effect on a report is
// not tested: Verilator 5.052 writes no coverage database or report.

module test_19_extra_option_cross_num_print_missing;
  bit a;

  covergroup cg;
    cp: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    $display("default cross_num_print_missing: %0d",
             g.option.cross_num_print_missing);
    g.option.cross_num_print_missing = 5;
    $display("assigned cross_num_print_missing: %0d",
             g.option.cross_num_print_missing);
  end
endmodule
