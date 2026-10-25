/*
:name: test_random_array_size_handles
:description: randomize() allocates no objects for an array of handles, keeps the size of an array without a kept size constraint, and accepts the size of an array in solve...before and disable soft (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4 18.5.13.2 18.5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_random_array_size_handles.expected
*/
// IEEE 1800-2023 §18.4: randomize() does not allocate class objects. When a
// rand dynamic array of handles grows, the retained handles keep their
// objects, whose contents are randomized, and the added elements are null;
// when it shrinks, the first handles stay. An array whose size is not
// constrained, or is constrained only by soft constraints that are discarded
// (here by disable soft s.size, 18.5.13.2), is not resized, and all its
// elements are randomized. The size of an array may appear in solve...before
// (18.5.9) and disable soft.
// - h holds two objects with v == 1; it grows to 4: h[0] and h[1] are the
//   same objects with v == 42 (the constraint of the item class), and h[2]
//   and h[3] are null; then it shrinks to 1 and keeps the first object;
// - u, three elements and no size constraint, becomes 20 21 22;
// - s, two elements, has only soft s.size() == 6, which the disable soft of
//   a later block discards, so s keeps size 2 and becomes 30 31 (if the soft
//   constraint were kept, s would have 6 elements);
// - solve q.size before z orders the size of q, and z < 10 still holds.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 stops with an internal error at solve q.size before z, and without
// that line its first randomize() does not return (soft s.size() with
// disable soft s.size).

class rsh_item;
  rand bit [7:0] v;
  constraint c_v { v == 8'd42; }
endclass

class rsh_obj;
  rand rsh_item h[];
  rand bit [7:0] u[];
  rand bit [7:0] s[];
  rand bit [7:0] q[$];
  rand bit [7:0] z;
  int hn = 4;
  constraint c_h { h.size() == hn; }
  constraint c_u { foreach (u[i]) u[i] == 8'd20 + 8'(i); }
  constraint c_s1 { soft s.size() == 6; }
  constraint c_s2 { disable soft s.size; foreach (s[i]) s[i] == 8'd30 + 8'(i); }
  constraint c_q { q.size() inside {[1:3]}; z < 8'd10; solve q.size before z; }
endclass

module test_random_array_size_handles;
  rsh_obj o;
  rsh_item a0, a1;
  int ok;

  initial begin
    o = new;
    o.h = new[2];
    o.h[0] = new;
    o.h[1] = new;
    a0 = o.h[0];
    a1 = o.h[1];
    a0.v = 8'd1;
    a1.v = 8'd1;
    o.u = '{1, 2, 3};
    o.s = new[2];
    ok = o.randomize();
    $display("ok=%0d", ok);
    $display("h: size %0d, same objects %0d %0d, v %0d %0d, null %0d %0d", o.h.size(),
             o.h[0] == a0, o.h[1] == a1, a0.v, a1.v, o.h[2] == null, o.h[3] == null);
    $display("u: size %0d, %0d %0d %0d", o.u.size(), o.u[0], o.u[1], o.u[2]);
    $display("s: size %0d, %0d %0d", o.s.size(), o.s[0], o.s[1]);
    $display("q size in [1:3] %0d, z < 10 %0d", o.q.size() inside {[1:3]}, o.z < 8'd10);
    o.hn = 1;
    a0.v = 8'd2;
    ok = o.randomize();
    $display("h shrunk: ok=%0d size %0d, same object %0d, v %0d", ok, o.h.size(),
             o.h[0] == a0, a0.v);
  end
endmodule
