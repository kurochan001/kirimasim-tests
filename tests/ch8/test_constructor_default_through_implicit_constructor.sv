/*
:name: test_constructor_default_through_implicit_constructor
:description: A class that extends its base with default as the sole argument and has no constructor gets an implicit one with the arguments of the base constructor, their names and default values, and default in the constructor of a final class below it expands to those same arguments (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.17 8.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constructor_default_through_implicit_constructor.expected
*/
// IEEE 1800-2023 §8.17: when default is the sole argument in the extends
// specifier and the subclass has no new() of its own, its implicit new() has
// all the arguments of the superclass constructor, as if default were its
// sole argument. default in a constructor argument list expands to the
// arguments of the superclass constructor with their order, directions,
// types, names and default values, and a constructor that does not call
// super.new gets super.new(default). §8.13: a class declared :final can still
// extend another class.
//
// cd_root_c::new has name and size = 4. cd_mid_c extends cd_root_c(default)
// and declares no constructor, so new("m1") gives size 4, and the named
// arguments .size(9) and .name("m2") use the names of cd_root_c. cd_leaf_c is
// final, extends cd_mid_c and has new(default, bit flag = 1): its default
// expands to the arguments of the implicit constructor of cd_mid_c, which are
// those of cd_root_c, so new("l1") gives size 4 and flag 1, and
// new("l2", 2, 0) gives size 2 and flag 0.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports
// default in an extends specifier or a constructor argument list, so the
// expected output follows the cited clauses.

class cd_root_c;
  string name;
  int size;
  function new(string name, int size = 4);
    this.name = name;
    this.size = size;
  endfunction
endclass

class cd_mid_c extends cd_root_c(default);
endclass

class :final cd_leaf_c extends cd_mid_c;
  bit flag;
  function new(default, bit flag = 1);
    this.flag = flag;
  endfunction
endclass

module test_constructor_default_through_implicit_constructor;
  cd_mid_c m1, m2;
  cd_leaf_c l1, l2;

  initial begin
    m1 = new("m1");
    m2 = new(.size(9), .name("m2"));
    l1 = new("l1");
    l2 = new("l2", 2, 0);
    $display("%s %0d, %s %0d", m1.name, m1.size, m2.name, m2.size);
    $display("%s %0d %0d, %s %0d %0d", l1.name, l1.size, l1.flag, l2.name, l2.size, l2.flag);
  end
endmodule
