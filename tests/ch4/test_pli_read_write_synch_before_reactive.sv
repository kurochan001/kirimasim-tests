/*
:name: test_pli_read_write_synch_before_reactive
:description: A cbReadWriteSynch callback runs in the Pre-NBA or the Post-NBA region, after the Active and Inactive events of its time step and before the program processes of the Reactive region, and a value it writes is processed in the same time step (IEEE 1800-2023 Section 4.10)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.10 4.4.3.3 4.4.3.4 38.36.2 24.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_pli_read_write_synch_before_reactive.c
:expected_stdout: @test_pli_read_write_synch_before_reactive.expected
*/
// IEEE 1800-2023 §4.10, Table 4-1: a cbReadWriteSynch callback runs in the
// Pre-NBA or the Post-NBA region; §38.36.2 lets it come before or after the
// nonblocking updates. Both regions follow the Active and Inactive regions
// and come before the reactive region set, and both let the callback write
// values and create events (§4.4.3.3, §4.4.3.4). §24.3.1: a program process
// runs in the Reactive region.
// $vt_register, called at 0, registers a cbReadWriteSynch and a
// cbReadOnlySynch callback for 10. At 10 the design sets a = 1, a2 = 1 after
// #0 (in the Inactive region) and b <= 1, and the update of b wakes a program
// process that sets p = 2. The cbReadWriteSynch callback sees a=1 and a2=1,
// and p still 0; it does not print b, which it may see before or after the
// update. It writes w = 3, which wakes a module process (c = w + 1) in the
// same time step, and the cbReadOnlySynch callback sees w=3, c=4, b=1, p=2.
// Icarus Verilog 13.0 runs the program process before the callback (p=2),
// as it does not schedule program code in the Reactive region, and the
// release 5.052 of Verilator does not support a program declared in a
// module.

`timescale 1ns/1ns

module test_pli_read_write_synch_before_reactive;
  int a = 0, a2 = 0, b = 0, p = 0, w = 0, c = 0;

  always @(w) c = w + 1;

  initial begin
    $vt_register;
    #10;
    a = 1;
    b <= 1;
    #0 a2 = 1;
    #10 $finish;
  end

  program prog;
    initial begin
      wait (b == 1);
      p = 2;
      #20;
    end
  endprogram
endmodule
