/*
:name: test_illegal_drive_strength_on_pass_switch
:description: Only the gate types of Table 28-2 can have a drive strength, so a tranif1 pass switch with one is illegal, while a not gate with the same strength is legal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the tranif1 switch t1 has a drive strength specification
:expected_stderr_regex: test_illegal_drive_strength_on_pass_switch\.sv:25:
*/
// IEEE 1800-2023 §28.3.2: the drive strength specification is allowed only on
// instances of the gate primitives in Table 28-2; bidirectional pass switches
// are not among them. The not gate n1 has (pull0, pull1), which is legal; the
// tranif1 t1 has the same strength.
// The 5.052 release of Verilator does not support tranif1 at all, so its
// syntax error on the illegal line does not count.

module test_illegal_drive_strength_on_pass_switch;
  logic a = 1'b0, en = 1'b1;
  wire y_not, p, q;
  not (pull0, pull1) n1 (y_not, a);
  tranif1 (pull0, pull1) t1 (p, q, en);   // illegal: no drive strength on a pass switch
  initial #1 $display("%v", y_not);
endmodule
