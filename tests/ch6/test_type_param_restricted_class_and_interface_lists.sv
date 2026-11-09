/*
:name: test_type_param_restricted_class_and_interface_lists
:description: restricted type parameters in the parameter port lists of a class and an interface, without the parameter keyword and without a default, and a restricted local type parameter in a class body, take conforming types by default and by specialization or override (IEEE 1800-2023 Sections 6.20.3, 6.20.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.3 6.20.1 6.20.4 8.25 25.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_param_restricted_class_and_interface_lists.expected
*/
// IEEE 1800-2023 §6.20.3: a type parameter may restrict its types to enum,
// struct, union, class or interface class types with the keyword before its
// name. §6.20.1, Syntax 6-6: the restriction is part of every type parameter
// declaration, so it is also allowed in a parameter port list entry without
// the parameter keyword, in the parameter port list of a class (§8.25) or an
// interface (§25.8), in a localparam, and on a type parameter without a
// default, which every specialization then has to give.
// - holder has E (enum, default abc_t), S (struct, no default) and
//   U (union, default su_t), and the local type parameter LE (enum) = E.
//   holder#(.S(pair_t)) keeps the defaults: LE'(1) is RB, E has 3 names,
//   S has 16 bits, U 16 bits. holder#(xy_t, rec_t) gives the enum xy_t,
//   whose value 1 is QY and which has 2 names, and the unpacked struct
//   rec_t of an int and a byte, 40 bits.
// - status_if has the enum parameter ST (default xy_t). The instance i_d keeps
//   it and i_o overrides it with abc_t; a variable of ST then has 2 and 3
//   names, and its last value is QY and RC.
// The 5.052 release of Verilator prints the expected output. Icarus Verilog
// 13.0 does not support unpacked structures or the restriction keywords.

package rk2_pkg;
  typedef enum {RA, RB, RC} abc_t;
  typedef enum bit [1:0] {QX, QY} xy_t;
  typedef struct packed { byte hi; byte lo; } pair_t;
  typedef struct { int a; byte b; } rec_t;
  typedef union packed { shortint s; pair_t p; } su_t;
endpackage

class holder #(type enum E = rk2_pkg::abc_t, type struct S, type union U = rk2_pkg::su_t);
  localparam type enum LE = E;
  static function string show();
    LE e;
    e = LE'(1);
    return $sformatf("%s names=%0d S=%0d U=%0d", e.name(), e.num(), $bits(S), $bits(U));
  endfunction
endclass

interface status_if #(type enum ST = rk2_pkg::xy_t);
  ST st;
endinterface

module test_type_param_restricted_class_and_interface_lists;
  import rk2_pkg::*;

  status_if i_d ();
  status_if #(.ST(abc_t)) i_o ();

  initial begin
    $display("holder#(.S(pair_t)): %s", holder#(.S(pair_t))::show());
    $display("holder#(xy_t, rec_t): %s", holder#(xy_t, rec_t)::show());
    i_d.st = i_d.st.last();
    i_o.st = i_o.st.last();
    $display("i_d: names=%0d last=%s", i_d.st.num(), i_d.st.name());
    $display("i_o: names=%0d last=%s", i_o.st.num(), i_o.st.name());
  end
endmodule
