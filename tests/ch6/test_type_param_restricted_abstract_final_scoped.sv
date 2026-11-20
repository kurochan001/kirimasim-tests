/*
:name: test_type_param_restricted_abstract_final_scoped
:description: A type parameter restricted with class conforms to an abstract class and to a final class, one restricted with struct to an unpacked structure typedef reached through a class scope, and one restricted with union to an unpacked union, by default and by override (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.3 8.13 8.21 8.23
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_param_restricted_abstract_final_scoped.expected
*/
// IEEE 1800-2023 §6.20.3: a type parameter with the keyword class, struct or
// union before its name accepts the types of that basic kind, and only those.
// An abstract class (§8.21, virtual class) and a class declared :final (§8.13)
// are both classes; a typedef of a structure declared in a class and named
// with the class scope (§8.23) is a structure; an unpacked union is a union.
//
// rtk_m has A (class, an abstract class by default), F (class, a final class
// that extends A), S (struct, a structure typedef of box_c) and U (union).
// show() makes an object of F, keeps it in a handle of type A and calls the
// virtual id() through that handle, prints $bits(S) and compares U with iu_t.
// The instance d keeps the defaults: id 9, S of two bytes, 16 bits, and U is
// iu_t. The instance o gives abs2_c, fin2_c, box_c::wide_t of an int and a
// byte, 40 bits, and bl_u: id 10, 40, and U is not iu_t.
// Icarus Verilog 13.0 stops with a syntax error on the pure virtual method
// of the first abstract class.

package rtk_pkg;
  virtual class abs_c;
    pure virtual function int id();
  endclass
  class :final fin_c extends abs_c;
    virtual function int id();
      return 9;
    endfunction
  endclass
  virtual class abs2_c;
    pure virtual function int id();
  endclass
  class :final fin2_c extends abs2_c;
    virtual function int id();
      return 10;
    endfunction
  endclass
  class box_c;
    typedef struct { byte a; byte b; } pair_t;
    typedef struct { int a; byte b; } wide_t;
  endclass
  typedef union { int i; shortint s; } iu_t;
  typedef union { byte b; longint l; } bl_u;
endpackage

module rtk_m import rtk_pkg::*; #(
  parameter type class A = abs_c,
  parameter type class F = fin_c,
  parameter type struct S = box_c::pair_t,
  parameter type union U = iu_t
) ();
  function automatic string show();
    F f;
    A a;
    f = new;
    a = f;
    return $sformatf("id=%0d S=%0d U is iu_t=%0d", a.id(), $bits(S), type(U) == type(iu_t));
  endfunction
endmodule

module test_type_param_restricted_abstract_final_scoped;
  import rtk_pkg::*;
  rtk_m d ();
  rtk_m #(.A(abs2_c), .F(fin2_c), .S(box_c::wide_t), .U(bl_u)) o ();
  initial begin
    $display("d: %s", d.show());
    $display("o: %s", o.show());
  end
endmodule
