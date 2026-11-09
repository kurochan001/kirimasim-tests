/*
:name: test_illegal_unique_real_and_int
:description: The members of a unique group shall have equivalent types, so a group with a rand real and a rand int is an error, while a group of real variables and a real array is legal (IEEE 1800-2023 Section 18.5.4)
:tags: ch18
:type: elaboration
:lrm: 1800-2023 18.5.4 6.22.2 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the unique group of u_bad holds the real r1 and the int n, whose types are not equivalent
:expected_stderr_regex: test_illegal_unique_real_and_int\.sv:32:
*/
// IEEE 1800-2023 §18.5.4: a unique group may hold singular variables of
// integral or real type and unpacked arrays with integral or real leaf
// elements, but all its members (the singular variables and the leaf
// elements) shall be of equivalent type. §6.22.2: the built-in types real and
// int do not match and are not packed or integral types of the same size, so
// they are not equivalent. u_ok groups the reals r1 and r2 with the elements of
// the real array ra and is legal; u_bad groups the real r1 with the int n and
// is an error.
// Icarus Verilog 13.0 does not support constraints, so the syntax error it
// reports on line 32 does not count. The 5.052 release of Verilator does not
// support real values in these constraints and reports no error on line 32.

class urn_obj;
  rand real r1, r2;
  rand real ra[2];
  rand int n;
  constraint c { r1 > 0.0; r1 < 4.0; r2 > 0.0; r2 < 4.0; n inside {[0:3]}; }
  constraint u_ok { unique {r1, r2, ra}; }
  constraint u_bad { unique {r1, n}; }   // illegal: real and int are not equivalent
endclass

module test_illegal_unique_real_and_int;
  urn_obj o = new;
  initial $display("ok=%0d", o.randomize());
endmodule
