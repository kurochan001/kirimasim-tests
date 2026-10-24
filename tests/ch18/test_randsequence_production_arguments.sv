/*
:name: test_randsequence_production_arguments
:description: Productions take formal arguments like a task, with defaults, and are called like a task; the arguments are visible in every rule, weight, repeat count, if condition and code block of the production and can be passed down (IEEE 1800-2023 Section 18.17.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.17.7 18.17.1 18.17.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randsequence_production_arguments.expected
*/
// IEEE 1800-2023 §18.17.7: a production may declare formal arguments like a
// task prototype, and it is called with the syntax of a task call, so an
// argument with a default may be left out. A production is a scope that
// covers all its rules and code blocks, so its arguments can be used
// throughout: here in code blocks, in the weights of its rules, as actual
// arguments of the productions it generates, and in a repeat count (18.17.4).
//
// §18.17.1: the probability of a rule is proportional to its weight, so a rule
// of weight 0 is never chosen while the other rule has weight 1. show picks
// its first rule when n > 0 and its second when n == 0. show("b") uses the
// default 1 for n. body generates put n times and then appends n. So:
// show("a", 2) gives <aaa2>, show("b") gives <bb1> and show("c", 0) gives (c).

module test_randsequence_production_arguments;
  string log = "";

  initial begin
    randsequence (main)
      main : show("a", 2) show("b") show("c", 0);
      show (string s, int n = 1)
           : { log = {log, "<", s}; } body(s, n) { log = {log, $sformatf("%0d>", n)}; }
               := (n > 0)
           | { log = {log, "(", s, ")"}; } := (n == 0);
      body (string t, int k) : repeat (k) put(t);
      put (string u) : { log = {log, u}; };
    endsequence
    $display("log=%s", log);
  end
endmodule
