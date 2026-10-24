/*
:name: test_param_class_extends_param_class
:description: a parameterized class can extend another parameterized class with its default parameters, with explicit parameters, with parameters that depend on its own, or with a base class given by a type parameter (IEEE 1800-2023 Section 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 20.6.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_class_extends_param_class.expected
*/
// IEEE 1800-2023 §8.25: a parameterized class may extend another
// parameterized class, using the default parameters of the base, explicit
// ones, its own parameters, or a type parameter that names the base class
// (which has to resolve to a class type).
// box_c#(T) reports $bits of its property v of type T (§20.6.2). plain_box_c
// extends box_c with its default T (bit), int_box_c with integer, pass_box_c
// with its own type parameter P, scaled_box_c with a vector whose width is its
// value parameter N, and any_box_c extends the class given by its type
// parameter B, by default box_c#(shortint). Each line prints the width that
// the base class of a specialization sees.
// Icarus Verilog 13.0 does not support parameterized classes.

class box_c #(type T = bit);
  T v;
  function int width();
    return $bits(v);
  endfunction
endclass

class plain_box_c #(int K = 0) extends box_c;
endclass

class int_box_c #(int K = 0) extends box_c #(integer);
endclass

class pass_box_c #(type P = byte) extends box_c #(P);
endclass

class scaled_box_c #(int N = 2) extends box_c #(bit [N-1:0]);
endclass

class any_box_c #(type B = box_c #(shortint)) extends B;
endclass

module test_param_class_extends_param_class;
  plain_box_c pb;
  int_box_c ib;
  pass_box_c pd;
  pass_box_c #(longint) pl;
  scaled_box_c #(6) s6;
  any_box_c ad;
  any_box_c #(box_c #(logic [4:0])) a5;

  initial begin
    pb = new;
    ib = new;
    pd = new;
    pl = new;
    s6 = new;
    ad = new;
    a5 = new;
    $display("default base: %0d, explicit integer: %0d", pb.width(), ib.width());
    $display("own type parameter: default %0d, longint %0d", pd.width(), pl.width());
    $display("dependent value parameter: %0d", s6.width());
    $display("base from type parameter: default %0d, logic [4:0] %0d", ad.width(), a5.width());
  end
endmodule
