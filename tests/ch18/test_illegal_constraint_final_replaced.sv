/*
:name: test_illegal_constraint_final_replaced
:description: A derived class that replaces a constraint declared final in its base class is an error (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: cfr_derived declares a constraint c_lock, which replaces the final constraint c_lock of cfr_base
:expected_stderr_regex: test_illegal_constraint_final_replaced\.sv:(25|30):
*/
// IEEE 1800-2023 §18.5.2: the final specifier forbids any later replacement
// of a constraint, and a subclass that tries to replace it is in error; final
// may be combined with initial or extends. c_lock of cfr_base is declared
// :initial :final (legal: it replaces nothing), and c_open is not final, so
// cfr_derived may replace c_open but not c_lock. A tool can report the error
// at the replacing constraint or at the final one.
// Icarus Verilog 13.0 does not support override specifiers, so the syntax error
// it reports does not count; Verilator 5.052 accepts the design.

class cfr_base;
  rand int v;
  constraint :initial :final c_lock { v > 0; }
  constraint c_open { v < 100; }
endclass

class cfr_derived extends cfr_base;
  constraint c_lock { v > 5; }   // illegal: c_lock is final in cfr_base
  constraint c_open { v < 50; }
endclass

module test_illegal_constraint_final_replaced;
  cfr_derived o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
