/*
:name: test_parameter_declaration_forms
:description: parameter and localparam declarations with a data type, an implicit type, a type parameter with and without an enum restriction, lists of value and type assignments, an unpacked array parameter, and parameters without a default that every instance overrides (IEEE 1800-2023 Sections 6.20.1, A.2.1.1, A.2.3, A.2.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.1 6.20.2 6.20.3 6.20.4 A.2.1.1 A.2.3 A.2.4 23.10.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_parameter_declaration_forms.expected
*/
// IEEE 1800-2023 A.2.1.1, §6.20.1: parameter and localparam take either a
// data type or an implicit type (signing and packed dimensions, or nothing)
// with a list of value assignments, or the keyword type, an optional basic
// type keyword such as enum (§6.20.3), and a list of type assignments.
// A.2.3, A.2.4: each list has one or more comma-separated entries; a value
// assignment can have unpacked dimensions, and the value of a parameter or
// the type of a type parameter can be left out in a parameter port list
// (A.10 note 22), where every instance then has to give it (§6.20.1).
// prm_child has such a parameter port list; its values are printed for two
// instances that override different parameters by name (§23.10.2.2):
// - N and T have no default; u_a sets N = 3 and T = shortint, u_b N = 1 and
//   T = logic [2:0], so $bits(T) is 16 and 3;
// - E is restricted to enum types; u_a passes shape_t, u_b keeps color_t, so
//   E'(1) is SQUARE and GREEN;
// - W and D = W * 2 share the type int unsigned; u_a sets W = 5, so D = 10;
// - S is signed [7:0] (§6.20.2: signed, 8 bits), U has no type or range and
//   takes the 8-bit unsigned type of 8'hA5;
// - T1 and T2 = logic [W-1:0] form one list of type assignments;
// - ARR is an unpacked array parameter, overridden as a whole in u_a;
// - LN and LT follow the localparam keyword of the port list, so they are
//   local parameters computed from N and T2;
// - in the body, parameter means localparam (§6.20.1), BP and BQ form one
//   list, BL and BL2 have an implicit range, and BLT is a local type.
// Each instance prints after N time units, so the lines come in a fixed order.

package pk_prm_types;
  typedef enum {RED, GREEN, BLUE} color_t;
  typedef enum {CIRCLE, SQUARE, TRIANGLE} shape_t;
endpackage

module prm_child
  import pk_prm_types::*;
  #(parameter int N,
    parameter type T,
    parameter type enum E = color_t,
    parameter int unsigned W = 4, D = W * 2,
    parameter signed [7:0] S = -3,
    parameter U = 8'hA5,
    parameter type T1 = byte, T2 = logic [W-1:0],
    parameter int ARR [2] = '{10, 20},
    localparam int LN = N + 1,
    localparam type LT = T2);

  parameter int BP = 5, BQ = BP + 1;
  localparam [3:0] BL = 4'hF, BL2 = BL - 1;
  localparam type BLT = T1;

  initial begin
    E ev;
    ev = E'(1);
    #N;
    $display("N=%0d bits(T)=%0d E'(1)=%s W=%0d D=%0d", N, $bits(T), ev.name(), W, D);
    $display("  S=%0d bits(S)=%0d U=%0d bits(U)=%0d", S, $bits(S), U, $bits(U));
    $display("  bits(T1)=%0d bits(T2)=%0d ARR=%0d,%0d LN=%0d bits(LT)=%0d",
             $bits(T1), $bits(T2), ARR[0], ARR[1], LN, $bits(LT));
    $display("  BP=%0d BQ=%0d BL=%0d BL2=%0d bits(BL)=%0d bits(BLT)=%0d",
             BP, BQ, BL, BL2, $bits(BL), $bits(BLT));
  end
endmodule

module test_parameter_declaration_forms;
  prm_child #(.N(3), .T(shortint), .E(pk_prm_types::shape_t), .W(5), .ARR('{7, 9})) u_a();
  prm_child #(.N(1), .T(logic [2:0])) u_b();
endmodule
