/*
:name: test_23_extra_instance_packed_bits
:description: A packed connection to an array of instances gives each instance a part-select, so too few or too many total bits for all instances is an error (IEEE 1800-2023 Section 23.3.3.5)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the 16-bit connection s cannot supply the 32 bits that the four instances of ip, each with an 8-bit port, require
:expected_stderr_regex: test_23_extra_instance_packed_bits\.sv:30:
*/
// IEEE 1800-2023 §23.3.3.5: if the port connection is a packed array, each
// instance gets a part-select of the connection, starting with the rightmost
// part-select and iterating through the rightmost dimension first. Too many
// or too few bits to connect all the instances shall be considered an error.
// The instance array ip u[3:0] has four instances, each with the 8-bit
// input i, so the connection must carry 32 bits. The connection s has 16
// bits, which is too few, and the design is illegal. The clause does not
// require a particular diagnostic, only that this connection be an error at
// elaboration.
// Both simulators report the width mismatch at this line.

module ip(input logic [7:0] i);
endmodule

module test_23_extra_instance_packed_bits;
  logic [15:0] s = 16'h1234;
  ip u[3:0](s);
endmodule
