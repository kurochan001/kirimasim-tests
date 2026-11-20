/*
:name: test_constructor_default_empty_and_inout
:description: default in a constructor argument list expands to nothing when the superclass constructor has no arguments, also when the superclass has only the implicit constructor or the subclass uses extends with default, and it keeps an inout argument of the superclass constructor an inout (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.17 8.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constructor_default_empty_and_inout.expected
*/
// IEEE 1800-2023 §8.17: default in a subclass constructor argument list
// stands for the argument list of the superclass constructor, with the same
// order, direction, type, name and default value, and a constructor without
// super.new gets super.new(default); with default as the sole argument of
// extends, a subclass without a constructor gets one with the arguments of
// the superclass. §8.7: a class without new has an implicit new without
// arguments.
// - ce_plain_c has no constructor, so in ce_k_c, new(int k, default) has the
//   single argument k: new(7) gives k = 7, and the property of ce_plain_c
//   keeps its initial value 5.
// - ce_e_c extends ce_plain_c(default) and declares nothing: new() works.
// - ce_zero_c::new() sets z to 3; ce_z2_c::new(default) has no argument and
//   calls it.
// - ce_cnt_c::new(inout int count, int step = 1) adds step to count; in
//   ce_cnt2_c, new(default) keeps count an inout, so c goes from 10 to 11 with
//   new(c) and to 16 with new(c, 5).
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports
// default in a constructor argument list, so the expected output follows the
// cited clauses.

class ce_plain_c;
  int base_v = 5;
endclass

class ce_k_c extends ce_plain_c;
  int k;
  function new(int k, default);
    this.k = k;
  endfunction
endclass

class ce_e_c extends ce_plain_c(default);
endclass

class ce_zero_c;
  int z;
  function new();
    z = 3;
  endfunction
endclass

class ce_z2_c extends ce_zero_c;
  function new(default);
  endfunction
endclass

class ce_cnt_c;
  function new(inout int count, input int step = 1);
    count += step;
  endfunction
endclass

class ce_cnt2_c extends ce_cnt_c;
  function new(default);
  endfunction
endclass

module test_constructor_default_empty_and_inout;
  ce_k_c kk;
  ce_e_c ee;
  ce_z2_c zz;
  ce_cnt2_c c1, c2;
  int c;

  initial begin
    kk = new(7);
    ee = new();
    zz = new();
    $display("k=%0d base_v=%0d, e base_v=%0d, z=%0d", kk.k, kk.base_v, ee.base_v, zz.z);
    c = 10;
    c1 = new(c);
    $display("count after new(c): %0d", c);
    c2 = new(c, 5);
    $display("count after new(c, 5): %0d", c);
  end
endmodule
