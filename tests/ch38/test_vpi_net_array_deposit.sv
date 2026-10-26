/*
:name: test_vpi_net_array_deposit
:description: a bulk put on one element of a static unpacked net array overrides the resolved value of that element only, and the element takes its driver's value again when the driver changes (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_array_deposit.c
:expected_stdout: @test_vpi_net_array_deposit.expected
*/
// IEEE 1800-2023 38.35: vpi_put_value_array writes elements of a static
// unpacked variable or net array without delay, like vpi_put_value with
// vpiNoDelay. An updated element of an array net overrides its resolved
// value on its own; the other elements keep the values of their drivers. The
// override lasts until a driver of that element changes, when the net is
// resolved again.
//
// wa[0] and wa[1] are driven by drv[0] and drv[1], which are 10 and 20. At
// time 1 the application puts aa on element 0 of the net array. The element
// is aa at time 2 while element 1 is still 20, and when drv[0] changes to 30
// at time 5, element 0 takes the resolved value 30 while element 1 keeps 20.

`timescale 1ns/1ns

module test_vpi_net_array_deposit;
  logic [7:0] drv[0:1];
  wire [7:0] wa[0:1];

  assign wa[0] = drv[0];
  assign wa[1] = drv[1];

  initial begin
    drv[0] = 8'h10;
    drv[1] = 8'h20;
    #2 $display("%0d: wa=%h,%h", $time, wa[0], wa[1]);
    #3 drv[0] = 8'h30;
    #1 $display("%0d: wa=%h,%h", $time, wa[0], wa[1]);
    $finish;
  end
endmodule
