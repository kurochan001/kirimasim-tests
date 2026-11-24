/*
:name: test_uwire_nested_slice_drivers_leave_no_overlap
:description: Two levels of port connections drive disjoint slices of an unresolved vector
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.2 23.3.3.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_uwire_nested_slice_drivers_leave_no_overlap.expected
*/
module two_bits(input wire [1:0] data, output wire [1:0] driven);
  assign driven = data;
endmodule

module uwire_middle(output uwire [3:0] pin);
  two_bits upper(2'b10, pin[3:2]);
  two_bits lower(2'b11, pin[1:0]);
endmodule

module test_uwire_nested_slice_drivers_leave_no_overlap;
  uwire [3:0] trace_pin;
  uwire_middle bridge(trace_pin);
  initial #1 $display("nonoverlapping drivers=%b", trace_pin);
endmodule
