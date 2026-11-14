/*
:name: test_cg_cross_auto_types_scope_and_fields
:description: Each cross has its own CrossValType, a struct with one member of the name and type of each crossed coverpoint, with the bounds [$bits-1:0] for a concatenation, and its own CrossQueueType, a queue of it; the names are not seen outside the cross, where other declarations of the same names stay in effect (IEEE 1800-2023 Section 19.6.1.3)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6.1.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cg_cross_auto_types_scope_and_fields.expected
*/
// IEEE 1800-2023 §19.6.1.3: every cross has the implicit typedefs
// CrossValType, a struct with one member for each coverpoint of the cross,
// of the name and the type of that coverpoint, and CrossQueueType, an
// unbounded queue of CrossValType. When the bounds of a coverpoint type are
// not evident, as for a concatenation without a declared type, they are
// [$bits(expression)-1:0]. The scope of both names is the cross: they are not
// accessible outside it. A function of a cross that returns CrossQueueType
// can give the value tuples of a cross bin (19.6.1.4).
//
// The module declares its own CrossValType (10 bits) and CrossQueueType
// (int). X1 crosses xy, the 12-bit concatenation {x, y}, and ca (3 bits);
// X2 crosses ca and cb (2 bits). The functions of the crosses can show their
// results only through the bins they make, so each function gives one tuple
// built from what it observes, and the coverpoints have bins for the values
// that the standard gives: in X1, '1 in the members named xy and ca is
// <4095, 7>, $left and $right of member xy given in the order of the members
// are <11, 0> and $bits(CrossValType) is <15, 0>; in X2, '1 in the members ca
// and cb is <7, 3> and $bits(CrossValType) is <5, 0>. Outside the crosses, the
// coverpoints cw and cq of the same covergroup have a bin for
// $bits(CrossValType) and $bits(CrossQueueType), which are the 10 and 32 of
// the module types, not the 15 or 5 of a cross type or the width of a queue,
// which has none. Both crosses keep only their own bins
// (cross_retain_auto_bins = 0), and the test prints the covered bins of X1,
// X2, cw and cq after each sample.
// Icarus Verilog 13.0 does not compile covergroups, and the counts of
// get_inst_coverage on a coverpoint or a cross are not supported by the 5.054
// release of Verilator.

module test_cg_cross_auto_types_scope_and_fields;
  typedef bit [9:0] CrossValType;
  typedef int CrossQueueType;

  bit [3:0] x;
  bit [7:0] y;
  bit [2:0] a;
  bit [1:0] b;
  bit [3:0] w;
  bit [5:0] u;

  covergroup cg;
    xy: coverpoint {x, y} {
      bins v11 = {11};
      bins v15 = {15};
      bins v4095 = {4095};
    }
    ca: coverpoint a {
      bins c0 = {0};
      bins c5 = {5};
      bins c7 = {7};
    }
    cb: coverpoint b {
      bins d0 = {0};
      bins d3 = {3};
    }
    X1: cross xy, ca {
      option.cross_retain_auto_bins = 0;
      function CrossQueueType x1_ones();
        x1_ones.push_back('{xy: '1, ca: '1});
      endfunction
      function CrossQueueType x1_bounds();
        CrossValType v;
        x1_bounds.push_back('{$left(v.xy), $right(v.xy)});
      endfunction
      function CrossQueueType x1_width();
        x1_width.push_back('{$bits(CrossValType), 0});
      endfunction
      bins all_ones = x1_ones();
      bins ends = x1_bounds();
      bins size = x1_width();
    }
    X2: cross ca, cb {
      option.cross_retain_auto_bins = 0;
      function CrossQueueType x2_ones();
        x2_ones.push_back('{ca: '1, cb: '1});
      endfunction
      function CrossQueueType x2_width();
        x2_width.push_back('{$bits(CrossValType), 0});
      endfunction
      bins all_ones = x2_ones();
      bins size = x2_width();
    }
    cw: coverpoint w { bins width = {$bits(CrossValType)}; }
    cq: coverpoint u { bins width = {$bits(CrossQueueType)}; }
  endgroup

  cg g = new;

  task automatic put(bit [11:0] vxy, bit [2:0] va, bit [1:0] vb, bit [3:0] vw, bit [5:0] vu);
    int c1, t1, c2, t2, c3, t3, c4, t4;
    {x, y} = vxy;
    a = va;
    b = vb;
    w = vw;
    u = vu;
    g.sample();
    void'(g.X1.get_inst_coverage(c1, t1));
    void'(g.X2.get_inst_coverage(c2, t2));
    void'(g.cw.get_inst_coverage(c3, t3));
    void'(g.cq.get_inst_coverage(c4, t4));
    $display("xy=%0d a=%0d b=%0d w=%0d u=%0d: X1 %0d/%0d, X2 %0d/%0d, cw %0d/%0d, cq %0d/%0d",
             vxy, va, vb, vw, vu, c1, t1, c2, t2, c3, t3, c4, t4);
  endtask

  initial begin
    $display("module: CrossValType %0d bits, CrossQueueType %0d bits", $bits(CrossValType),
             $bits(CrossQueueType));
    put(4095, 7, 3, 15, 0);
    put(11, 0, 0, 5, 0);
    put(15, 0, 0, 10, 32);
    put(0, 5, 0, 0, 0);
  end
endmodule
