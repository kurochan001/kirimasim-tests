/*
:name: test_random_array_resize_modes
:description: randomize() resizes a dynamic array as new[] does and a queue at its back, new queue elements start at the default value, and retained elements keep their rand_mode while new ones are active (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4 18.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_random_array_resize_modes.expected
*/
// IEEE 1800-2023 §18.4: when randomize() changes the size of a rand dynamic
// array, the new array is initialized from the old one (7.5.1); a queue grows
// or shrinks at its back (the right side), and the elements it inserts take
// the default value of the element type. When a dynamic array or queue is
// resized by randomize() or by new, each retained element keeps its
// rand_mode (18.8) and each new element is active.
// - d = {5, 6} with both elements off grows to 4: the two old values stay
//   (they are state variables) and the new elements follow their
//   constraint, 5 6 102 103, modes 0011; d = new[5](d) keeps those modes and
//   adds an active element with the default 0 (00111);
// - q = {1, 2, 3}, all off, shrinks to {1, 2} (the back element goes), then
//   grows to 1 2 52 53 with modes 0011;
// - hq, a queue of handles holding one object, grows to 3; the elements it
//   adds have the default value of a class handle, null, and stay null,
//   since randomize() allocates no objects.
// Icarus Verilog 13.0 does not compile classes with constraints, and the
// 5.052 release of Verilator does not support rand_mode() on an element of a
// dynamic array or queue.

class rrm_item;
  rand bit [7:0] v;
  constraint c_v { v == 8'd42; }
endclass

class rrm_obj;
  rand bit [7:0] d[];
  rand bit [7:0] q[$];
  rand rrm_item hq[$];
  int qn = 2;
  constraint c_d { d.size() == 4; foreach (d[i]) (i >= 2) -> d[i] == 8'd100 + 8'(i); }
  constraint c_q { q.size() == qn; foreach (q[i]) (i >= 2) -> q[i] == 8'd50 + 8'(i); }
  constraint c_hq { hq.size() == 3; }
endclass

module test_random_array_resize_modes;
  rrm_obj o;
  rrm_item a0;
  int ok;

  initial begin
    o = new;
    o.d = new[2];
    o.d[0] = 8'd5;
    o.d[1] = 8'd6;
    o.d[0].rand_mode(0);
    o.d[1].rand_mode(0);
    o.q = '{1, 2, 3};
    foreach (o.q[i]) o.q[i].rand_mode(0);
    a0 = new;
    a0.v = 8'd1;
    o.hq.push_back(a0);
    ok = o.randomize();
    $display("ok=%0d", ok);
    $display("d: %0d %0d %0d %0d modes %0d%0d%0d%0d", o.d[0], o.d[1], o.d[2], o.d[3],
             o.d[0].rand_mode(), o.d[1].rand_mode(), o.d[2].rand_mode(), o.d[3].rand_mode());
    $display("q: size %0d, %0d %0d modes %0d%0d", o.q.size(), o.q[0], o.q[1],
             o.q[0].rand_mode(), o.q[1].rand_mode());
    $display("hq: size %0d, hq[0] is a0 %0d with v=%0d, null %0d %0d", o.hq.size(),
             o.hq[0] == a0, a0.v, o.hq[1] == null, o.hq[2] == null);

    o.qn = 4;
    ok = o.randomize();
    $display("q grown: ok=%0d %0d %0d %0d %0d modes %0d%0d%0d%0d", ok, o.q[0], o.q[1], o.q[2],
             o.q[3], o.q[0].rand_mode(), o.q[1].rand_mode(), o.q[2].rand_mode(),
             o.q[3].rand_mode());

    o.d = new[5](o.d);
    $display("d = new[5](d): %0d %0d %0d %0d %0d modes %0d%0d%0d%0d%0d", o.d[0], o.d[1],
             o.d[2], o.d[3], o.d[4], o.d[0].rand_mode(), o.d[1].rand_mode(),
             o.d[2].rand_mode(), o.d[3].rand_mode(), o.d[4].rand_mode());
  end
endmodule
