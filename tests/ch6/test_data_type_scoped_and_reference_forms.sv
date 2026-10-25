/*
:name: test_data_type_scoped_and_reference_forms
:description: Data types named through a package or class scope with packed dimensions, a class type and a nested class type, an incomplete class-scoped type, a class scope with a parameter value assignment, a type reference as a data type and as a casting type, and casts whose casting type is a simple type, a constant primary, a signing, string or const (IEEE 1800-2023 Sections 6.18, 6.23 and 6.24.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 6.23 6.24.1 A.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_data_type_scoped_and_reference_forms.expected
*/
// IEEE 1800-2023 A.2.2.1: a data type may be a type identifier with an
// optional package or class scope and packed dimensions, a class type, or a
// type reference; a class scope is a class type followed by ::, and a class
// type is a package-scoped class name with optional parameters and further ::
// class names. An incomplete class-scoped type starts with a type name and ::
// and continues with type names or class types. A casting type is a simple
// type, a constant primary, a signing, string or const.
//   - wide_t names pkg::nib_t with a packed dimension of two, so it holds 8
//     bits; b2_t comes from the incomplete class-scoped type
//     Outer::Nested::bits2_t; p3_t comes from the class scope P#(3):: and
//     its 3-bit type T,
//   - o and n are variables of a class type and of a nested class type,
//   - d and e are declared with a type reference, one from an expression and
//     one from a data type, as 6.23 requires with var,
//   - the casts use int as an integer type, pkg::nib_t and pkg::W as a
//     package-scoped type name and parameter name, 4 as a size, signed and
//     unsigned as signings, string and const.
// The printed numbers: pn = a, wide = 5a, b2 = 11, p3 = 101, it = 7,
// d = 42, e = 9, int' = 5, nib' = a, W' = 2, 4' = 5, signed' = -1,
// unsigned' = 4294967295, string' = 2, const' = 8, type(i)' = 5 and
// type(logic [3:0])' = 10.
//
// Icarus Verilog 13.0 does not compile this design; Verilator 5.052 does not
// accept every form here.

package pkg;
  typedef logic [3:0] nib_t;
  parameter int W = 3;
endpackage

class Outer;
  typedef int inner_t;
  static int count = 4;

  class Nested;
    typedef bit [1:0] bits2_t;
  endclass
endclass

class P #(parameter int W = 2);
  typedef logic [W-1:0] T;
  static int n = 5;
endclass

typedef pkg::nib_t [1:0] wide_t;
typedef Outer::Nested::bits2_t b2_t;
typedef P#(3)::T p3_t;

module test_data_type_scoped_and_reference_forms;
  pkg::nib_t pn = 4'hA;
  wide_t wide = 8'h5A;
  b2_t b2 = 2'b11;
  p3_t p3 = 3'b101;
  Outer o;
  Outer::Nested n;
  Outer::inner_t it = 7;
  int i = 7;
  var type(i + 1) d;
  var type(logic [3:0]) e;

  initial begin
    o = new();
    n = new();
    d = 42;
    e = 4'h9;
    $display("named: pn=%h wide=%h b2=%b p3=%b it=%0d", pn, wide, b2, p3, it);
    $display("class: count=%0d nested=%0d", Outer::count, P#(3)::n);
    $display("ref: d=%0d e=%h", d, e);
    $display("cast: int=%0d nib=%h param=%0d size=%0d signed=%0d unsigned=%0d",
             int'(5), pkg::nib_t'(4'hA), pkg::W'(2), 4'(5), signed'(4'hF),
             unsigned'(-1));
    $display("cast: string=%0d const=%0d typeexpr=%0d typedata=%0d",
             string'("xy").len(), const'(i + 1), type(i)'(5),
             type(logic [3:0])'(10));
  end
endmodule
