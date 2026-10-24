/*
:name: test_illegal_drive_strength_on_mos_switch
:description: Only the gate types of Table 28-2 can have a drive strength, so an nmos switch with one is illegal, while a bufif1 with the same strength is legal (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the nmos switch m1 has a drive strength specification
:expected_stderr_regex: test_illegal_drive_strength_on_mos_switch\.sv:24:
*/
// IEEE 1800-2023 §28.3.2: only instances of the gate primitives listed in
// Table 28-2 (the n-input and n-output gates, the three-state gates, pullup
// and pulldown) can have a drive strength specification. A MOS switch is not
// in the table. bufif1 b1, which is, has (weak0, weak1); the nmos m1 has the
// same strength.

module test_illegal_drive_strength_on_mos_switch;
  logic d = 1'b1, g = 1'b1;
  wire y_buf, y_mos;
  bufif1 (weak0, weak1) b1 (y_buf, d, g);
  nmos (weak0, weak1) m1 (y_mos, d, g);   // illegal: no drive strength on a MOS switch
  initial #1 $display("%v", y_buf);
endmodule
