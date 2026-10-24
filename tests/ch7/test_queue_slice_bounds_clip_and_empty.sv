/*
:name: test_queue_slice_bounds_clip_and_empty
:description: a queue slice Q[a:b] takes variable bounds, clips a below 0 to 0 and b above $ to $, is empty when a > b or a bound has an x or z bit, and Q[n:n] holds just Q[n] or is empty when n is out of range (IEEE 1800-2023 Section 7.10.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_queue_slice_bounds_clip_and_empty.expected
*/
// IEEE 1800-2023 §7.10.1: the bounds of a queue slice Q[a:b] can be any
// integral expressions, not only constants, and the slice has b-a+1 elements.
// It is the empty queue when a > b or when a or b is a 4-state value with x or
// z bits. Q[a:b] with a < 0 is Q[0:b], and with b > $ it is Q[a:$]. Q[n:n] is
// the one-element queue {Q[n]}, or empty when n < 0 or n > $.
// q holds 10 20 30 40 50, so $ is 4. Every slice is copied to r, which show
// prints with its size; a and b are variables, and one slice has expressions as
// bounds.
// Icarus Verilog 13.0 copies the whole queue for every slice with variable
// bounds. Verilator 5.052 gives 50 for q[5:5], the whole queue for q[-1:-1]
// and one element for the bound 3'b0z1.

module test_queue_slice_bounds_clip_and_empty;
  int q[$] = '{10, 20, 30, 40, 50};
  int r[$];
  int a, b;
  integer xa = 'x;
  logic [2:0] zb = 3'b0z1;

  task automatic show(string label);
    string s = $sformatf("size=%0d:", r.size());
    foreach (r[i]) s = {s, $sformatf(" %0d", r[i])};
    $display("%s %s", label, s);
  endtask

  initial begin
    a = 1; b = 3; r = q[a:b];
    show("q[1:3]");
    r = q[a+1:2*b-3];
    show("q[a+1:2*b-3]");
    a = -2; b = 1; r = q[a:b];
    show("q[-2:1]");
    a = 3; b = 9; r = q[a:b];
    show("q[3:9]");
    a = -1; b = 7; r = q[a:b];
    show("q[-1:7]");
    a = 3; b = 2; r = q[a:b];
    show("q[3:2]");
    a = 2; r = q[a:a];
    show("q[2:2]");
    a = 5; r = q[a:a];
    show("q[5:5]");
    a = -1; r = q[a:a];
    show("q[-1:-1]");
    b = 3; r = q[xa:b];
    show("q[x:3]");
    a = 1; r = q[a:zb];
    show("q[1:3'b0z1]");
  end
endmodule
