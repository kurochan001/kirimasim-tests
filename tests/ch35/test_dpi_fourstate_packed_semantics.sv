/*
:name: test_dpi_fourstate_packed_semantics
:description: Packed structures and arrays of logic keep their four-state SystemVerilog values across the DPI boundary; C changes bits through the canonical access functions without assuming a memory layout (IEEE 1800-2023 Section 35.2.2.1)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.2.2 35.2.2.1 H.7.4 H.7.5 H.7.7 35.3.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_fourstate_packed_semantics.c
:expected_stdout: @test_dpi_fourstate_packed_semantics.expected
*/
// IEEE 1800-2023 §35.2.2.1: the DPI adds no constraint on how SystemVerilog
// data types are represented; the layout of 2- or 4-state packed structures
// and arrays is implementation dependent and irrelevant for SystemVerilog
// semantics. The C code therefore never reads or writes a whole packed object
// as memory, but changes individual bits with the canonical bit access of
// H.7.7; the bit index is the index of the packed value (6.22.2, H.7.4,
// H.7.5). The struct p of 16 bits holds 16'h359c, v holds 8'hf0 and the packed
// array a holds 8'ha5. C puts x at bits 12 and 0 and z at bits 5, 3 and 7, and
// SystemVerilog reads the members and elements: p.a.hi = 4'b001x,
// p.b.hi = 4'b10z1, v = 8'b1111z00x, a[1] = 4'bx010. The other bits keep
// their values, so a wrong representation or a lost four-state bit changes
// the output.
//
// Icarus Verilog 13.0 has no DPI. Verilator 5.052 cannot hold x or z, so the
// expected output follows the standard alone.

module test_dpi_fourstate_packed_semantics;
  typedef struct packed {
    logic [3:0] hi;
    logic [3:0] lo;
  } nib_t;

  typedef struct packed {
    nib_t a;
    nib_t b;
  } pair_t;

  import "DPI-C" function void c_put_special(inout pair_t p, inout logic [7:0] v,
                                            inout logic [1:0][3:0] a);

  pair_t p;
  logic [7:0] v;
  logic [1:0][3:0] a;

  initial begin
    p = 16'h359c;
    v = 8'hf0;
    a = 8'ha5;
    c_put_special(p, v, a);
    $display("p: %b %b %b %b", p.a.hi, p.a.lo, p.b.hi, p.b.lo);
    $display("v: %b", v);
    $display("a[1]: %b", a[1]);
  end
endmodule
