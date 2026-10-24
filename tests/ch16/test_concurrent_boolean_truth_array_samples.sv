/*
:name: test_concurrent_boolean_truth_array_samples
:description: a Boolean expression of a concurrent assertion is false when its value is 0, x or z and true for any other known value, as in an if condition, and elements of a queue, a dynamic array and an associative array that the assertion samples keep their sampled values when they are removed or the array is resized before the Observed region of the tick (IEEE 1800-2023 Section 16.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.6 16.5.1 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_concurrent_boolean_truth_array_samples.expected
*/
// IEEE 1800-2023 §16.6: the result of a Boolean expression in a concurrent
// assertion is read as the condition of an if statement: 0, x and z are
// false and any other value is true. a_vec checks a 4-bit v sampled as 0000,
// xxxx, zzzz, 0001, 1000 and 0110 at the ticks of clk at 10 to 60, and a_bit
// a 1-bit s sampled as 0, x, z, 1, 1 and 1. So both fail at 10, 20 and 30
// and pass at 40, 50 and 60; a test of the LSB of v alone would fail a_vec at
// 50 and 60.
// §16.6 also requires that elements of a queue, a dynamic array or an
// associative array sampled for an assertion stay available until the
// expression is evaluated, even if they are removed or the array is resized
// in the meantime. aclk rises at 70 and 80 only. In the time step of 70 the
// procedure deletes q, shrinks d to one element and deletes aa[3] before it
// raises aclk, so the Preponed values (§16.5.1) q[1] == 8, d[2] == 9 and
// aa[3] == 4 are used and the three assertions pass. At 75 the arrays get
// the values 2, 3 and 1 at those indices, which the tick at 80 samples, and
// the assertions fail. The action blocks (§16.14.1) record the times.

`timescale 1ns/1ns

module test_concurrent_boolean_truth_array_samples;
  logic clk = 0, aclk = 0;
  logic [3:0] v = 4'b0000;
  logic s = 1'b0;
  int q[$];
  int d[];
  int aa[int];
  int pv[$], fv[$], ps[$], fs[$], pq[$], fq[$], pd[$], fd[$], pa[$], fa[$];

  a_vec: assert property (@(posedge clk) v) pv.push_back($time); else fv.push_back($time);
  a_bit: assert property (@(posedge clk) s) ps.push_back($time); else fs.push_back($time);

  a_q: assert property (@(posedge aclk) q[1] == 8) pq.push_back($time);
    else fq.push_back($time);
  a_d: assert property (@(posedge aclk) d[2] == 9) pd.push_back($time);
    else fd.push_back($time);
  a_aa: assert property (@(posedge aclk) aa[3] == 4) pa.push_back($time);
    else fa.push_back($time);

  function automatic string times(int t[$]);
    string str = "";
    foreach (t[i]) str = {str, $sformatf(" %0d", t[i])};
    return str;
  endfunction

  initial begin
    q = '{7, 8};
    d = '{5, 6, 9};
    aa[3] = 4;
    #10 clk = 1;                 // 10: v = 0000, s = 0
    #5 clk = 0; v = 4'bxxxx; s = 1'bx;
    #5 clk = 1;                  // 20
    #5 clk = 0; v = 4'bzzzz; s = 1'bz;
    #5 clk = 1;                  // 30
    #5 clk = 0; v = 4'b0001; s = 1'b1;
    #5 clk = 1;                  // 40
    #5 clk = 0; v = 4'b1000;
    #5 clk = 1;                  // 50
    #5 clk = 0; v = 4'b0110;
    #5 clk = 1;                  // 60
    #5 clk = 0;
    #5 q.delete();               // 70, before the rising edge of aclk in the same time step
    d = new[1](d);
    aa.delete(3);
    aclk = 1;
    #5 aclk = 0;                 // 75
    q = '{1, 2};
    d = '{0, 0, 3};
    aa[3] = 1;
    #5 aclk = 1;                 // 80
    #5 aclk = 0;
    $display("a_vec: passes%s, failures%s", times(pv), times(fv));
    $display("a_bit: passes%s, failures%s", times(ps), times(fs));
    $display("a_q: passes%s, failures%s", times(pq), times(fq));
    $display("a_d: passes%s, failures%s", times(pd), times(fd));
    $display("a_aa: passes%s, failures%s", times(pa), times(fa));
    $finish;
  end
endmodule
