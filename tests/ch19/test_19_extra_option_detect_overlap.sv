/*
:name: test_19_extra_option_detect_overlap
:description: The definition-only instance option detect_overlap starts as false (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_extra_option_detect_overlap.expected
*/
// IEEE 1800-2023 §19.7: option.detect_overlap is a definition-only group and
// point option whose default is false. When true, the tool warns about
// overlapping state ranges or transition lists between the bins of a point.
// The test reads the default of a new covergroup. The warning that true
// requires is not tested, because the form of a tool warning is not fixed by
// the standard, and Verilator 5.052 ignores the option and prints no overlap
// warning. The option is definition-only, so a procedural assignment would
// itself be illegal and is not attempted.

module test_19_extra_option_detect_overlap;
  bit a;

  covergroup cg;
    cp: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    $display("default detect_overlap: %0d", g.option.detect_overlap);
  end
endmodule
