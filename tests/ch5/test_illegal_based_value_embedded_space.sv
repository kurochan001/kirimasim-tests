/*
:name: test_illegal_based_value_embedded_space
:description: A space inside the value digits of a based literal is rejected (IEEE 1800-2023 Section 5.7)
:tags: ch5
:type: elaboration
:lrm: 1800-2023 5.7 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the hexadecimal value A5 of the based literal is written with a space between its digits
:expected_stderr_regex: test_illegal_based_value_embedded_space\.sv:26:
*/
// IEEE 1800-2023 §5.7 (Syntax 5-2, footnote 38): embedded spaces are
// illegal in an unsigned number, a real number, the value digits of a
// based literal and its base designator.
// White space may separate the base
// designator from the value (§5.7.1), as in 8'h A5, which is legal; on the
// marked line the value itself is split as A 5, an error.

module test_illegal_based_value_embedded_space;
  logic [7:0] a, b;

  initial begin
    a = 8'h A5;
    b = 8'hA 5;   // illegal: a space inside the value digits
    $display("%h %h", a, b);
  end
endmodule
