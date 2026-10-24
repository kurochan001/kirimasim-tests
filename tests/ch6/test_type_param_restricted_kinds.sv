/*
:name: test_type_param_restricted_kinds
:description: type parameters restricted to enum, struct, union, class and interface class, alone or as a list of type assignments, take conforming types by default and by override (IEEE 1800-2023 Section 6.20.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.3 6.20.1 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_param_restricted_kinds.expected
*/
// IEEE 1800-2023 §6.20.3: a type parameter may restrict its types with the
// keyword enum, struct, union, class or interface class before its name.
// §6.20.1, Syntax 6-6: a type parameter declaration is type, the optional
// restriction and a list of type assignments, so in "type struct S1, S2"
// both names are restricted. Each parameter gets a type of its kind, by
// default and in the instance by override, and the module uses it: the
// sizes, the enum count and the class results come from those types.
// Each instance prints at the time $bits(s1), 16 and 32, in a fixed order.
// Icarus Verilog 13.0 does not parse interface classes (unsupported
// construct).

package rk_pkg;
  typedef enum {RA, RB, RC} abc_t;
  typedef enum bit [1:0] {QX, QY} xy_t;
  typedef struct packed { byte hi; byte lo; } pair_t;
  typedef struct packed { int w; } word_t;
  typedef union packed { shortint s; pair_t p; } su_t;
  interface class shape_ic;
    pure virtual function int sides();
  endclass
  class square_c implements shape_ic;
    virtual function int sides();
      return 4;
    endfunction
  endclass
  class tri_c implements shape_ic;
    virtual function int sides();
      return 3;
    endfunction
  endclass
endpackage

module rk_m import rk_pkg::*; #(
  parameter type enum E = abc_t,
  parameter type struct S1 = pair_t, S2 = word_t,
  parameter type union U = su_t,
  parameter type class C = square_c,
  parameter type interface class I = shape_ic
) ();
  E e;
  S1 s1;
  S2 s2;
  U u;
  C c;
  I i;
  initial begin
    c = new;
    i = c;
    #($bits(s1));
    $display("%m: E num=%0d S1=%0d S2=%0d U=%0d sides=%0d", e.num(), $bits(s1), $bits(s2),
             $bits(u), i.sides());
  end
endmodule

module test_type_param_restricted_kinds;
  import rk_pkg::*;
  rk_m d ();
  rk_m #(.E(xy_t), .S1(word_t), .S2(pair_t), .C(tri_c)) o ();
endmodule
