/*
:name: test_user_net_timezero_order
:description: user net resolver histories when driver values change at time zero
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.3 6.6.7 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_user_net_timezero_order.expected
:vpi_c: @test_user_net_resolver_trace.c
*/
`timescale 1ns/1ns
module test_user_net_timezero_order;
  function automatic int resolve(input int drivers[]);
    int total = 100;
    foreach (drivers[i]) total += drivers[i];
    return total;
  endfunction

  nettype int biased_sum_net with resolve;
  int a, b;
  biased_sum_net resolved, driverless;
  assign resolved = a;
  assign resolved = b;

  initial begin
    a = 2;
    b = 3;
    // At the end of time zero, the undriven control must already have resolved.
    $strobe("tick=%0d driverless=%0d driven=%0d", $time, driverless, resolved);
    #1;
    $vt_check_resolver_history;
    $finish;
  end
endmodule
