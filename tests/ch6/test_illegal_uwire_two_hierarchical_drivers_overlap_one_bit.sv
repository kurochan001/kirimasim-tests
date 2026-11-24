/*
:name: test_illegal_uwire_two_hierarchical_drivers_overlap_one_bit
:description: Two hierarchical output drivers overlap only on the middle bit of an unresolved net
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.2 23.3.3.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two submodule output drivers both reach bit one of the same unresolved net
:expected_stderr_regex: test_illegal_uwire_two_hierarchical_drivers_overlap_one_bit\.sv:(?:19|20|24|25):(?:\d+:)?[^\n]*(?i:(?:uwire|unresolved|single.driver)[^\n]*(?:driver|driv)|(?:multiple|second)[^\n]*(?:driver|driv))
*/
module two_bits(input wire [1:0] data, output wire [1:0] driven);
  assign driven = data;
endmodule

module uwire_middle(output uwire [2:0] pin);
  two_bits upper(2'b10, pin[2:1]);
  two_bits lower(2'b11, pin[1:0]);
endmodule

module test_illegal_uwire_two_hierarchical_drivers_overlap_one_bit;
  uwire [2:0] trace_pin;
  uwire_middle bridge(trace_pin);
  initial #1 $display("unexpected multiple drivers=%b", trace_pin);
endmodule
