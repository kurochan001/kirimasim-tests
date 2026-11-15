/*
:name: test_countbits_unpacked_aggregates
:description: $countbits treats an unpacked array, an unpacked structure and a queue as one vector of all their bits, as if assigned from {>>{expression}}, and counts the matching bits of every element (IEEE 1800-2023 Section 20.9)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_countbits_unpacked_aggregates.expected
*/
// IEEE 1800-2023 §20.9: the expression argument of $countbits is of a
// bit-stream type, and the count is made on a vector of the same size
// assigned from {>>{expression}} (11.4.14), which holds the bits of every
// element of an unpacked array or queue and of every member of an unpacked
// structure. The elements and members here hold 1, 2, 4 and 8 one bits, so
// each sum of the ones of some of them is a different number, and only a
// count over all of them gives the printed value. The count of 0 bits, and
// that of 1 or 0 bits, show that the vector has the size of all the bits
// and nothing more: ua has 3 bytes (24 bits), st a byte, a 4-bit logic and
// a 6-bit bit vector (18 bits), and q 4 bytes (32 bits).
// Icarus Verilog 13.0 does not support unpacked structures, and the 5.054
// release of Verilator rejects an unpacked argument of $countbits.

module test_countbits_unpacked_aggregates;
  typedef struct {
    byte b;
    logic [3:0] n;
    bit [5:0] t;
  } st_t;

  byte ua [3];
  st_t st;
  byte q [$];

  initial begin
    ua = '{8'h01, 8'h03, 8'h0F};
    st.b = 8'h01;
    st.n = 4'b0011;
    st.t = 6'b001111;
    q = '{8'h80, 8'hC0, 8'hF0, 8'hFF};
    $display("array: ones %0d, zeros %0d, both %0d", $countbits(ua, '1), $countbits(ua, '0),
             $countbits(ua, '1, '0));
    $display("struct: ones %0d, zeros %0d, both %0d", $countbits(st, '1), $countbits(st, '0),
             $countbits(st, '1, '0));
    $display("queue: ones %0d, zeros %0d, both %0d", $countbits(q, '1), $countbits(q, '0),
             $countbits(q, '1, '0));
  end
endmodule
