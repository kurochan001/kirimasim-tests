/*
:name: test_user_net_same_region_resolution
:description: user net resolver traces for driver changes in the same and in separate scheduling regions
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_user_net_same_region_resolution.expected
:vpi_c: @test_user_net_resolver_trace.c
*/
`timescale 1ns/1ns
module test_user_net_same_region_resolution;
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
    #1;
    $display("before: %0d", resolved);
    // Both assignments execute in the same active process without yielding.
    a = 7;
    b = 11;
    #1;
    $display("same region: %0d", resolved);
    // #0 separates the driver changes without advancing simulation time.
    a = 13;
    #0 b = 17;
    #1;
    $display("separate regions: %0d", resolved);
    $vt_check_resolver_history;
    $finish;
  end
endmodule
