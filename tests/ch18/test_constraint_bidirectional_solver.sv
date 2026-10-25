/*
:name: test_constraint_bidirectional_solver
:description: The solver satisfies all constraints together, in both directions also through inside, dist and implication, and handles algebraic, Boolean and mixed integer and bit constraints (IEEE 1800-2023 Section 18.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.3 18.5.3 18.5.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_bidirectional_solver.expected
*/
// IEEE 1800-2023 §18.3: randomize() gives new values to the active random
// variables so that every constraint holds, and a variable without a
// constraint can take any value of its declared range. The values chosen
// satisfy all constraints and distributions, and a variable on either side
// of an operator constrains the other one, also for inside, dist (18.5.3)
// and implication (18.5.5). The solver handles algebraic, Boolean and mixed
// integer and bit constraints. Each case below has a single solution:
// - inside: v inside {p, q} with p != v; fixing v to 7 and p to 3 makes q 7,
//   and fixing p and q makes v the member that is not excluded;
// - dist: w dist {[0:3], [8:9]} with k == w + 1; k == 9 makes w 8, and
//   k == 6 would need w == 5, outside the set, so randomize() fails;
// - implication: (m == 1) -> n > 10 with n == 3 makes m 0;
// - algebra: a * b == 91 with 1 < a < b has only 7 * 13;
// - Boolean: six relations of the bits of f leave only 4'b0110;
// - mixed: the bit fields of an int i and a power of two d == 1 << s with
//   1000 < d < 2000 (s = 10, d = 1024);
// - the unconstrained u (bit [7:0]) and sb (byte) take the ends of their
//   ranges when asked to, while every other constraint still holds.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 can fail the first call: it chooses an item of the dist first, and
// then k == 9 holds only if it chose [8:9].

class cbs_obj;
  rand bit [7:0] v, p, q;
  rand bit [7:0] w, k;
  rand bit m;
  rand bit [3:0] n;
  rand bit [7:0] a, b;
  rand bit [3:0] f;
  rand int i;
  rand bit [4:0] s;
  rand int unsigned d;
  rand bit [7:0] u;
  rand byte sb;
  constraint c_in { v inside {p, q}; p != v; }
  constraint c_dist { w dist {[0:3] := 1, [8:9] := 2}; k == w + 8'd1; }
  constraint c_imp { (m == 1'b1) -> n > 4'd10; }
  constraint c_alg { 16'(a) * 16'(b) == 16'd91; a > 8'd1; a < b; }
  constraint c_bool {
    f[0] ^ f[1];
    f[1] -> f[2];
    !(f[2] && f[3]);
    f[0] == f[3];
    f[1] || f[3];
    f[2] || !f[0];
  }
  constraint c_mix { (i >> 4) == 3; i[3:0] == 4'hA; d == 32'd1 << s; d > 1000; d < 2000; }
endclass

module test_constraint_bidirectional_solver;
  cbs_obj o;
  int ok;

  initial begin
    o = new;
    ok = o.randomize() with { v == 8'd7; p == 8'd3; k == 8'd9; n == 4'd3; };
    $display("ok=%0d inside: q=%0d dist: w=%0d implication: m=%0d", ok, o.q, o.w, o.m);
    $display("algebra: a=%0d b=%0d Boolean: f=%b mixed: i=%0d s=%0d d=%0d",
             o.a, o.b, o.f, o.i, o.s, o.d);
    ok = o.randomize() with { p == 8'd3; q == 8'd4; v != 8'd3; };
    $display("set fixed: ok=%0d v=%0d", ok, o.v);
    ok = o.randomize() with { k == 8'd6; };
    $display("k == 6: ok=%0d", ok);
    ok = o.randomize() with { u == 8'd255; sb == -128; };
    $display("range ends: ok=%0d u=%0d sb=%0d f=%b", ok, o.u, o.sb, o.f);
    ok = o.randomize() with { u == 8'd0; sb == 127; };
    $display("range ends: ok=%0d u=%0d sb=%0d a=%0d", ok, o.u, o.sb, o.a);
  end
endmodule
