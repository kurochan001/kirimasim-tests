/*
:name: test_enum_base_type_forms_and_int_default
:description: an enum without a base type is an int enum, and the base type can be an integer atom type with signing, an integer vector type with signing and a packed dimension, or a type name of either (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_enum_base_type_forms_and_int_default.expected
*/
// IEEE 1800-2023 §6.19: without a base type an enum has the base type int
// (32 bits, signed, 2-state, so a variable starts at 0 and the members can
// be -1 and 32'h7fff_ffff). The base type can be an integer atom type with
// optional signing (byte unsigned, shortint, integer), an integer vector type
// with optional signing and packed dimension (bit [2:0], logic signed [4:0]),
// or a type name that stands for an integer atom type (without an added
// dimension) or for an integer vector type (here with a packed dimension).
// The sizes, the signs of members compared with 0, and the initial values of
// variables (§6.11: 0 for 2-state types, x for 4-state types) follow the base.

module test_enum_base_type_forms_and_int_default;
  typedef byte unsigned ub_t;
  typedef bit bit_t;
  enum {I_NEG = -1, I_ZERO, I_MAX = 32'h7fff_ffff} ei;
  enum byte unsigned {U_LO, U_HI = 255} eu;
  enum shortint {S_MIN = -32768, S_MAX = 32767} es;
  enum integer {G0, G1} eg;
  enum bit [2:0] {B0, B7 = 7} eb;
  enum logic signed [4:0] {V_NEG = -16, V_POS = 15} ev;
  enum ub_t {T0, T200 = 200} et;
  enum bit_t [3:0] {N0, N15 = 15} en;

  initial begin
    $display("default: bits=%0d init=%0d I_NEG=%0d I_ZERO=%0d I_MAX=%0d neg=%0d",
             $bits(ei), ei, I_NEG, I_ZERO, I_MAX, I_NEG < 0);
    $display("atoms: bits=%0d,%0d,%0d U_HI=%0d neg=%0d S_MIN=%0d neg=%0d init=%0d,%0d,%b",
             $bits(eu), $bits(es), $bits(eg), U_HI, U_HI < 0, S_MIN, S_MIN < 0, eu, es, eg);
    $display("vectors: bits=%0d,%0d B7=%0d neg=%0d V_NEG=%0d neg=%0d init=%0d,%b",
             $bits(eb), $bits(ev), B7, B7 < 0, V_NEG, V_NEG < 0, eb, ev);
    $display("type names: bits=%0d,%0d T200=%0d neg=%0d N15=%0d neg=%0d",
             $bits(et), $bits(en), T200, T200 < 0, N15, N15 < 0);
  end
endmodule
