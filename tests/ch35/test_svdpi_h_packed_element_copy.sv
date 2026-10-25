/*
:name: test_svdpi_h_packed_element_copy
:description: svGetBitArrElem1VecVal and svGetLogicArrElem1VecVal read an element of an open array into a canonical array of SV_PACKED_DATA_NELEMS chunks that the caller allocates, and svPutBitArrElem1VecVal and svPutLogicArrElem1VecVal write one element from such an array (IEEE 1800-2023 Section 35.3.2, I.3, H.12.5, H.7.7)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.12.5 H.7.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_svdpi_h_packed_element_copy.c
:expected_stdout: @test_svdpi_h_packed_element_copy.expected
*/
// IEEE 1800-2023 §35.3.2: the C layer of DPI is the one Annex I lists.
// I.3 and H.12.5: the whole-element functions copy one packed element between
// the simulator and a canonical representation in the caller's memory; the
// caller allocates the array and passes its address, and an element of n bits
// needs SV_PACKED_DATA_NELEMS(n) chunks, of svBitVecVal for a 2-state element
// and of svLogicVecVal, with the aval and bval of each bit, for a 4-state one
// (H.7.7). The functions copy the whole element in either direction, so no
// part of the caller's array is left as the caller wrote it.
//
// c_copy fills two svBitVecVal chunks with a sentinel, reads the first
// element of bit [63:0] w[0:1] into them, and prints whether both chunks
// changed and what they hold: 0123456789abcdef splits into 89abcdef and
// 01234567, the low chunk first. It then writes 3333444411112222 into the
// second element from a chunk array of its own, reads the first element of
// logic [31:0] l[0:1] into an svLogicVecVal, prints its aval and bval, and
// writes deadbeef into the second element. The design prints both arrays
// afterwards, so the written elements show SV_PACKED_DATA_NELEMS chunks of
// the caller's memory and nothing else.

module test_svdpi_h_packed_element_copy;
  import "DPI-C" function void c_copy(inout bit [63:0] w [], inout logic [31:0] l []);

  bit [63:0] w [0:1] = '{64'h0123456789abcdef, 64'h0f0f0f0f0f0f0f0f};
  logic [31:0] l [0:1] = '{32'hcafebabe, 32'h12345678};

  initial begin
    c_copy(w, l);
    $display("w[0] %016h w[1] %016h", w[0], w[1]);
    $display("l[0] %08h l[1] %08h", l[0], l[1]);
  end
endmodule
