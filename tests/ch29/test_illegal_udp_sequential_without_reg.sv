/*
:name: test_illegal_udp_sequential_without_reg
:description: The output of a sequential UDP must be declared reg (IEEE 1800-2023 Section 29.3.2)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.3.2 29.3.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the UDP has a sequential table but no reg declaration for its output
:expected_stderr_regex: test_illegal_udp_sequential_without_reg\.sv:(23|26|27|28):
*/
// IEEE 1800-2023 §29.3.2: a sequential UDP contains a reg declaration for
// its output, either as a declaration of its own or in the output
// declaration. The table of this UDP has a current state field in every
// entry, so the UDP is sequential (29.3.4), but its output is not
// declared reg. A tool can report the output declaration or the entries.
// Icarus Verilog 13.0 stops on an internal assertion instead of reporting
// the error.

primitive test_illegal_udp_sequential_without_reg_p(q, en, d);
  output q;   // illegal: no reg for the output of a sequential UDP
  input en, d;
  table
    1 0 : ? : 0;   // error here
    1 1 : ? : 1;   // error here
    0 ? : ? : -;   // error here
  endtable
endprimitive

module test_illegal_udp_sequential_without_reg;
  logic en = 0, d = 0;
  wire q;
  test_illegal_udp_sequential_without_reg_p u(q, en, d);
endmodule
