/*
:name: test_vpi_put_value_targets
:description: vpi_put_value sets a variable, a memory word, a named event, a net and a net bit, and returns the value of a user system function during its calltf, all with vpiNoDelay (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_targets.c
:expected_stdout: @test_vpi_put_value_targets.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value can be applied to nets, variables,
// variable selects, memory words, named events, system function calls,
// sequential UDPs and scheduled events, except for subelements of a net of a
// user-defined nettype. vpiNoDelay sets the object at once and ignores the
// time argument. A named event toggles and needs no value. A user system
// function call takes the value put during its calltf, and the value 0 if the
// routine puts none.
//
// At time 1 the application puts 11 into v, 22 and 33 into the two words of
// mem, toggles ev, puts a5 on the net n, sets bit 3 of the net nb, and lets
// $vt_value put 77 during its calltf. The design prints the results at time 2.

`timescale 1ns/1ns

module test_vpi_put_value_targets;
  int v;
  int mem [0:1];
  event ev;
  int ev_count;
  wire [7:0] n;
  wire [7:0] nb;
  reg [7:0] driver;
  reg [7:0] bits;

  assign n = driver;
  assign nb = bits;

  always @(ev) ev_count++;

  initial begin
    driver = 8'h00;
    bits = 8'h00;
    #1 $vt_put;
    #1 $display("v=%0d mem0=%0d mem1=%0d ev_count=%0d n=%h nb=%h fn=%0d",
                v, mem[0], mem[1], ev_count, n, nb, $vt_value);
    $finish;
  end
endmodule
