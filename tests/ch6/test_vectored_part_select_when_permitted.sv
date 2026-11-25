/*
:name: test_vectored_part_select_when_permitted
:description: vectored net part select when the implementation permits it
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vectored_part_select_when_permitted.expected
*/
module test_vectored_part_select_when_permitted;
  wire vectored [4:6] bus;
  wire [4:6] control_bus;
  logic [4:6] stimulus = 3'b101;

  assign bus = stimulus;
  assign control_bus = stimulus;
  initial begin
    #1 $display("part: %b control: %b", bus[4:5], control_bus[4:5]);
    stimulus = 3'b011;
    #1 $display("part: %b control: %b", bus[4:5], control_bus[4:5]);
    $finish;
  end
endmodule
