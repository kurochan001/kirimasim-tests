/*
:name: test_vector_net_scalared
:description: A vector net declared scalared allows bit-selects and part-selects, so continuous assignments can drive single bits of it while the others keep the value of the net type (IEEE 1800-2023 Section 6.9.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.9.2 6.6.5 10.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_vector_net_scalared.expected
*/
// IEEE 1800-2023 §6.9.2: with the keyword scalared, bit-selects and
// part-selects of a vector net are permitted. bus is a tri1 net (6.6.5), so its
// undriven bits are 1; continuous assignments (10.3.2) drive bit 0 and bits
// 4:3 of it with 0.

module test_vector_net_scalared;
  tri1 scalared [7:0] bus;

  assign bus[0] = 1'b0;
  assign bus[4:3] = 2'b00;

  initial #1 $display("bus=%b", bus);
endmodule
