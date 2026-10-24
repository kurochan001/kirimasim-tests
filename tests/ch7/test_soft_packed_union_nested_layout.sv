/*
:name: test_soft_packed_union_nested_layout
:description: the size and right-justified layout of a soft packed union apply again to a soft packed union nested in it, directly and through a packed structure (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1 7.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_soft_packed_union_nested_layout.expected
*/
// IEEE 1800-2023 §7.3.1: a soft packed union is as wide as its widest member,
// each member sits in its low bits, and writing a member leaves the bits above
// it unchanged. The same layout is applied recursively to soft packed unions
// nested in it.
// inner_t is a 6-bit soft union whose 4-bit member mid lies in its bits
// [3:0]. outer_t is 12 bits; its member r is a packed structure (§7.2.1)
// whose low 6 bits are an inner_t, and its member i is an inner_t itself, so
// both nested unions occupy bits [5:0] of the outer union and their mid
// member bits [3:0]. The test writes through the nested members and prints the
// whole outer union, which shows where each write lands.
// Icarus Verilog 13.0 does not support soft packed unions.

module test_soft_packed_union_nested_layout;
  typedef union soft {
    logic [5:0] wide;
    logic [3:0] mid;
  } inner_t;

  typedef struct packed {
    logic [1:0] tag;
    inner_t in;
  } rec_t;

  typedef union soft {
    logic [11:0] all;
    rec_t r;
    inner_t i;
  } outer_t;

  outer_t o;

  initial begin
    $display("bits: inner=%0d rec=%0d outer=%0d", $bits(inner_t), $bits(rec_t), $bits(outer_t));
    o.all = 12'hfff;
    o.r.in.mid = 4'h5;
    $display("after r.in.mid=5: all=%h r.tag=%b r.in.wide=%h i.wide=%h",
             o.all, o.r.tag, o.r.in.wide, o.i.wide);
    o.i.mid = 4'h0;
    $display("after i.mid=0: all=%h r.in.mid=%h", o.all, o.r.in.mid);
    o.r.in = 6'h2a;
    $display("after r.in=2a: all=%h i.mid=%h r.tag=%b", o.all, o.i.mid, o.r.tag);
  end
endmodule
