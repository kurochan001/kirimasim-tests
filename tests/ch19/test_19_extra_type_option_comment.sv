/*
:name: test_19_extra_type_option_comment
:description: The type option comment starts as the empty string and holds a string assigned to it (IEEE 1800-2023 Section 19.7.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.7.1 19.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_19_extra_type_option_comment.expected
*/
// IEEE 1800-2023 §19.7.1: type_option.comment is a type option of a covergroup,
// coverpoint and cross whose default is the empty string, and the value is
// saved and reported with the type or type item. §19.10 makes type_option a
// structure member. The test reads the default through a new instance and
// then assigns a string and reads it back. Verilator 5.052 does not retain a
// type option set in the definition, and it writes no coverage database, so
// the saving clause is not tested.

module test_19_extra_type_option_comment;
  bit a;

  covergroup cg;
    cp: coverpoint a;
  endgroup

  cg g;

  initial begin
    g = new;
    $display("default comment: [%s]", g.type_option.comment);
    g.type_option.comment = "note";
    $display("assigned comment: [%s]", g.type_option.comment);
  end
endmodule
