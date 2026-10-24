/*
:name: test_illegal_case_two_default_items
:description: a case statement cannot have two default items (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: elaboration
:lrm: 1800-2023 12.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the case statement has two default items
:expected_stderr_regex: test_illegal_case_two_default_items\.sv:29:
*/
// IEEE 1800-2023 §12.5: the default item of a case statement is optional, and
// more than one default item in one case statement is illegal. The first case
// statement has no default item, which is legal; the second has two.
// Icarus Verilog 13.0 accepts the design.

module test_illegal_case_two_default_items;
  logic [1:0] s = 2'd1;
  initial begin
    case (s)
      2'd0: $display("zero");
    endcase
    case (s)
      2'd0: $display("zero");
      default: $display("first default");
      2'd1: $display("one");
      default: $display("second default");   // illegal
    endcase
  end
endmodule
