/*
:name: test_illegal_unbased_unsized_literal_space
:description: White space between the apostrophe and the value of an unbased unsized literal is rejected (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the apostrophe of the unbased unsized literal is followed by white space
:expected_stderr_regex: test_illegal_unbased_unsized_literal_space\.sv:24:
*/
// IEEE 1800-2023 §5.7 (Syntax 5-2, footnote 53): the apostrophe of an
// unbased unsized literal ('0, '1, 'x, 'z) shall not be followed by white
// space. The assignment of '0 is legal; the one on the marked line puts a
// space between ' and 1 and is an error.

module test_illegal_unbased_unsized_literal_space;
  logic [3:0] a, b;

  initial begin
    a = '0;
    b = ' 1;   // illegal: white space after the apostrophe
    $display("%b %b", a, b);
  end
endmodule
