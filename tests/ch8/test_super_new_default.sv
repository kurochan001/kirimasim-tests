/*
:name: test_super_new_default
:description: default in the argument list of a constructor takes the arguments of the superclass constructor, super.new(default) passes them on, and extends with default gives an implicit constructor the same arguments (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.17 8.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_super_new_default.expected
*/
// IEEE 1800-2023 §8.17: default in the argument list of a subclass constructor
// stands for the arguments of the superclass constructor, with their names,
// types and default values, and super.new(default) passes them to it. derived
// adds an argument c after them, so new(5) gives a = 5, b = 3 and c = 9.
// extends with default as its argument gives a subclass without a constructor
// of its own an implicit one with the arguments of the superclass.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports this construct of
// IEEE 1800-2023.

class test_super_new_default_base;
  int a, b;
  function new(int a, int b = 3);
    this.a = a;
    this.b = b;
  endfunction
endclass

class test_super_new_default_derived extends test_super_new_default_base;
  int c;
  function new(default, int c = 9);
    super.new(default);
    this.c = c;
  endfunction
endclass

class test_super_new_default_implicit extends test_super_new_default_base(default);
endclass

module test_super_new_default;
  test_super_new_default_derived d1, d2;
  test_super_new_default_implicit k;
  initial begin
    d1 = new(5);
    d2 = new(1, 2, 4);
    k = new(7, 8);
    $display("d1: a=%0d b=%0d c=%0d", d1.a, d1.b, d1.c);
    $display("d2: a=%0d b=%0d c=%0d", d2.a, d2.b, d2.c);
    $display("k: a=%0d b=%0d", k.a, k.b);
  end
endmodule
