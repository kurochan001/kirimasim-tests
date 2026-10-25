/*
:name: test_illegal_tagged_expression_value_of_wrong_type
:description: the member value of a tagged union expression has to have the type of that member (IEEE 1800-2023 Section 11.9)
:tags: ch11
:type: elaboration
:lrm: 1800-2023 11.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the member value of tagged Valid h is the class handle h, while the member Valid has the type int
:expected_stderr_regex: test_illegal_tagged_expression_value_of_wrong_type\.sv:37:
*/
// IEEE 1800-2023 §11.9: in a tagged union expression the member expression
// shall have the type of the member, which is checked statically. An int
// value for the int member Valid and a handle for the class member Obj are
// legal; the class handle h for the int member Valid is not.
// Icarus Verilog 13.0 does not parse tagged unions, and the 5.052 release
// of Verilator reports them as unsupported.

class obj_c;
endclass

module test_illegal_tagged_expression_value_of_wrong_type;
  typedef union tagged {
    void Invalid;
    int Valid;
    obj_c Obj;
  } ref_t;
  ref_t u;
  obj_c h = new;
  int k = 7;

  initial begin
    u = tagged Valid k;
    u = tagged Obj h;
    u = tagged Valid h;   // illegal: a class handle for the int member Valid
    $display("%0d", k);
  end
endmodule
