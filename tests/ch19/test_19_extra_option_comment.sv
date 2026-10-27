/*
:name: test_19_extra_option_comment
:description: The instance option comment starts as the empty string and holds a string assigned to it (IEEE 1800-2023 Section 19.7)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7 19.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_extra_option_comment.expected
*/
// IEEE 1800-2023 §19.7: option.comment is an instance option of a covergroup,
// coverpoint and cross whose default is the empty string. §19.10 makes option
// a structure member, so the value can be read after construction. The test
// reads the default of a new covergroup and then assigns a string and reads
// it back. The clause also says the comment is saved with its group, point or
// cross in the database and report (19.9); Verilator 5.052 writes no coverage
// database, so that part is not tested here.

module test_19_extra_option_comment;
  bit a;

  covergroup cg;
    cp: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    $display("default comment: [%s]", g.option.comment);
    g.option.comment = "note";
    $display("assigned comment: [%s]", g.option.comment);
  end
endmodule
