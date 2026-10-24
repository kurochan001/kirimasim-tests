/*
:name: test_type_matching_rules_by_type_compare
:description: type reference comparisons follow the matching type rules: renaming typedefs and type parameters, anonymous types within one declaration, typedefs of structures, enums and classes, redundant signing, array kinds, bounds and elements, and package typedefs wherever imported; other pairs do not match (IEEE 1800-2023 Section 6.22.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.22.1 6.23 26.3 7.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_matching_rules_by_type_compare.expected
*/
// IEEE 1800-2023 §6.23: two type references compare equal exactly when their
// types match (§6.22.1). The rules exercised, each with pairs that match (1)
// and pairs that do not (0):
//   b) a simple typedef or a type parameter override that renames a type
//      matches it: node_t and bit, ab2_t and ab_t, and T in tm_check when T
//      is given the package type rec_t;
//   c) an anonymous structure or enum matches itself only within its own
//      declaration statement (s1, s2 but not s3; e1, e2 but not f1);
//   d) a typedef of a structure or class matches itself and the variables
//      declared with it, not another typedef or class of the same body;
//   g) a signing that is already the default keeps the match (byte signed,
//      bit unsigned [3:0]), while byte unsigned does not match byte;
//   f) arrays match when both are packed or both unpacked, of the same kind,
//      with matching index and element types and, for fixed size, the same
//      bounds ([0:3] and [4] match, [1:4] does not; [][2:0] and [][0:2] do
//      not);
//   h) a package typedef matches itself whether imported by a wildcard or an
//      explicit import (§26.3); a local typedef of the same body does not.
// Any other pair is nonmatching. int fd [4] has the bounds [0:3] (§7.4.2).
// Icarus Verilog 13.0 does not parse type references (unsupported). For
// type(fa) == type(fd), Verilator 5.052 gives 0 instead of 1.

package tm_pkg;
  typedef struct packed { int a; int b; } rec_t;
endpackage

module tm_check #(parameter type T = int) ();
  localparam bit IS_REC = type(T) == type(tm_pkg::rec_t);
endmodule

module tm_wild;
  import tm_pkg::*;
  tm_check #(.T(rec_t)) c ();
endmodule

module tm_expl;
  import tm_pkg::rec_t;
  tm_check #(.T(rec_t)) c ();
endmodule

module test_type_matching_rules_by_type_compare;
  typedef bit node_t;
  typedef struct packed { int a; int b; } ab_t;
  typedef ab_t ab2_t;
  typedef struct packed { int a; int b; } other_ab_t;
  struct packed { int a; int b; } s1, s2;
  struct packed { int a; int b; } s3;
  enum {E0, E1} e1, e2;
  enum {F0, F1} f1;
  ab_t x1;
  ab_t x2;
  class c1_c; int v; endclass
  class c2_c; int v; endclass
  c1_c h1;
  c1_c h2;
  typedef byte signed sbyte_t;
  typedef bit unsigned [3:0] unib_t;
  typedef byte unsigned ubyte_t;
  int fa [0:3];
  int fb [0:3];
  int fc [1:4];
  int fd [4];
  int da [];
  int db [];
  int q1 [$];
  int aa [string];
  int ab [string];
  int ac [int];
  ab_t ea [2];
  ab2_t eb [2];
  other_ab_t ec [2];
  logic m1 [][2:0];
  logic m2 [][0:2];
  logic [7:0] pk;
  logic up [8];
  tm_wild w ();
  tm_expl ex ();
  tm_check #(.T(ab_t)) lc ();

  initial begin
    $display("b alias: %0d %0d %0d", type(node_t) == type(bit), type(ab2_t) == type(ab_t),
             type(ab2_t) == type(other_ab_t));
    $display("c anonymous: %0d %0d %0d %0d %0d", type(s1) == type(s2), type(s1) == type(s3),
             type(e1) == type(e2), type(e1) == type(f1), type(s1) == type(ab_t));
    $display("d typedef: %0d %0d %0d %0d %0d", type(x1) == type(x2), type(x1) == type(ab_t),
             type(x1) == type(other_ab_t), type(h1) == type(h2), type(c1_c) == type(c2_c));
    $display("g signing: %0d %0d %0d", type(sbyte_t) == type(byte),
             type(unib_t) == type(bit [3:0]), type(ubyte_t) == type(byte));
    $display("f fixed: %0d %0d %0d", type(fa) == type(fb), type(fa) == type(fc),
             type(fa) == type(fd));
    $display("f kinds: %0d %0d %0d %0d", type(da) == type(db), type(da) == type(q1),
             type(aa) == type(ab), type(aa) == type(ac));
    $display("f elements: %0d %0d %0d %0d", type(ea) == type(eb), type(ea) == type(ec),
             type(m1) == type(m2), type(pk) == type(up));
    $display("h package: %0d %0d %0d", w.c.IS_REC, ex.c.IS_REC, lc.IS_REC);
  end
endmodule
