/*
:name: test_dpi_enum_base_type_representation
:description: Enumeration arguments reach C as the C type of their base type: byte, shortint, int, longint and scalar bit and logic bases are small values passed by value, integer, time and packed vector bases are canonical arrays passed by reference (integer and time 4-state), and C works with the values only, the names being restored in SystemVerilog (IEEE 1800-2023 Section 35.5.6, H.7.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.3 H.7.4 H.8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_enum_base_type_representation.c
:expected_stdout: @test_dpi_enum_base_type_representation.expected
*/
// IEEE 1800-2023 §35.5.6, H.7.3: an enumeration type crosses the DPI as its
// base type, in the C representation of that type, and its base type decides
// whether it is a small value passed by value (H.8.7). Any base type of an
// enumeration is allowed (6.19): the integer atom types, the vector types bit,
// logic and reg with or without a packed dimension, signed or unsigned, and a
// type name. integer and time bases are 4-state packed arrays, svLogicVecVal;
// bit vectors are svBitVecVal; scalar bit and logic are svBit and svLogic
// (H.7.4). The names of the values do not exist in C.
//
// c_enums takes one enumeration of each kind of base type and prints the C
// value it gets (for a by-reference one the aval and bval chunks), then writes
// the value 2 to an output enumeration with an int base and the value 7 to one
// with an integer base, which the design prints by name. c_next returns, for
// a byte-based enumeration, the value one above its input as a C char.
//
// Icarus Verilog 13.0 has no DPI.

module test_dpi_enum_base_type_representation;
  typedef enum byte {B_M3 = -3, B_FOUR = 4} e_byte_t;
  typedef enum shortint {S_BIG = 30000} e_short_t;
  typedef enum {I_ZERO, I_ONE, I_TWO} e_int_t;
  typedef enum longint {L_HUGE = 64'sd6000000000} e_long_t;
  typedef enum bit {BT_OFF, BT_ON} e_bit_t;
  typedef enum logic {LG_LO, LG_HI} e_logic_t;
  typedef enum integer {IG_SEVEN = 7, IG_NEG = -9} e_integer_t;
  typedef enum time {T_FAR = 64'h0000_0003_0000_0005} e_time_t;
  typedef enum bit [7:0] {BV_A5 = 8'ha5} e_bv_t;
  typedef enum logic [5:0] {LV_29 = 6'h29} e_lv_t;
  typedef enum reg [3:0] {RG_C = 4'hc} e_reg_t;
  typedef enum byte unsigned {BU_200 = 8'd200} e_bu_t;
  typedef bit [2:0] tri_bits_t;
  typedef enum tri_bits_t {TN_SIX = 3'd6} e_named_t;

  import "DPI-C" function void c_enums(input e_byte_t eb, input e_short_t es, input e_int_t ei,
                                       input e_long_t el, input e_bit_t ebt, input e_logic_t elg,
                                       input e_integer_t eig, input e_time_t etm,
                                       input e_bv_t ebv, input e_lv_t elv, input e_reg_t erg,
                                       input e_bu_t ebu, input e_named_t etn,
                                       output e_int_t oi, output e_integer_t oig);
  import "DPI-C" function e_byte_t c_next(input e_byte_t x);

  e_int_t oi;
  e_integer_t oig;
  e_byte_t nb;

  initial begin
    c_enums(B_M3, S_BIG, I_ONE, L_HUGE, BT_ON, LG_HI, IG_NEG, T_FAR, BV_A5, LV_29, RG_C, BU_200,
            TN_SIX, oi, oig);
    $display("oi %s %0d, oig %s %0d", oi.name(), oi, oig.name(), oig);
    nb = c_next(B_M3);
    $display("c_next(B_M3) %0d, c_next(3) %s", nb, c_next(e_byte_t'(3)).name());
  end
endmodule
