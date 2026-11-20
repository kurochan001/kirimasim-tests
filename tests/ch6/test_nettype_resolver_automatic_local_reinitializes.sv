/*
:name: test_nettype_resolver_automatic_local_reinitializes
:description: Each evaluation of an automatic nettype resolver reinitializes its local accumulator, so decreasing a driver decreases the resolved value independently of the evaluation count (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 6.21 13.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_resolver_automatic_local_reinitializes.expected
*/
// A resolution function is automatic or otherwise retains no state between
// evaluations, and has no side effects (6.6.7). The automatic local total
// is initialized to 100 on every entry (6.21, 13.4.2). Only the local is
// modified; the driver array and all objects outside the function are read.
// The resolver therefore always returns 100 plus its two driver values.
// No number or order of resolver calls is assumed. In particular, a local
// incorrectly retained across calls cannot produce the decrease 110 to
// 104: all contributions are positive, so a retained total only grows.

module test_nettype_resolver_automatic_local_reinitializes;
  function automatic int resolve(input int drivers[]);
    int total = 100;
    foreach (drivers[i]) total += drivers[i];
    return total;
  endfunction

  nettype int biased_sum_net with resolve;
  int a = 2, b = 3;
  biased_sum_net resolved;
  assign resolved = a;
  assign resolved = b;

  initial begin
    #1 $display("a=%0d b=%0d resolved=%0d", a, b, resolved);
    a = 7;
    #1 $display("a=%0d b=%0d resolved=%0d", a, b, resolved);
    a = 1;
    #1 $display("a=%0d b=%0d resolved=%0d", a, b, resolved);
  end
endmodule
