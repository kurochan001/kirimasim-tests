/*
:name: test_time_literals_preserve_fraction_until_used_as_delays
:description: Time literals retain their local fractional realtime value until a procedural delay applies the local precision
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 5.8 3.14.1 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literals_preserve_fraction_until_used_as_delays.expected
*/
package literal_time_scope;
  timeunit 10ns;
  timeprecision 1ns;
  localparam realtime BELOW = 490ps, ABOVE = 510ps;

  function automatic realtime amount(input bit upper);
    return upper ? ABOVE : BELOW;
  endfunction

  task automatic inline_delay(input bit upper);
    if (upper) #510ps;
    else #490ps;
  endtask

  task automatic value_delay(input bit upper);
    #(amount(upper));
  endtask
endpackage

module test_time_literals_preserve_fraction_until_used_as_delays;
  timeunit 1ps;
  timeprecision 1ps;
  import literal_time_scope::*;

  task automatic verify(input bit upper);
    time started, direct_ticks, computed_ticks;
    started = $time;
    inline_delay(upper);
    direct_ticks = $time - started;
    started = $time;
    value_delay(upper);
    computed_ticks = $time - started;
    $display("upper=%b value=%0.3f inline=%0d computed=%0d", upper,
             amount(upper), direct_ticks, computed_ticks);
  endtask

  initial begin
    #1;
    verify(0);
    verify(1);
    $finish(0);
  end
endmodule
