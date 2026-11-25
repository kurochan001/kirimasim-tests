/*
:name: test_port_type_time_zero_events
:description: Observe startup changes for signed and unsigned net ports
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_type_time_zero_events.expected
*/
`timescale 1ns/1ns
module typed_receiver(input wire logic signed [3:0] converted, input wire logic [3:0] same_type);
  int converted_startup, same_type_startup;
  int converted_later, same_type_later;

  always @(converted)
    if ($time == 0) converted_startup++;
    else converted_later++;

  always @(same_type)
    if ($time == 0) same_type_startup++;
    else same_type_later++;

  initial begin
    #1 $display("settled values=%h,%h", converted, same_type);
    #2 $display("later signed=%0d unsigned=%0d events=%0d,%0d",
                converted, same_type, converted_later, same_type_later);
    if ($test$plusargs("observe_startup"))
      $display("startup events=%0d,%0d", converted_startup, same_type_startup);
    $finish(0);
  end
endmodule

module test_port_type_time_zero_events;
  logic [3:0] driver = 4'h6;
  wire logic [3:0] line = driver;
  typed_receiver receiver(line, line);

  initial #2 driver = 4'hd;
endmodule
