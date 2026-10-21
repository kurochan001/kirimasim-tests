/*
:name: test_foreach_dynamic_multidim_constraint
:description: foreach constraints over a dynamic array whose size is constrained, with the size used as a state variable and a loop-variable guard, over a two-dimensional array with a descending range, and over a string (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.1 18.5.12 18.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_dynamic_multidim_constraint.expected
*/
// IEEE 1800-2023 §18.5.7.1:
// - the size of a rand dynamic array (18.4) is solved before the foreach
//   constraints on it, which see q.size() as a state variable: q[0] is the
//   size and each next element is 2 more. The condition k == 0 uses only the
//   loop variable, so it is a guard (18.5.12): the else branch, which reads
//   q[k - 1], is not created for k == 0. Every result of 30 calls is checked,
//   and with the size fixed to 3 by randomize() with, q has 3 elements:
//   3, 5 and 7. In Verilator 5.052 that call gives q[0] == 3 but leaves q
//   at the size of the call before, so its output depends on its seed.
// - each loop variable follows its dimension in the order of 20.7: for
//   m[3:1][2], i goes over 3, 2 and 1 and j over 0 and 1, so m[i][j] ==
//   i * 10 + j gives every element a single value.
// - a string is iterated as a dynamic array of bytes indexed from 0, so
//   r[n] == word[n] + 1 with word "abc" makes r the bytes of "bcd".

class fdm_obj;
  rand byte unsigned q[];
  rand int m[3:1][2];
  rand byte unsigned r[3];
  string word = "abc";
  constraint c_size { q.size() inside {[2:6]}; }
  constraint c_q {
    foreach (q[k])
      if (k == 0) q[k] == q.size();
      else q[k] == q[k - 1] + 8'd2;
  }
  constraint c_m { foreach (m[i, j]) m[i][j] == i * 10 + j; }
  constraint c_r { foreach (word[n]) r[n] == word[n] + 8'd1; }
endclass

module test_foreach_dynamic_multidim_constraint;
  fdm_obj o;
  int failed = 0, bad = 0;
  string line;

  initial begin
    o = new;
    repeat (30) begin
      if (!o.randomize()) failed++;
      if (!(o.q.size() inside {[2:6]}) || o.q[0] != o.q.size()) bad++;
      foreach (o.q[k]) if (k > 0 && o.q[k] != o.q[k - 1] + 2) bad++;
    end
    $display("30 calls: failed=%0d violations=%0d", failed, bad);
    void'(o.randomize() with { q.size() == 3; });
    $display("size %0d: q = %0d %0d %0d", o.q.size(), o.q[0], o.q[1], o.q[2]);
    line = "";
    foreach (o.m[i, j]) line = {line, $sformatf(" m[%0d][%0d]=%0d", i, j, o.m[i][j])};
    $display("m:%s", line);
    $display("r = %s", {o.r[0], o.r[1], o.r[2]});
  end
endmodule
