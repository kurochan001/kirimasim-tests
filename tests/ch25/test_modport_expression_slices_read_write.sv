/*
:name: test_modport_expression_slices_read_write
:description: A modport expression can expose separate renamed input and output slices of one interface vector (IEEE 1800-2023 Section 25.5.4)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.5.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_modport_expression_slices_read_write.expected
*/
// IEEE 1800-2023 25.5.4: A write through the output expression updates only its
// slice while a read of the input expression observes the other slice.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

interface split_bus;
  logic [7:0] data;
  modport split(output .low(data[3:0]), input .high(data[7:4]));
endinterface
module split_user(split_bus.split bus, output bit [3:0] observed);
  assign observed = bus.high;
  initial #1 bus.low = 4'h6;
endmodule
module test_modport_expression_slices_read_write;
  split_bus bus();
  wire [3:0] observed;
  split_user user_instance(bus, observed);
  initial begin
    bus.data[7:4] = 4'ha;
    #2 $display("data=%h observed=%h", bus.data, observed);
  end
endmodule
