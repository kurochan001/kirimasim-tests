/*
:name: test_uwire_allows_disjoint_slice_drivers_across_nested_ports
:description: Different bits of a uwire may be driven through different chains of module ports
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.6 6.6.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_uwire_allows_disjoint_slice_drivers_across_nested_ports.expected
*/
module uwire_port_leaf(input wire [1:0] source, output uwire [1:0] result);
  assign result = source;
endmodule
module uwire_port_branch(input wire [1:0] source, output uwire [1:0] result);
  uwire_port_leaf leaf(source, result);
endmodule
module test_uwire_allows_disjoint_slice_drivers_across_nested_ports;
  logic [1:0] a, b;
  uwire [3:0] link;
  uwire_port_branch upper(a, link[3:2]);
  uwire_port_branch lower(b, link[1:0]);

  initial begin
    a = 2'b10;
    b = 2'b01;
    #1 $display("first=%b", link);
    a = 2'b01;
    b = 2'b11;
    #1 $display("second=%b", link);
  end
endmodule
