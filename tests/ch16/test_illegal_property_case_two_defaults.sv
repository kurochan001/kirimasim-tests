/*
:name: test_illegal_property_case_two_defaults
:description: a property case statement with two default items is illegal (IEEE 1800-2023 Section 16.12.16)
:tags: ch16
:type: elaboration
:lrm: 1800-2023 16.12.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the case property statement of p_two has a second default item
:expected_stderr_regex: test_illegal_property_case_two_defaults\.sv:38:
*/
// IEEE 1800-2023 §16.12.16: in a case property statement the default item is
// optional, but one case statement shall not have more than one default
// item. p_none has no default item, which is legal: when no item matches,
// the evaluation succeeds. p_two has a first default item and then a second
// one, which is the error.
// Icarus Verilog 13.0 does not support property declarations, so its syntax
// errors do not count.

module test_illegal_property_case_two_defaults;
  logic clk = 0;
  logic [1:0] sel = 0;
  logic a = 0, b = 0, c = 0;

  property p_none;
    @(posedge clk) case (sel)
      2'd0: a;
      2'd1, 2'd2: b;
    endcase
  endproperty

  property p_two;
    @(posedge clk) case (sel)
      2'd0: a;
      default: b;
      default: c;   // illegal: a second default item
    endcase
  endproperty

  a_none: assert property (p_none);
  a_two: assert property (p_two);
endmodule
