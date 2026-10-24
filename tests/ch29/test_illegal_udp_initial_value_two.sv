/*
:name: test_illegal_udp_initial_value_two
:description: The initial value of a UDP output must be one of 1'b0, 1'b1, 1'bx, 1 and 0 (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: elaboration
:lrm: 1800-2023 29.7 29.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial statement of the UDP assigns the value 2
:expected_stderr_regex: test_illegal_udp_initial_value_two\.sv:24:
*/
// IEEE 1800-2023 §29.7, Table 29-2: the initial statement of a UDP assigns
// one of the values 1'b1, 1'b0, 1'bx, 1 and 0 (with the spellings of
// init_val in 29.3), while a module can assign values of any size, radix
// and value. This UDP assigns the decimal value 2.
// Icarus Verilog 13.0 and Verilator 5.052 accept the design.

primitive test_illegal_udp_initial_value_two_p(q, en, d);
  output q;
  reg q;
  input en, d;
  initial q = 2;   // illegal: not a single-bit value
  table
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module test_illegal_udp_initial_value_two;
  logic en = 0, d = 0;
  wire q;
  test_illegal_udp_initial_value_two_p u(q, en, d);
endmodule
