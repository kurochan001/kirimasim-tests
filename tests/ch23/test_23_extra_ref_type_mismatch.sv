/*
:name: test_23_extra_ref_type_mismatch
:description: A ref port shall be connected to an equivalent variable data type, so a ref int port connected to a 4-bit logic variable is an error (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ref port r of rf has the data type int and is connected to the 4-bit logic variable v, which is not an equivalent type
:expected_stderr_regex: test_23_extra_ref_type_mismatch\.sv:31:
*/
// IEEE 1800-2023 §23.3.3.2: a ref port shall be connected to an equivalent
// variable data type, and references to the port variable are treated as
// hierarchical references to the connected variable. The module rf declares
// the ref port r with the data type int. The instance connects it to v,
// whose data type logic [3:0] has a different width and signedness, so the
// connection is not equivalent and the design is illegal. The clause also
// says a ref port cannot be left unconnected; that part is not exercised
// here because Verilator 5.052 accepts an unconnected ref port.
// The 5.052 release of Verilator reports the type mismatch at the
// connection; Icarus Verilog 13.0 has no ref ports, so the rejection is
// recorded with Verilator alone.

module rf(ref int r);
endmodule

module test_23_extra_ref_type_mismatch;
  logic [3:0] v = 4'h3;
  rf u(.r(v));
endmodule
