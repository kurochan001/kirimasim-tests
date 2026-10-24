/*
:name: test_dpi_canonical_logic_select_utilities
:description: The svdpi.h bit-select and part-select utilities have the declared types, read and write single bits of 4-state chunks, get a part-select of 1 to 32 bits into the low bits of a word, and put one without changing the bits around it, across a chunk boundary too (IEEE 1800-2023 Section 35.3.2, H.11.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.11.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_canonical_logic_select_utilities.c
:expected_stdout: @test_dpi_canonical_logic_select_utilities.expected
*/
// IEEE 1800-2023 §35.3.2: the C code uses the utilities of svdpi.h. H.11.5
// declares svGetBitselLogic, svPutBitselLogic, svGetPartselLogic,
// svPutPartselLogic and svPutPartselBit with fixed parameter and result types;
// indices are normalized, bit 0 being the least significant bit. A get of a
// part-select of width w from index i copies source bits i+w-1 to i into bits
// w-1 to 0 of the destination word and leaves its bits 31 to w as they were;
// a put copies bits w-1 to 0 of the source word into destination bits i+w-1
// to i and leaves the bits around them as they were. The width is at most 32.
//
// The SystemVerilog side only calls c_run once; it passes no x or z value. The
// C code builds 40-bit 4-state values in svLogicVecVal chunks (a bit is 0 for
// aval 0 bval 0, 1 for 1 0, z for 0 1 and x for 1 1, H.10.1.2) and prints
// 1 for each utility whose type is the declared one (compared at compile time
// with C11 _Generic in C and decltype in C++), the svLogic codes that the bit
// selects read (0, 1, 2 for z, 3 for x, H.10.1.1), and the chunks after the
// puts and gets. A put starts from a known pattern, so the bits it must keep
// are visible; a get here writes a zero word, or all 32 bits of a word, and
// test_dpi_canonical_partsel_get_keeps_bits checks the bits above w.

module test_dpi_canonical_logic_select_utilities;
  import "DPI-C" function void c_run();

  initial c_run();
endmodule
