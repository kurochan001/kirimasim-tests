/*
:name: test_vectored_bit_select_when_permitted
:description: vectored net bit select when the implementation permits it
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vectored_bit_select_when_permitted.expected
*/
module test_vectored_bit_select_when_permitted;
  wire vectored [6:4] bus;
  wire [6:4] control_bus;
  logic [6:4] stimulus = 3'b101;

  assign bus = stimulus;
  assign control_bus = stimulus;
  initial begin
    #1 $display("bit: %b control: %b", bus[5], control_bus[5]);
    stimulus = 3'b010;
    #1 $display("bit: %b control: %b", bus[5], control_bus[5]);
    $finish;
  end
endmodule
