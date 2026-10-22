/*
:name: test_static_prefix_disjoint_field_drivers
:description: Separate constant fields of a struct can have independent continuous and procedural writers (IEEE 1800-2023 Section 11.5.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.3 6.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_prefix_disjoint_field_drivers.expected
*/
// IEEE 1800-2023 11.5.3 6.5: The longest static prefixes of two different
// fields are disjoint, so driving one continuously does not forbid a procedural
// write to the other.
// Oracle checks: Icarus Verilog 13.0 does not build this case.

module test_static_prefix_disjoint_field_drivers;
  typedef struct packed { bit [3:0] high; bit [3:0] low; } pair_t;
  pair_t value;
  bit [3:0] drive = 4'ha;
  assign value.high = drive;
  initial begin
    value.low = 4'h3;
    #1 $display("first=%h", value);
    drive = 4'h5; value.low = 4'hc;
    #1 $display("second=%h", value);
  end
endmodule
