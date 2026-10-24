/*
:name: test_illegal_case_inside_two_default_items
:description: a case-inside statement cannot have two default items (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the case-inside statement has two default items
:expected_stderr_regex: test_illegal_case_inside_two_default_items\.sv:27:
*/
// IEEE 1800-2023 §12.5: more than one default item in one case statement is
// illegal; the rule covers the case_inside_item form of the default item used
// by a case-inside statement (12.5.4), which here has two.
// Icarus Verilog 13.0 does not support case inside and reports a syntax
// error on another line.

module test_illegal_case_inside_two_default_items;
  int v = 7;
  initial begin
    case (v) inside
      [0:3]: $display("low");
      default $display("first default");
      [4:5]: $display("middle");
      default $display("second default");   // illegal
    endcase
  end
endmodule
