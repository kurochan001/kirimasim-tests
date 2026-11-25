/*
:name: test_vectored_strength_when_permitted
:description: vectored net drive strength when the implementation permits it
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vectored_strength_when_permitted.expected
*/
module test_vectored_strength_when_permitted;
  logic [1:0] stimulus = 2'b01;
  wire vectored [1:0] bus;
  wire [1:0] control_bus;

  assign (pull0, pull1) bus = stimulus;
  assign (pull0, pull1) control_bus = stimulus;
  assign (weak0, weak1) bus = 2'b10;
  assign (weak0, weak1) control_bus = 2'b10;
  initial begin
    #1 $display("resolved: %b control: %b", bus, control_bus);
    stimulus = 2'b00;
    #1 $display("resolved: %b control: %b", bus, control_bus);
    $finish;
  end
endmodule
