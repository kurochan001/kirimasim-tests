/*
:name: test_rand_real_unique_and_conditions
:description: rand real variables and a rand real array can form a unique group, a real expression can be the condition of if-else and of an implication, and real variables can be ordered with solve...before; the values follow from the constraints (IEEE 1800-2023 Sections 18.5.4, 18.5.5, 18.5.6 and 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.4 18.5.5 18.5.6 18.5.9 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_real_unique_and_conditions.expected
*/
// IEEE 1800-2023 §18.4: the solver randomizes singular variables of real
// type, and the elements of a rand array of reals. §18.5.4: a unique group
// may hold singular real variables and unpacked arrays whose elements are
// real, all of an equivalent type, and no two of its members get the same
// value. §18.5.5 and §18.5.6: the condition of an implication or of if-else
// may be a real expression. §18.5.9: real variables may be ordered with
// solve...before. Set membership uses == on real values (§11.4.13).
// - a and b come from {1.5, 2.5}, are different and a < b, so a is 1.5 and b
//   2.5; c comes from {1.5, 2.5, 3.5} and differs from both, so it is 3.5;
//   the two elements of arr come from 1.5 to 5.5 in steps of 1.0, differ from
//   a, b and c and from each other, and arr[0] < arr[1], so they are 4.5 and
//   5.5. c > 3.0 holds, so the if branch gives k == 1.
// - r is a real in [0.0:1.0); half is 1 exactly when r >= 0.5 (if-else on a
//   real) and big is 1 only when r > 0.75 (implication from a real
//   comparison; big == 0 otherwise). For each of 20 calls the test checks
//   these relations and the range of r, and prints how many calls broke one:
//   0. The values of r are not printed, since they are random.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports rand real variables
// in constraints.

class rru_obj;
  rand real a, b, c;
  rand real arr[2];
  rand int k;
  constraint c_set { a inside {1.5, 2.5}; b inside {1.5, 2.5}; c inside {1.5, 2.5, 3.5};
                     foreach (arr[i]) arr[i] inside {1.5, 2.5, 3.5, 4.5, 5.5};
                     arr[0] < arr[1]; a < b; }
  constraint c_u { unique {a, b, c, arr}; }
  constraint c_if { if (c > 3.0) k == 1; else k == 2; }
  constraint o { solve c before k; }
endclass

class rrc_obj;
  rand real r;
  rand bit half, big;
  constraint c_r { r >= 0.0; r < 1.0; }
  constraint c_half { if (r >= 0.5) half == 1; else half == 0; }
  constraint c_big { (r > 0.75) -> big == 1; (r <= 0.75) -> big == 0; }
  constraint o { solve r before half, big; }
endclass

module test_rand_real_unique_and_conditions;
  rru_obj u;
  rrc_obj w;
  int ok, bad;

  initial begin
    u = new;
    ok = u.randomize();
    $display("ok=%0d a=%0.1f b=%0.1f c=%0.1f arr=%0.1f %0.1f k=%0d", ok, u.a, u.b, u.c,
             u.arr[0], u.arr[1], u.k);
    w = new;
    bad = 0;
    repeat (20) begin
      if (!w.randomize()) bad++;
      else if (!(w.r >= 0.0 && w.r < 1.0) || w.half != (w.r >= 0.5) || w.big != (w.r > 0.75))
        bad++;
    end
    $display("real conditions: broken in %0d of 20 calls", bad);
  end
endmodule
