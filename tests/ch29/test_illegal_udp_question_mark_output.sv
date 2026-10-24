/*
:name: test_illegal_udp_question_mark_output
:description: The UDP symbol ? cannot be used in an output field (IEEE 1800-2023 Section 29.3.6)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the output field of a table entry is ?
:expected_stderr_regex: test_illegal_udp_question_mark_output\.sv:23:
*/
// IEEE 1800-2023 §29.3.6, Table 29-1: ? stands for 0, 1 and x and is not
// permitted in the output field. The second entry of this combinational
// UDP has ? as its output.

primitive test_illegal_udp_question_mark_output_p(y, a);
  output y;
  input a;
  table
    0 : 1;
    1 : ?;   // illegal: ? in the output field
  endtable
endprimitive

module test_illegal_udp_question_mark_output;
  logic a = 0;
  wire y;
  test_illegal_udp_question_mark_output_p u(y, a);
endmodule
