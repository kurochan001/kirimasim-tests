/*
:name: test_dpi_canonical_aval_bval_packed_kinds
:description: Packed arrays, a packed struct, a packed union, integer and time with 0, 1, x and z bits reach C in the canonical svLogicVecVal form, which is the VPI aval/bval form (0 = 0/0, 1 = 1/0, z = 0/1, x = 1/1) in 32-bit chunks from the LSBs; a 2-state value has the same chunks as the aval of the 4-state one; a 4-state output written in that form comes back as 0, 1, z and x (IEEE 1800-2023 Section 35.5.6, H.2, H.7.3, H.7.7)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.2 H.7.3 H.7.7 H.10.1.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_canonical_aval_bval_packed_kinds.c
:expected_stdout: @test_dpi_canonical_aval_bval_packed_kinds.expected
*/
// IEEE 1800-2023 H.2, H.7.3, H.7.7: packed types, packed arrays, structs and
// unions, and also integer and time, are given to C in a canonical form: an
// array of 32-bit chunks, the first holding the 32 LSBs. The 4-state form
// svLogicVecVal is exactly the VPI s_vpi_vecval with its aval and bval
// fields, where a bit is 0 as 0/0, 1 as 1/0, z as 0/1 and x as 1/1
// (H.10.1.2), and the 2-state form svBitVecVal is consistent with it: its
// chunks are the aval chunks of the same value. §35.5.6: a packed struct or
// union is seen as a one-dimensional packed array. svdpi.h supplies functions
// such as svGetBitselLogic and svGetBitselBit to read single bits.
//
// c_canon prints the aval and bval chunks (masked to the used bits) of a
// 40-bit logic vector, a packed struct {a, b}, a packed union written through
// its struct member, an integer, a time and a logic [3:0][2:0], and the
// chunks of a bit [35:0] and a logic [35:0] holding the same value. It reads
// bits 39, 37 and 36 of the 40-bit vector with svGetBitselLogic (1, x and z
// are the svLogic values 1, 3 and 2), prints 1 when svLogicVecVal is
// s_vpi_vecval, and writes aval 0f, bval 33 to an output logic [7:0], which
// the design prints as 00zz11xx.
//
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 has no x and z.

module test_dpi_canonical_aval_bval_packed_kinds;
  typedef struct packed {
    logic [3:0] a;
    logic [7:0] b;
  } ps_t;
  typedef union packed {
    logic [7:0] w;
    struct packed {
      logic [3:0] hi;
      logic [3:0] lo;
    } s;
  } pu_t;

  import "DPI-C" function void c_canon(input logic [39:0] l40, input ps_t ps, input pu_t pu,
                                       input integer ig, input time tm,
                                       input logic [3:0][2:0] la, input bit [35:0] b36,
                                       input logic [35:0] l36, output logic [7:0] ol);

  logic [39:0] l40;
  ps_t ps;
  pu_t pu;
  integer ig;
  time tm;
  logic [3:0][2:0] la;
  logic [7:0] ol;

  initial begin
    l40 = {4'b10xz, 4'hf, 24'h0, 4'bzz00, 4'b1x1x};
    ps.a = 4'bx01z;
    ps.b = 8'h5a;
    pu.s.hi = 4'bzz11;
    pu.s.lo = 4'h6;
    ig = 32'h1234;
    ig[31:28] = 4'bzzzz;
    ig[0] = 1'bx;
    tm = 64'h0000_0001_0000_0002;
    tm[63] = 1'bz;
    tm[40] = 1'bx;
    la[3] = 3'b1xz;
    la[2] = 3'b000;
    la[1] = 3'b111;
    la[0] = 3'bz0x;
    c_canon(l40, ps, pu, ig, tm, la, 36'h9_8765_4321, 36'h9_8765_4321, ol);
    $display("ol %b", ol);
  end
endmodule
