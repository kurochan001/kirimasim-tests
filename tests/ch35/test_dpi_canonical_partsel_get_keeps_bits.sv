/*
:name: test_dpi_canonical_partsel_get_keeps_bits
:description: svGetPartselBit and svGetPartselLogic copy a part-select of width w into bits w-1 to 0 of the destination word and leave its bits 31 to w unchanged (IEEE 1800-2023 Section 35.3.2, H.11.5)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 H.11.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_canonical_partsel_get_keeps_bits.c
:expected_stdout: @test_dpi_canonical_partsel_get_keeps_bits.expected
*/
// IEEE 1800-2023 §35.3.2: the C code uses the utilities of svdpi.h. H.11.5: a
// get of a part-select of width w at index i copies source bits i+w-1 to i
// into destination bits w-1 to 0, and when w is less than 32 the destination
// bits 31 to w keep the values they had; with w = 32 the whole word is
// replaced. Indices are normalized, bit 0 being the least significant bit,
// and the part-select may cross from one chunk of the source into the next.
//
// The SystemVerilog side only calls c_run; it passes no x or z value. The C
// code fills each destination word with a pattern before the get, so the
// bits that must be kept are visible, for widths 1, 8, 16, 31 and 32, from a
// 2-state source in svBitVecVal chunks and a 4-state source in svLogicVecVal
// chunks (aval and bval words, H.10.1.2).
//
// In Verilator 5.052 the get clears the destination bits 31 to w instead of
// keeping them (see the simulator differences document), so :oracle: names
// no simulator; Icarus Verilog 13.0 has no DPI.

module test_dpi_canonical_partsel_get_keeps_bits;
  import "DPI-C" function void c_run();

  initial c_run();
endmodule
