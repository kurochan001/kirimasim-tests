/*
:name: test_unit_time_default_is_independent_of_timescale_directive
:description: A timescale directive leaves the observed compilation-unit time default unchanged
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 22.7
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_time_default_is_independent_of_timescale_directive.expected
:expected_exit: 0
*/
task automatic unit_delay_before_directive();
  #1 test_unit_time_default_is_independent_of_timescale_directive.record(0);
endtask

module default_unit_reference;
  initial #1 test_unit_time_default_is_independent_of_timescale_directive.record(1);
endmodule

`timescale 100s/100s
task automatic unit_delay_after_coarse_directive();
  #1 test_unit_time_default_is_independent_of_timescale_directive.record(2);
endtask

`timescale 1fs/1fs
task automatic unit_delay_after_fine_directive();
  #1 test_unit_time_default_is_independent_of_timescale_directive.record(3);
endtask

`resetall
module test_unit_time_default_is_independent_of_timescale_directive;
  default_unit_reference default_probe();
  realtime ticks [4];
  bit [3:0] reported;

  task automatic record(input int probe);
    ticks[probe] = $realtime;
    reported[probe] = 1;
  endtask

  initial begin
    fork
      unit_delay_before_directive();
      unit_delay_after_coarse_directive();
      unit_delay_after_fine_directive();
    join_none
    wait (&reported);
    $display("unit matches default=%0d after coarse matches=%0d after fine matches=%0d",
             ticks[0] == ticks[1] && ticks[1] > 0,
             ticks[0] == ticks[2],
             ticks[0] == ticks[3]);
    $finish(0);
  end
endmodule
