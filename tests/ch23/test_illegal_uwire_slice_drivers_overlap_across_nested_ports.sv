/*
:name: test_illegal_uwire_slice_drivers_overlap_across_nested_ports
:description: Overlapping bits of a uwire cannot be driven through two chains of module ports
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.6 6.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the two instance outputs both drive bit two of the same unresolved wire
:expected_stderr_regex: test_illegal_uwire_slice_drivers_overlap_across_nested_ports\.sv:24:(?:\d+:)?[^\n]*(?i:\b(?:uwire|unresolved)\b[^\n]*(?:multiple|more than one|2)[^\n]*driv|(?:multiple|more than one|2)[^\n]*driv[^\n]*(?:uwire|unresolved|link))
*/
module uwire_port_leaf(input wire [1:0] source, output uwire [1:0] result);
  assign result = source;
endmodule
module uwire_port_branch(input wire [1:0] source, output uwire [1:0] result);
  uwire_port_leaf leaf(source, result);
endmodule
module test_illegal_uwire_slice_drivers_overlap_across_nested_ports;
  logic [1:0] a, b;
  uwire [3:0] link;
  uwire_port_branch upper(a, link[3:2]);
  uwire_port_branch lower(b, link[2:1]); // illegal

  initial begin
    a = 2'b10;
    b = 2'b01;
    #1 $display("first=%b", link);
    a = 2'b01;
    b = 2'b11;
    #1 $display("second=%b", link);
  end
endmodule
