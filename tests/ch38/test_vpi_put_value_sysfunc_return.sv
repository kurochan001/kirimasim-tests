/*
:name: test_vpi_put_value_sysfunc_return
:description: vpi_put_value with vpiNoDelay on the call of a user-defined system function sets its return value while its calltf runs, a call whose calltf puts no value returns 0, and a put on the call handle when the call is not active is ignored (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.37.1 38.36.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_sysfunc_return.c
:expected_stdout: @test_vpi_put_value_sysfunc_return.expected
*/
// IEEE 1800-2023 §38.34: the calltf routine of a user-defined system function
// returns its value by vpi_put_value with vpiNoDelay on the handle of the
// call; a put on that handle while the calltf routine is not active is
// ignored, and if the calltf routine puts no value, the function returns 0.
// $vt_value(n) returns n. $vt_nothing puts no value; at its first call it
// keeps the handle of the call and registers a cbAfterDelay callback of 2
// (38.36.2), which puts 55 on that handle when no call is active. The loop
// calls $vt_nothing from the same place at 0 and 5. Both are vpiIntFunc
// functions (38.37.1).

`timescale 1ns/1ns

module test_vpi_put_value_sysfunc_return;
  int r1, r2, r3, k;

  initial begin
    r1 = $vt_value(7);
    $display("%0t: $vt_value(7) returns %0d", $time, r1);
    for (k = 0; k < 2; k++) begin
      r2 = $vt_nothing();
      $display("%0t: $vt_nothing returns %0d", $time, r2);
      #5;
    end
    r3 = $vt_value(9);
    $display("%0t: $vt_value(9) returns %0d", $time, r3);
  end
endmodule
