/*
:name: test_illegal_constraint_final_replacement_replaced
:description: A constraint that a subclass replaces with :extends :final cannot be replaced again by a class derived from that subclass (IEEE 1800-2023 Section 18.5.2)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: cg_leaf_c replaces c, which cg_mid_c declared :extends :final
:expected_stderr_regex: test_illegal_constraint_final_replacement_replaced\.sv:(38|32):
*/
// IEEE 1800-2023 §18.5.2: final may be combined with extends, and a final
// constraint shall not be replaced by any further subclass; an attempt is an
// error. cg_mid_c replaces c of cg_base_c with :extends :final, which is
// legal, and also replaces d without a specifier. cg_leaf_c may replace d
// again, but not c. A tool can report the replacing constraint or the final
// one. With another name for the constraint in the marked line the design is
// legal and prints ok=1.
// The 5.054 release of Verilator accepts the design. Icarus Verilog 13.0 does
// not support override specifiers, so the syntax error it reports does not
// count.

class cg_base_c;
  rand int v;
  constraint c { v > 0; }
  constraint d { v < 100; }
endclass

class cg_mid_c extends cg_base_c;
  constraint :extends :final c { v > 5; }   // (or reported here)
  constraint d { v < 50; }
endclass

class cg_leaf_c extends cg_mid_c;
  constraint d { v < 20; }
  constraint c { v > 10; }   // illegal: c is final in cg_mid_c
endclass

module test_illegal_constraint_final_replacement_replaced;
  cg_leaf_c o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
