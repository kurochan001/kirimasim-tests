/*
:name: test_untyped_formal_arguments
:description: Sequences, properties and lets declare formal arguments as untyped, also as their first formal, and take expressions as actuals (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.12 11.12 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_untyped_formal_arguments.expected
*/
// IEEE 1800-2023 §16.8, §16.12, §11.12: a formal argument of a sequence, a
// property or a let can be declared with the keyword untyped, including the
// first one; the actual argument is substituted as an expression. s_pair(a,
// b) matches when b follows a by one tick, at 25 here; p_follow(a, b) fails
// when a, at 45, is not followed by b at 55; and both(1, 0) is 0.

module test_untyped_formal_arguments;
  logic clk = 0, a = 0, b = 0;
  int n_match = 0, fails = 0;
  int match_at = -1, fail_at = -1;

  always #5 clk = ~clk;

  sequence s_pair(untyped x, untyped y);
    x ##1 y;
  endsequence

  property p_follow(untyped trig, untyped resp);
    @(posedge clk) trig |=> resp;
  endproperty

  let both(untyped p, untyped q) = p && q;

  c1: cover sequence (@(posedge clk) s_pair(a, b)) begin
    n_match++;
    match_at = $time;
  end

  a1: assert property (p_follow(a, b)) else begin
    fails++;
    fail_at = $time;
  end

  initial begin
    #10 a = 1;
    #10 a = 0;
    b = 1;
    #10 b = 0;
    #10 a = 1;
    #10 a = 0;
    #20;
    $display("s_pair: %0d match at %0d, p_follow: %0d failure at %0d, both(1, 0) = %0d",
             n_match, match_at, fails, fail_at, both(1'b1, 1'b0));
    $finish;
  end
endmodule
