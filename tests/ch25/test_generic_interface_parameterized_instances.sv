/*
:name: test_generic_interface_parameterized_instances
:description: A generic interface formal accepts two parameterizations and observes each actual width (IEEE 1800-2023 Section 25.3.3)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.3.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generic_interface_parameterized_instances.expected
*/
// IEEE 1800-2023 25.3.3: The generic port acquires the interface instance
// actual without fixing a particular interface specialization in its
// declaration.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

interface width_bus #(int W = 3); bit [W-1:0] data; endinterface
module width_reader(interface bus, output int width_value);
  assign width_value = $bits(bus.data);
endmodule
module test_generic_interface_parameterized_instances;
  width_bus #(3) a();
  width_bus #(7) b();
  wire signed [31:0] wa, wb;
  width_reader first(a, wa), second(b, wb);
  initial #1 $display("widths=%0d,%0d", wa, wb);
endmodule
