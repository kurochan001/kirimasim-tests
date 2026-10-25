/*
:name: test_random_array_kinds
:description: Fixed, dynamic, associative and queue arrays can be rand or randc, every element is randomized over its old value, and element constraints can index with constants, state variables and loop variables (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4 18.4.2 18.5.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_random_array_kinds.expected
*/
// IEEE 1800-2023 §18.4: class properties can be declared rand or randc, also
// arrays of every kind; all the elements of such an array are random (or
// cyclic, 18.4.2), and randomize() overwrites their previous values. The size
// of a rand dynamic array or queue can be constrained with size(): the array
// is resized first and then all its elements are randomized. A constraint on
// one element can index it with a constant, a state variable or a loop
// variable of foreach (18.5.7.1). So, starting from old values (1 or 9):
// - fixed[3] gets 10 11 12 from foreach with the loop variable;
// - dyn, of size 5, becomes size 3 and each element 10 * size + index, which
//   reads the new size: 30 31 32;
// - the queue q, of size 3, becomes size 2 with q[0] == 7 (constant index)
//   and q[k - 1] == 8 (k = 2, a state variable);
// - the associative array aa keeps its indices 5 and 9 (they are not
//   random) and gets aa[key] == key;
// - each element of the randc array rc[2] cycles on its own, so 4 calls give
//   each element each of the values 0 to 3 once (masks f f).
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 leaves the elements of aa unchanged and does not cycle the elements
// of rc.

class rak_obj;
  rand bit [7:0] fixed[3];
  rand bit [7:0] dyn[];
  rand bit [7:0] q[$];
  rand bit [7:0] aa[int];
  randc bit [1:0] rc[2];
  int k = 2;
  constraint c_fixed { foreach (fixed[i]) fixed[i] == 8'd10 + 8'(i); }
  constraint c_dyn {
    dyn.size() == 3;
    foreach (dyn[i]) dyn[i] == 8'(dyn.size() * 10 + i);
  }
  constraint c_q { q.size() == 2; q[0] == 8'd7; q[k - 1] == 8'd8; }
  constraint c_aa { foreach (aa[key]) aa[key] == 8'(key); }
endclass

module test_random_array_kinds;
  rak_obj o;
  int ok;
  bit [3:0] seen0, seen1;

  initial begin
    o = new;
    o.fixed = '{1, 1, 1};
    o.dyn = '{1, 1, 1, 1, 1};
    o.q = '{9, 9, 9};
    o.aa[5] = 8'd1;
    o.aa[9] = 8'd1;
    ok = o.randomize();
    $display("ok=%0d fixed: %0d %0d %0d", ok, o.fixed[0], o.fixed[1], o.fixed[2]);
    $display("dyn: size %0d, %0d %0d %0d", o.dyn.size(), o.dyn[0], o.dyn[1], o.dyn[2]);
    $display("q: size %0d, %0d %0d", o.q.size(), o.q[0], o.q[1]);
    $display("aa: size %0d, aa[5]=%0d aa[9]=%0d", o.aa.num(), o.aa[5], o.aa[9]);
    seen0 = 0;
    seen1 = 0;
    seen0[o.rc[0]] = 1'b1;
    seen1[o.rc[1]] = 1'b1;
    repeat (3) begin
      ok = ok & o.randomize();
      seen0[o.rc[0]] = 1'b1;
      seen1[o.rc[1]] = 1'b1;
    end
    $display("rc over 4 calls: ok=%0d masks %h %h", ok, seen0, seen1);
  end
endmodule
