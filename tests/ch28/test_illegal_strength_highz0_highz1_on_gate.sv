/*
:name: test_illegal_strength_highz0_highz1_on_gate
:description: A gate drive strength cannot be highz for both values, here (highz0, highz1) on a nor gate, while one highz strength with a driving strength for the other value is legal (IEEE 1800-2023 Section 28.11)
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.11 28.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:should_fail_because: the nor gate n_bad has the drive strength (highz0, highz1)
:expected_stderr_regex: test_illegal_strength_highz0_highz1_on_gate\.sv:27:
*/
// IEEE 1800-2023 §28.11: a strength specification has a strength0 and a
// strength1 component, and the combinations (highz0, highz1) and
// (highz1, highz0) are illegal. §28.3.2 says the same of the drive strength
// of a gate instance. n_oc has (highz1, strong0), an open-collector gate,
// which is legal; n_bad has highz for both values.
// The 5.052 release of Verilator does not support highz strengths and stops
// with "Unsupported: highz strength" on the legal gate as well, so its
// error on the illegal line does not count.

module test_illegal_strength_highz0_highz1_on_gate;
  logic a = 1'b0, b = 1'b0;
  wire y_oc, y_bad;
  nor (highz1, strong0) n_oc (y_oc, a, b);
  nor (highz0, highz1) n_bad (y_bad, a, b);   // illegal: both strengths are highz
  initial #1 $display("%v", y_oc);
endmodule
