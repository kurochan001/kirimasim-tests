/*
:name: test_resetall_restores_observed_default_timescale
:description: Resetall restores the default time unit and delay rounding observed before any directive
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.7 22.3 3.14.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_resetall_restores_observed_default_timescale.expected
:expected_exit: 0
*/
module before_any_timescale;
  initial begin
    #0.49 test_resetall_restores_observed_default_timescale.record(0, 0);
    #0.51 test_resetall_restores_observed_default_timescale.record(0, 1);
    #1 test_resetall_restores_observed_default_timescale.record(0, 2);
  end
endmodule

`timescale 100s/100s
`resetall
module after_coarse_timescale;
  initial begin
    #0.49 test_resetall_restores_observed_default_timescale.record(1, 0);
    #0.51 test_resetall_restores_observed_default_timescale.record(1, 1);
    #1 test_resetall_restores_observed_default_timescale.record(1, 2);
  end
endmodule

`timescale 1fs/1fs
`resetall
module after_fine_timescale;
  initial begin
    #0.49 test_resetall_restores_observed_default_timescale.record(2, 0);
    #0.51 test_resetall_restores_observed_default_timescale.record(2, 1);
    #1 test_resetall_restores_observed_default_timescale.record(2, 2);
  end
endmodule

module test_resetall_restores_observed_default_timescale;
  before_any_timescale first();
  after_coarse_timescale after_coarse();
  after_fine_timescale after_fine();

  realtime ticks [3][3];
  bit [8:0] reported;

  task automatic record(input int probe, input int step);
    ticks[probe][step] = $realtime;
    reported[3 * probe + step] = 1;
  endtask

  initial begin
    wait (&reported);
    $display("after coarse matches=%0d after fine matches=%0d default advances=%0d",
             ticks[0][0] == ticks[1][0] && ticks[0][1] == ticks[1][1] && ticks[0][2] == ticks[1][2],
             ticks[0][0] == ticks[2][0] && ticks[0][1] == ticks[2][1] && ticks[0][2] == ticks[2][2],
             ticks[0][2] > ticks[0][1]);
    $finish(0);
  end
endmodule
