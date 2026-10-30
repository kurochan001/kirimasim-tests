/*
:name: test_recursive_property_time_advance
:description: a named property may refer to itself when every recursive path advances time; an attempt of the recursive property reaches a match through the base case after one or more cycles (IEEE 1800-2023 Sections 16.12 and 16.12.17)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12 16.12.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_recursive_property_time_advance.expected
*/
// IEEE 1800-2023 §16.12.17: a property may depend on itself, and such a
// dependency is legal when a positive number of clock ticks lies on every
// cycle of the dependency graph. Here p_rec holds when a holds and, one tick
// later, b or p_rec holds, so the reference to p_rec in its own body follows
// the |=> of one tick. A property such as b or p_rec cannot follow ##1, whose
// operands are sequences (§16.7), so it follows 1'b1 |=> instead. a is high at
// the ticks at 5 and 15 and low at 25, and b is high at 25. The attempt that
// starts at 5 reaches b at 25 through one recursion, and the attempt that
// starts at 15 reaches b at 25 directly; both pass at 25. The attempt that
// starts at 25 has a false, so it fails at 25.

`timescale 1ns/1ns

module test_recursive_property_time_advance;
  logic clk = 0, a = 1, b = 0;
  int passes[$], fails[$];

  always #5 clk = ~clk;   // rising edges at 5, 15, 25

  property p_rec;
    a and (1'b1 |=> (b or p_rec));
  endproperty

  a_rec: assert property (@(posedge clk) p_rec)
    passes.push_back($time); else fails.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #20 a = 0; b = 1;
    #10;
    $display("recursive property passes:%s; failures:%s", times(passes), times(fails));
    $finish;
  end
endmodule
