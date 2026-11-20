/*
:name: test_vpi_bulk_propagation_suppressed_then_restored
:description: A bulk array put with vpiPropagateOff changes the stored elements without notifying their fanouts, and a later ordinary update restores propagation (IEEE 1800-2023 Section 38.35)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.35
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_bulk_propagation_suppressed_then_restored.c
:expected_stdout: @test_vpi_bulk_propagation_suppressed_then_restored.expected
*/
// 38.35 B024 inhibits array fanout notification with vpiPropagateOff.
// At 10 the application changes a from {10,20} to {31,47} with that flag.
// The stored elements change, but the event-controlled observer processes
// are not notified. At 11 their captured values retain
// 10,20 and their event counts remain zero. The unrelated array is a
// target-identity control and retains 100,200 throughout.
// At 20 an ordinary no-delay bulk put changes both elements to 32,48.
// This supplies the subsequent update needed to resume propagation.
// By 21 both observers see 32,48, with one event on each observed element.
// The observations occur a full time step after each update;
// no relative order among independent fanouts is assumed.
// Icarus Verilog 13.0 lacks the bulk-array VPI declarations. The 5.054
// release of the Verilator simulator rejects vpiPropagateOff as an
// unsupported flag. Neither unsupported result is an oracle.

`timescale 1ns/1ns

module test_vpi_bulk_propagation_suppressed_then_restored;
  int a[0:1];
  int unrelated[0:1];
  int seen0 = 0, seen1 = 0;
  int events0 = 0, events1 = 0;

  always @(a[0]) begin
    seen0 = a[0];
    events0++;
  end
  always @(a[1]) begin
    seen1 = a[1];
    events1++;
  end

  task automatic show(input string stage);
    $display("%s a=%0d,%0d seen=%0d,%0d events=%0d,%0d other=%0d,%0d",
             stage, a[0], a[1], seen0, seen1,
             events0, events1, unrelated[0], unrelated[1]);
  endtask

  initial begin
    #1;
    a[0] = 10;
    a[1] = 20;
    unrelated[0] = 100;
    unrelated[1] = 200;
    #1 events0 = 0; events1 = 0;
    #9 show("suppressed");
    #10 show("restored");
    $finish;
  end
endmodule
