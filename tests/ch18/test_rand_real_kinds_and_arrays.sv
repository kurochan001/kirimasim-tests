/*
:name: test_rand_real_kinds_and_arrays
:description: rand shortreal and rand realtime variables, fixed-size and dynamic arrays of rand real, and constraints that mix integral and real operands are solved like integral ones, and a soft constraint on a real is dropped when a hard one contradicts it (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4 18.5 18.5.7.1 18.5.13 6.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_real_kinds_and_arrays.expected
*/
// IEEE 1800-2023 §18.4: the solver randomizes singular variables of any real
// type; §6.12 calls variables of type real, shortreal and realtime real
// variables. A rand array of reals has rand elements, and the size of a rand
// dynamic array of reals can be constrained. §18.5: a constraint may have
// operands of integral and real types; the usual rules of the operators apply,
// so n / 2.0 is a real division and m == h * 4.0 compares m converted to real.
// §18.5.13: a soft constraint that contradicts a hard one is discarded.
// - s is a shortreal fixed to 0.25 and t a realtime between 1.0 and 1.5;
// - fa[i] == i * 0.5 makes fa 0.0 0.5 1.0; da gets 2 elements 2.0 - i, that
//   is 2.0 and 1.0 (§18.5.7.1: the size is solved before the foreach);
// - n == 3, h == n / 2.0 is 1.5, and m == h * 4.0 makes m 6;
// - soft p == 2.5 is kept by the first call (p is 2.5) and discarded when the
//   inline constraint p > 3.0 contradicts it.
// Only fixed values and relations that hold for every solution are printed:
// t is checked against its range, not printed, and so is p in the second call.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports rand real variables
// in constraints.

class rrk_obj;
  rand shortreal s;
  rand realtime t;
  rand real fa[3];
  rand real da[];
  rand int n, m;
  rand real h, p;
  constraint c_s { s == 0.25; t > 1.0; t < 1.5; }
  constraint c_a { foreach (fa[i]) fa[i] == i * 0.5;
                   da.size() == 2; foreach (da[i]) da[i] == 2.0 - i; }
  constraint c_mix { n == 3; h == n / 2.0; m == h * 4.0; }
  constraint c_p { soft p == 2.5; }
endclass

module test_rand_real_kinds_and_arrays;
  rrk_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize();
    $display("ok=%0d s=%0.2f t in (1.0,1.5) %0d", ok, o.s, o.t > 1.0 && o.t < 1.5);
    $display("fa=%0.1f %0.1f %0.1f da size %0d: %0.1f %0.1f", o.fa[0], o.fa[1], o.fa[2],
             o.da.size(), o.da[0], o.da[1]);
    $display("n=%0d h=%0.2f m=%0d p=%0.2f", o.n, o.h, o.m, o.p);
    ok = o.randomize() with { p > 3.0; };
    $display("ok=%0d p > 3.0 %0d, s=%0.2f h=%0.2f", ok, o.p > 3.0, o.s, o.h);
  end
endmodule
