/*
:name: test_tf_port_directions_ref_static_and_item_forms
:description: a task argument may be input, output, inout, ref, const ref, ref static or const ref static, each with its own way of sharing the value, and a tf port item may carry attributes, var, an implicit type, unpacked dimensions and a default, and may have no name in a prototype (IEEE 1800-2023 Section A.2.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.2 13.5.3 A.2.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tf_port_directions_ref_static_and_item_forms.expected
*/
// IEEE 1800-2023 §A.2.7: a tf port direction is a port direction (input,
// output or inout) or ref with an optional const before it and an optional
// static after it. A tf port item has any number of attributes, an optional
// direction, an optional var, a data type or an implicit type (a packed
// range alone), and a port name with unpacked dimensions and an optional
// default value; the name may be left out only in a prototype (footnote 28).
// §13.5: input is copied in at the call, output is copied out at the return,
// inout both. §13.5.2: ref shares the caller's variable, so changes are seen
// on both sides at once; const ref may only be read; a ref static argument
// may be used where an automatic variable may not, such as a nonblocking
// assignment, and takes only variables with static lifetime. §13.5.3: an
// omitted argument takes the default value of its port.
//
// The task t is called at time 0 with seven static variables. At 0 it sets
// b to a + 10, adds 100 to c and 1000 to d, and copies s_ref, which is
// already 1004. At 1 another process sets s_in, s_cref and s_crs and copies
// s_out, s_io and s_ref: 0 and 3 (output and inout not copied out yet) and
// 1004. At 2 the task reads a (still the copy 1), e and g (the new 50 and
// 70) and does f <= f + 1, and returns. At 3 the caller shows s_out 11,
// s_io 103, s_ref 1004 and s_rs 7.
//
// The function sum has the port items (* a1 *) (* a2 *) input var int
// arr [2], then [3:0] nib = 4'd5 (no direction, so input, and an implicit
// type), then int k = 1; defaults are given to the singular ports only
// (13.5.3). sum('{3, 4}) gives 3 + 4 + 5 + 1 = 13, sum('{10, 20}, 4'd2, 0)
// gives 32 and sum('{1, 1}, , 0), which leaves out the middle argument,
// gives 7. The modport mp of the
// interface ifc imports inc with the prototype function int inc(int), whose
// port has no name; u.p.inc(4) gives 5.
//
// Icarus Verilog 13.0 supports neither the subroutines of a modport nor
// ref static, and Verilator 5.054 supports neither a prototype port without
// a name nor ref static.

`timescale 1ns/1ns

interface ifc;
  function automatic int inc(int v);
    return v + 1;
  endfunction
  modport mp (import function int inc(int));
endinterface

module user (ifc.mp p);
  int r;
  initial begin
    #5;
    r = p.inc(4);
    $display("prototype without a port name: inc(4) = %0d", r);
  end
endmodule

module test_tf_port_directions_ref_static_and_item_forms;
  int s_in = 1, s_out = 0, s_io = 3, s_ref = 4, s_cref = 5, s_rs = 6, s_crs = 7;
  int d_at_0, a_at_2, e_at_2, g_at_2;
  int out_at_1, io_at_1, ref_at_1;

  task automatic t(input int a, output int b, inout int c, ref int d, const ref int e,
                   ref static int f, const ref static int g);
    b = a + 10;
    c = c + 100;
    d = d + 1000;
    d_at_0 = s_ref;
    #2;
    a_at_2 = a;
    e_at_2 = e;
    g_at_2 = g;
    f <= f + 1;
  endtask

  function automatic int sum((* a1 *) (* a2 *) input var int arr [2], [3:0] nib = 4'd5,
                             int k = 1);
    return arr[0] + arr[1] + nib + k;
  endfunction

  ifc i0 ();
  user u (i0);

  initial begin
    t(s_in, s_out, s_io, s_ref, s_cref, s_rs, s_crs);
    #1;
    $display("in the task at 0: s_ref %0d; at 2: a %0d, e %0d, g %0d", d_at_0, a_at_2,
             e_at_2, g_at_2);
    $display("at 1: s_out %0d, s_io %0d, s_ref %0d", out_at_1, io_at_1, ref_at_1);
    $display("after the return: s_out %0d, s_io %0d, s_ref %0d, s_rs %0d", s_out, s_io,
             s_ref, s_rs);
    $display("sum('{3, 4}) %0d, sum('{10, 20}, 4'd2, 0) %0d, sum('{1, 1}, , 0) %0d",
             sum('{3, 4}), sum('{10, 20}, 4'd2, 0), sum('{1, 1}, , 0));
  end

  initial begin
    #1;
    s_in = 99;
    s_cref = 50;
    s_crs = 70;
    out_at_1 = s_out;
    io_at_1 = s_io;
    ref_at_1 = s_ref;
  end
endmodule
