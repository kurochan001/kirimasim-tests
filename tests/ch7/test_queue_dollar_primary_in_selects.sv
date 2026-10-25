/*
:name: test_queue_dollar_primary_in_selects
:description: The $ primary in a select of a queue stands for the last index of that queue, in element selects for reading and writing, in expressions such as $-1, in slices and in a select nested in the index of another queue (IEEE 1800-2023 Section 7.10.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.1 7.10 A.8.4 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_queue_dollar_primary_in_selects.expected
*/
// IEEE 1800-2023 §7.10 and §7.10.1 with footnote 47 of A.10 (on the $
// primary, A.8.4): $ is a primary used in a select of a queue variable,
// where it is the last index of that queue, and it follows the size of the
// queue as elements are added. It can be an operand of an expression in the
// select ($-1) and a bound of a slice (Q[1:$], Q[$:$]).
//
// q starts as {10, 20, 30, 40}, so $ is 3: q[$] = 40 and q[$-1] = 30; the
// slice q[1:$] has 3 elements, 20, 30, 40, and q[$:$] the one element 40.
// After push_back(50), $ is 4: q[$] = 50 and q[$-4] = 10.
// In q[q2[$]] with q2 = {3, 1}, the inner $ is the last index of q2, so the
// index is q2[1] = 1 and the value is q[1] = 20. Writing q[$] = 99 changes
// the last element.
//
// Icarus Verilog 13.0 accepts q[$] but reports a syntax error for $ in an
// expression such as $-1 and in a slice bound.

module test_queue_dollar_primary_in_selects;
  int q[$] = {10, 20, 30, 40};
  int q2[$] = {3, 1};
  int s[$];

  initial begin
    $display("q[$]=%0d q[$-1]=%0d", q[$], q[$-1]);
    s = q[1:$];
    $display("q[1:$]: size=%0d %0d %0d %0d", s.size(), s[0], s[1], s[2]);
    s = q[$:$];
    $display("q[$:$]: size=%0d %0d", s.size(), s[0]);
    q.push_back(50);
    $display("after push_back: size=%0d q[$]=%0d q[$-4]=%0d", q.size(), q[$], q[$-4]);
    $display("q[q2[$]]=%0d", q[q2[$]]);
    q[$] = 99;
    $display("after q[$]=99: size=%0d q[4]=%0d q[3]=%0d", q.size(), q[4], q[3]);
  end
endmodule
