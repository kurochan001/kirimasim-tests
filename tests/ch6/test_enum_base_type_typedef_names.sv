/*
:name: test_enum_base_type_typedef_names
:description: The base type of an enumeration can be a type name that denotes an integer atom type, without a packed dimension, or an integer vector type, with one; the enumeration then has the width and signedness of that type (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 A.2.2.1 A.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_base_type_typedef_names.expected
*/
// IEEE 1800-2023 §6.19 and footnote 19 of A.10 (on enum_base_type,
// A.2.2.1): a type_identifier can be the base type of an enumeration when it
// denotes an integer atom type, which then takes no packed dimension, or an
// integer vector type (bit, logic, reg), which can take one. The base type
// gives the enumeration its width and its signedness, and the names without
// a value follow the previous name plus one.
//
// sb_t is byte (atom, signed, 8 bits): the member SN = -2 is negative and
// compares below 0. sh_t is shortint (atom, signed, 16 bits). in_t is
// integer (atom, signed, 32 bits): IN = -5 is negative. ub_t is bit (vector)
// with the packed dimension [2:0]: 3 bits and unsigned, so U7 = 7 is not
// below 0 and the name after U5 = 5 is 6. lg_t is logic (vector) with
// [1:0]: 2 bits, printed in binary.

module test_enum_base_type_typedef_names;
  typedef byte sb_t;
  typedef shortint sh_t;
  typedef integer in_t;
  typedef bit ub_t;
  typedef logic lg_t;

  enum sb_t {SN = -2, SZ = 0, SP} e_sb;
  enum sh_t {H1 = 1000, H2} e_sh;
  enum in_t {I0, I1, IN = -5} e_in;
  enum ub_t [2:0] {U0, U5 = 5, U6, U7} e_ub;
  enum lg_t [1:0] {L0, L1, L3 = 3} e_lg;

  initial begin
    e_sb = SN;
    e_sh = H2;
    e_in = IN;
    e_ub = U7;
    e_lg = L3;
    $display("bits: sb=%0d sh=%0d in=%0d ub=%0d lg=%0d", $bits(e_sb), $bits(e_sh),
             $bits(e_in), $bits(e_ub), $bits(e_lg));
    $display("sb: SN=%0d SZ=%0d SP=%0d e_sb<0=%0d", SN, SZ, SP, e_sb < 0);
    $display("sh: H2=%0d", e_sh);
    $display("in: I1=%0d IN=%0d e_in<0=%0d", I1, e_in, e_in < 0);
    $display("ub: U6=%0d U7=%0d e_ub<0=%0d", U6, e_ub, e_ub < 0);
    $display("lg: L1=%b L3=%b", L1, e_lg);
  end
endmodule
