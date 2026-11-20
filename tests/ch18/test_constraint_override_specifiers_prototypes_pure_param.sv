/*
:name: test_constraint_override_specifiers_prototypes_pure_param
:description: Override specifiers written on both an extern or implicit constraint prototype and its external block, :extends on a constraint that implements an inherited pure constraint, and :extends in a parameterized subclass that replaces a constraint of a specialization, all give the replaced or added constraints to randomize() (IEEE 1800-2023 Sections 18.5.2, 18.5.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.2 18.5.1 8.25
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_override_specifiers_prototypes_pure_param.expected
*/
// IEEE 1800-2023 §18.5.2: :initial, :extends and :final are written on both
// the prototype and the external block of a constraint, or on neither. A
// constraint prototype with the name of an inherited constraint replaces it,
// and a constraint of the name of an inherited pure constraint overrides it;
// :extends says that a constraint is an override, :initial that it is not.
// §18.5.1: a prototype is extern or implicit (the name alone), and its block
// is declared outside the class with the class scope. §8.25: a class can
// extend a specialization of a parameterized class.
//
// cp_abs_c has the pure constraint c_p and c_q (q == 1). cp_impl_c declares
// extern :extends c_p, which implements c_p (p == 7), extern :extends :final
// c_q, which replaces c_q (q == 8), and the implicit prototype :initial c_r,
// a new constraint (r == 9). cpp_sub_c #(M) extends cpp_c #(M) and replaces
// c_v (v == N) with :extends (v == M * 10): cpp_sub_c #(3) gives 30, while
// cpp_c #(3) itself gives 3.
// Icarus Verilog 13.0 does not support pure constraints and override
// specifiers and stops with a syntax error.

virtual class cp_abs_c;
  rand int p, q;
  pure constraint c_p;
  constraint c_q { q == 1; }
endclass

class cp_impl_c extends cp_abs_c;
  rand int r;
  extern constraint :extends c_p;
  extern constraint :extends :final c_q;
  constraint :initial c_r;
endclass

constraint :extends cp_impl_c::c_p { p == 7; }
constraint :extends :final cp_impl_c::c_q { q == 8; }
constraint :initial cp_impl_c::c_r { r == 9; }

class cpp_c #(int N = 1);
  rand int v;
  constraint c_v { v == N; }
endclass

class cpp_sub_c #(int M = 2) extends cpp_c #(M);
  constraint :extends c_v { v == M * 10; }
endclass

module test_constraint_override_specifiers_prototypes_pure_param;
  cp_impl_c i;
  cp_abs_c a;
  cpp_c #(3) pb;
  cpp_sub_c #(3) ps;
  int ok;

  initial begin
    i = new;
    a = i;
    ok = a.randomize();
    $display("impl: ok=%0d p=%0d q=%0d r=%0d", ok, i.p, i.q, i.r);
    pb = new;
    ps = new;
    ok = pb.randomize();
    $display("cpp_c #(3): ok=%0d v=%0d", ok, pb.v);
    ok = ps.randomize();
    $display("cpp_sub_c #(3): ok=%0d v=%0d", ok, ps.v);
  end
endmodule
