/*
:name: test_type_param_restricted_conforming_types
:description: a restricted type parameter conforms when it is given a typedef name of an enum, an enum declared by a forward typedef, a derived class, a specialization of a parameterized class, an interface class that extends another, or another type parameter with the same restriction (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.3 6.18 8.25 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_param_restricted_conforming_types.expected
*/
// IEEE 1800-2023 §6.20.3: it is an error if a restricted type parameter is
// given a type that does not conform to its basic type (enum, struct, union,
// class or interface class); a type of that basic type conforms, however it
// is named. §6.18: a typedef that names an existing type gives the same type,
// and a forward typedef with enum is completed by an enum definition. So:
// - E (enum) takes abc_t, its typedef name abc_alias_t and the forward-
//   declared fwd_t of 4 names in bit [2:0];
// - C (class) takes base_c, the derived class sub_c and box#(5), a
//   specialization of a parameterized class (§8.25);
// - I (interface class) takes base_ic and ext_ic, which extends it (§8.26);
//   square_c implements ext_ic, so a handle of it can be assigned to either;
// - the child instance gets E for its own enum-restricted CE.
// Each instance prints the number of names of E and its last name, $bits of
// the child's variable of type CE, id() of a new object of C and sides()
// through a handle of type I: d keeps the defaults, a gives the typedef
// name, sub_c and ext_ic, and f gives fwd_t and box#(5).
// The 5.052 release of Verilator prints the expected output. Icarus Verilog
// 13.0 first stops at the parameterized class box.

package rk3_pkg;
  typedef enum {RA, RB, RC} abc_t;
  typedef abc_t abc_alias_t;
  typedef enum fwd_t;
  typedef enum bit [2:0] {F0, F1, F2, F3} fwd_t;

  class base_c;
    virtual function int id();
      return 1;
    endfunction
  endclass
  class sub_c extends base_c;
    virtual function int id();
      return 2;
    endfunction
  endclass
  class box #(int N = 1);
    function int id();
      return 10 + N;
    endfunction
  endclass

  interface class base_ic;
    pure virtual function int sides();
  endclass
  interface class ext_ic extends base_ic;
    pure virtual function int corners();
  endclass
  class square_c implements ext_ic;
    virtual function int sides();
      return 4;
    endfunction
    virtual function int corners();
      return 4;
    endfunction
  endclass
endpackage

module rk3_child import rk3_pkg::*; #(parameter type enum CE = abc_t) ();
  CE v;
endmodule

module rk3_m import rk3_pkg::*; #(
  parameter type enum E = abc_t,
  parameter type class C = base_c,
  parameter type interface class I = base_ic
) ();
  E e;
  rk3_child #(.CE(E)) child ();

  function automatic string show();
    C c;
    I h;
    square_c sq;
    c = new;
    sq = new;
    h = sq;
    e = e.last();
    return $sformatf("E names=%0d last=%s child=%0d C id=%0d I sides=%0d", e.num(), e.name(),
                     $bits(child.v), c.id(), h.sides());
  endfunction
endmodule

module test_type_param_restricted_conforming_types;
  import rk3_pkg::*;

  rk3_m d ();
  rk3_m #(.E(abc_alias_t), .C(sub_c), .I(ext_ic)) a ();
  rk3_m #(.E(fwd_t), .C(box#(5))) f ();

  initial begin
    $display("d: %s", d.show());
    $display("a: %s", a.show());
    $display("f: %s", f.show());
  end
endmodule
