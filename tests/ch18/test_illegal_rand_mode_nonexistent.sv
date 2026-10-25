/*
:name: test_illegal_rand_mode_nonexistent
:description: Calling rand_mode() on a variable that does not exist in the class hierarchy is a compile error (IEEE 1800-2023 Section 18.8)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: rand_mode() is called on w, which is not a property of rmn_derived or of its base class
:expected_stderr_regex: test_illegal_rand_mode_nonexistent\.sv:33:
*/
// IEEE 1800-2023 §18.8: a compiler error shall be issued if the variable that
// rand_mode() names does not exist within the class hierarchy. v, declared
// rand in the base class, and u, declared rand in the derived class, exist;
// w does not exist in either.
// Icarus Verilog 13.0 does not support rand_mode(), so its errors do not count.

class rmn_base;
  rand int v;
endclass

class rmn_derived extends rmn_base;
  rand int u;
endclass

module test_illegal_rand_mode_nonexistent;
  rmn_derived o = new;
  initial begin
    o.v.rand_mode(0);
    o.u.rand_mode(0);
    o.w.rand_mode(0);   // illegal: no variable w in the class hierarchy
    $display("ok=%0d", o.randomize());
  end
endmodule
