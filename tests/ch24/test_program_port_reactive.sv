/*
:name: test_program_port_reactive
:description: without clocking blocks, a continuous assignment in a program drives its output port in the reactive region set, so a module process sensitive to the connected net runs after the active region set has finished with the input change, including its nonblocking assignments (IEEE 1800-2023 Section 24.3.2)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3.2 24.3.1 4.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_port_reactive.expected
*/
// IEEE 1800-2023 §24.3.2: the code of a program, including its continuous
// assignments, runs in the reactive region set, so the nets on the other side
// of its output ports are driven there; module processes sensitive to them
// are woken in the active region set, in the next iteration of the scheduling
// loop (§4.5). When r rises at 10, the module sees dw1 change and its
// nonblocking assignment to q update in the active region set, and only then
// does the program's assign copy pw1 to pw2, and the module sees dw2 change.

`timescale 1ns/1ns

program pass_through(output wire pw2, input wire pw1);
  assign pw2 = pw1;
endprogram

module test_program_port_reactive;
  logic r = 0, q = 0;
  wire dw1, dw2;

  assign dw1 = r;
  pass_through p(dw2, dw1);

  always @(dw1) if ($time > 0) begin
    $display("%0d: dw1 = %b", $time, dw1);
    q <= dw1;
  end
  always @(q) if ($time > 0) $display("%0d: q = %b", $time, q);
  always @(dw2) if ($time > 0) $display("%0d: dw2 = %b", $time, dw2);

  initial begin
    #10 r = 1;
    #10 r = 0;
  end
endmodule
