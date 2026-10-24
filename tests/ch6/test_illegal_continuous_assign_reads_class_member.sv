/*
:name: test_illegal_continuous_assign_reads_class_member
:description: A continuous assignment cannot reference a member of a class object, a dynamic variable (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21 8.4 10.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w reads h.value, a member of the object of the class handle h, outside a procedural block
:expected_stderr_regex: test_illegal_continuous_assign_reads_class_member\.sv:28:
*/
// IEEE 1800-2023 §6.21: references to members of dynamic variables shall
// be limited to procedural blocks. A class object is created at run time
// (§8.4), and the continuous assignment (§10.3) reads its property value
// through the handle h.
// Icarus Verilog 13.0 stops on this line with an internal error (it cannot
// synthesize the expression), which is not a diagnosis of the rule; the
// design is accepted by Verilator 5.052.

module test_illegal_continuous_assign_reads_class_member;
  class box_c;
    int value = 3;
  endclass
  box_c h = new;
  wire [31:0] w;
  assign w = h.value;    // illegal: member of a dynamic variable outside a procedure
endmodule
