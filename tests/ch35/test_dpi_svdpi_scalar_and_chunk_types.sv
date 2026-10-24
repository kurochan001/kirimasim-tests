/*
:name: test_dpi_svdpi_scalar_and_chunk_types
:description: svdpi.h gives the scalar type and its values, the 32-bit chunk types of packed bit and logic arrays and the chunk macros, and packed arguments arrive and leave as chunks with the 32 least significant bits first (IEEE 1800-2023 Section 35.3.2, H.10.1.1, H.10.1.2, H.7.7)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.10.1.1 H.10.1.2 H.7.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_svdpi_scalar_and_chunk_types.c
:expected_stdout: @test_dpi_svdpi_scalar_and_chunk_types.expected
*/
// IEEE 1800-2023 §35.3.2: the C side of DPI includes svdpi.h. H.10.1.1: a
// scalar bit or logic value has the type svScalar, an unsigned char, and
// svBit and svLogic are other names for it; its values are 0, 1, 2 for z and
// 3 for x. H.10.1.2: a chunk of a packed bit array is a uint32_t
// (svBitVecVal), and a chunk of a packed logic array is the structure
// s_vpi_vecval (svLogicVecVal), which holds the uint32_t aval and then the
// uint32_t bval; SV_PACKED_DATA_NELEMS gives the number of chunks of a width,
// one for every 32 bits or part of them, and SV_GET_UNSIGNED_BITS keeps the N
// low bits of a value, all 32 when N is 32. H.7.7: a packed argument is an
// array of such chunks whose first element holds the 32 least significant
// bits; the bits above the width in the last chunk are not defined, so the C
// code masks them.
//
// c_check_types prints 1 for each type that is the one H.10.1 gives (compared
// at compile time with C11 _Generic in C and decltype in C++) and the values
// of the macros. c_words gets a 40-bit bit and a 40-bit logic vector and
// prints their chunks; c_make writes two 40-bit outputs chunk by chunk. The
// logic values have no x or z bits, so every bval is 0.

module test_dpi_svdpi_scalar_and_chunk_types;
  import "DPI-C" function void c_check_types();
  import "DPI-C" function void c_words(input bit [39:0] b, input logic [39:0] l);
  import "DPI-C" function void c_make(output bit [39:0] b, output logic [39:0] l);

  bit [39:0] mb;
  logic [39:0] ml;

  initial begin
    c_check_types();
    c_words(40'hab_1234_5678, 40'h5c_9abc_def0);
    c_make(mb, ml);
    $display("c_make: bit %h, logic %h", mb, ml);
  end
endmodule
