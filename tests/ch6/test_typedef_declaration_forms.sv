/*
:name: test_typedef_declaration_forms
:description: typedef declarations of a data type with fixed, queue, associative and dynamic unpacked dimensions, of a type reached through an interface port with and without a bit-select, of a type selected through a forward class and its nested and parameterized classes, and forward typedefs with enum, struct, union, class, interface class and no keyword whose names are used before the final definitions (IEEE 1800-2023 Sections 6.18, A.2.1.3, A.2.2.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 8.23 8.27 A.2.1.3 A.2.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_declaration_forms.expected
*/
// IEEE 1800-2023 A.2.1.3: a type declaration is typedef with a data type or
// an incomplete class-scoped type, a name and variable dimensions; typedef
// with an interface port name, a constant bit-select, a dot, a type name and
// a new name; or typedef with an optional forward type (enum, struct, union,
// class or interface class) and a name. A.2.2.1: an incomplete class-scoped
// type is a type name, ::, a type name or class type, and further :: parts.
// - The variable dimensions belong to the new type: pair_t holds 2 ints,
//   q_t is a queue, aa_t is indexed by strings and dyn_t is a dynamic array.
// - §6.18: an interface-based typedef takes the type that the interface
//   connected to the port defines: 6 bits through b, 3 bits through
//   arr[1], an element of an interface array with the parameter W = 3.
// - §6.18: before the final definition a forward type is incomplete, and
//   class scope selection on it is allowed in a typedef: through the class
//   types Fwd::Inner and Fwd::Box#(5), T is int and W is logic [4:0].
//   Functions and the class User use the forward names fwd_e, fwd_s, fwd_u,
//   fwd_c, fwd_ic and fwd_any before their definitions, which then fix their
//   contents: E2 is the last of fwd_e, hi of fwd_s is the upper nibble, n[1]
//   of fwd_u is the upper nibble of b, and fwd_any is shortint, so a
//   returned -1 stays signed with 16 bits. A repeated forward declaration
//   after the definition is legal.
// Icarus Verilog 13.0 does not compile forward typedefs with a keyword or
// class scope selection on a forward type.

interface tf_bus #(parameter int W = 6);
  typedef logic [W-1:0] data_t;
endinterface

typedef enum fwd_e;
typedef struct fwd_s;
typedef union fwd_u;
typedef class fwd_c;
typedef interface class fwd_ic;
typedef fwd_any;
typedef Fwd;

typedef Fwd::Inner inner_c;
typedef Fwd::Box#(5) box5_c;
typedef inner_c::T deep_t;
typedef box5_c::W w5_t;

function automatic int enum_last(fwd_e e);
  return e.last();
endfunction

function automatic int struct_hi(fwd_s s);
  return s.hi;
endfunction

function automatic int union_n1(fwd_u u);
  return u.n[1];
endfunction

function automatic fwd_any minus_one();
  return -1;
endfunction

class User;
  fwd_c h;
  fwd_ic ih;
endclass

typedef enum logic [1:0] {E0, E1, E2} fwd_e;
typedef struct packed { logic [3:0] hi, lo; } fwd_s;
typedef union packed { logic [7:0] b; logic [1:0][3:0] n; } fwd_u;
interface class fwd_ic;
  pure virtual function int get();
endclass
class fwd_c implements fwd_ic;
  virtual function int get();
    return 42;
  endfunction
endclass
typedef class fwd_c;
typedef shortint fwd_any;

class Fwd;
  class Inner;
    typedef int T;
  endclass
  class Box #(int N = 1);
    typedef logic [N-1:0] W;
  endclass
endclass

module tf_user (tf_bus b, tf_bus arr [2]);
  typedef b.data_t local_t;
  typedef arr[1].data_t arr_t;
  local_t lv;
  arr_t av;
endmodule

module test_typedef_declaration_forms;
  typedef int pair_t [2];
  typedef byte q_t [$];
  typedef int aa_t [string];
  typedef logic [3:0] dyn_t [];

  tf_bus b0 ();
  tf_bus #(.W(3)) ar [2] ();
  tf_user u (.b(b0), .arr(ar));

  pair_t p = '{3, 4};
  q_t q;
  aa_t aa;
  dyn_t d;
  deep_t dv;
  w5_t wv;
  User usr;
  fwd_s s = 8'h5a;
  fwd_u un;
  fwd_any m1;

  initial begin
    q.push_back(8'd7);
    q.push_back(8'd9);
    aa["k"] = 11;
    d = new[3];
    $display("p=%0d,%0d/%0d q=%0d,%0d/%0d aa[k]=%0d/%0d d=%0d/%0d", p[0], p[1], $size(p), q[0],
             q[1], q.size(), aa["k"], aa.num(), d.size(), $bits(d[0]));
    $display("lv=%0d av=%0d", $bits(u.lv), $bits(u.av));
    $display("deep_t=%0d w5_t=%0d", $bits(dv), $bits(wv));
    un.b = 8'hc3;
    m1 = minus_one();
    $display("enum_last=%0d struct_hi=%0d union_n1=%0d m1=%0d bits=%0d", enum_last(E0),
             struct_hi(s), union_n1(un), m1, $bits(m1));
    usr = new;
    usr.h = new;
    usr.ih = usr.h;
    $display("get=%0d", usr.ih.get());
  end
endmodule
