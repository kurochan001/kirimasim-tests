/*
:name: test_19_extra_option_per_instance
:description: The instance option per_instance starts as false (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_19_extra_option_per_instance.expected
*/
// IEEE 1800-2023 §19.7: option.per_instance is a definition-only covergroup
// option whose default is false. With true, the tool saves and reports the
// data of the instance; with false, it need not retain that data while the
// instance still contributes to the type coverage. The test reads the default
// of a new covergroup. The saving and reporting that true requires is not
// tested: Verilator 5.052 writes no coverage database, and its type coverage
// reads 0 for every group.

module test_19_extra_option_per_instance;
  bit a;

  covergroup cg;
    cp: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    $display("default per_instance: %0d", g.option.per_instance);
  end
endmodule
