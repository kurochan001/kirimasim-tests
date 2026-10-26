/*
:name: test_expr_tagged_union_access
:description: a tagged union value is built with tagged and its member passes through, and dot access that matches the current tag reads and writes that member (IEEE 1800-2023 11.9)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_tagged_union_access.expected
*/
// IEEE 1800-2023 §11.9: tagged member value builds a tagged union expression,
// whose type comes from its context; the member name has to belong to that
// type and the value has to have the member type. A member can be read and
// assigned with dot notation when the current tag matches. The test builds
// tagged Int 5 and tagged Byte 8'hA5, reads each active member, writes Byte
// again while its tag is current, and builds another Int through a cast that
// supplies the context type. A different tag encoding or a member value that
// does not survive the round trip prints a different line. The undefined
// value of an uninitialized tagged union and the run-time error of a
// mismatching access are not observed here. Neither release simulated here
// supports tagged unions, so the expected output follows the clause.

module test_expr_tagged_union_access;
  typedef union tagged {
    int Int;
    logic [7:0] Byte;
  } tu_t;

  tu_t t;

  initial begin
    t = tagged Int 5;
    $display("int=%0d", t.Int);
    t = tagged Byte 8'hA5;
    $display("byte=%h", t.Byte);
    t.Byte = 8'h3C;
    $display("byte2=%h", t.Byte);
    t = tu_t'(tagged Int 7);
    $display("cast=%0d", t.Int);
    $finish;
  end
endmodule
