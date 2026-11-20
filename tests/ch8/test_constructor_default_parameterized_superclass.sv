/*
:name: test_constructor_default_parameterized_superclass
:description: When a subclass extends a specialization of a parameterized class, default in its constructor argument list, and default in its extends specifier, expand to the constructor arguments of that specialization, whose type is the type given to the parameter (IEEE 1800-2023 Sections 8.17, 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.17 8.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constructor_default_parameterized_superclass.expected
*/
// IEEE 1800-2023 §8.17: default in a subclass constructor argument list
// expands to the argument list of the superclass constructor with the same
// types and default values, and default as the sole argument of the extends
// specifier gives a subclass without a constructor an implicit one with those
// arguments. §8.25: the superclass of a class that extends cd_box_c #(T') is
// that specialization, in which the argument v of new has the type T'.
//
// cd_nib_c extends cd_box_c #(bit [3:0]) and has new(int tag, default), so v
// is a bit [3:0]: -1 becomes 15, and new(2) takes the default 0. cd_byte_c
// extends cd_box_c #(byte)(default), so its implicit new has v of type byte:
// 300 becomes 44, and -3 stays -3. With the default specialization, int,
// the values would stay -1 and 300.
// Icarus Verilog 13.0 stops with a syntax error at the parameterized class
// cd_box_c, and the 5.054 release of Verilator does not support default in a
// constructor argument list, so the expected output follows the cited
// clauses.

class cd_box_c #(type T = int);
  T v;
  function new(T v = 0);
    this.v = v;
  endfunction
endclass

class cd_nib_c extends cd_box_c #(bit [3:0]);
  int tag;
  function new(int tag, default);
    this.tag = tag;
  endfunction
endclass

class cd_byte_c extends cd_box_c #(byte)(default);
endclass

module test_constructor_default_parameterized_superclass;
  cd_nib_c n1, n2;
  cd_byte_c b1, b2;

  initial begin
    n1 = new(1, -1);
    n2 = new(2);
    b1 = new(300);
    b2 = new(-3);
    $display("nib: %0d %0d, %0d %0d", n1.tag, n1.v, n2.tag, n2.v);
    $display("byte: %0d %0d", b1.v, b2.v);
  end
endmodule
