/*
:name: test_delay_x_z_value_is_zero_delay
:description: a delay control whose expression is all x or all z waits as #0 does, without advancing time (IEEE 1800-2023 Section 9.4.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.1 4.4.2.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_delay_x_z_value_is_zero_delay.expected
*/
// IEEE 1800-2023 §9.4.1: a delay expression that evaluates to an unknown or
// high-impedance value is interpreted as a zero delay. A zero delay does not
// advance time; it suspends the process into the Inactive region (4.4.2.2),
// so every process that is already active in that time step runs before the
// delayed statement.
//
// At time 3 the main process and the process that sets flag both wake from
// #3, in an order the standard leaves open. The main process then executes
// #dx (dx is all x): read as #0, it lets the other process set flag first,
// so it prints time 3 and flag 1 whichever process ran first. The same holds
// for #dz (all z). A plain #4 follows as a contrast that does advance time.

`timescale 1ns/1ns
module test_delay_x_z_value_is_zero_delay;
  logic [7:0] dx = 8'bxxxx_xxxx;
  logic [7:0] dz = 8'bzzzz_zzzz;
  int flag = 0, flag2 = 0;

  initial #3 flag = 1;
  initial #7 flag2 = 1;

  initial begin
    #3;
    #dx $display("after #dx: t=%0t flag=%0d", $time, flag);
    #dz $display("after #dz: t=%0t flag=%0d", $time, flag);
    #4;
    #dz $display("after #4 then #dz: t=%0t flag2=%0d", $time, flag2);
  end
endmodule
