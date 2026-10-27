/*
:name: test_23_extra_input_variable_write
:description: An input port of a variable data type receives a continuous assignment from the connection, so assigning the declared input variable inside the module is illegal (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the always procedure of iv assigns the input variable a, which an input port only reads
:expected_stderr_regex: test_23_extra_input_variable_write\.sv:28:
*/
// IEEE 1800-2023 §23.3.3.2: an input port can be connected to any expression
// of a compatible data type, and a continuous assignment is implied when a
// variable is connected to an input port declaration. Assignments to
// variables declared as input ports shall be illegal. The module iv
// declares a as input var logic [3:0] and its always procedure writes a
// before reading it, so the design is illegal. An unconnected input
// variable would instead keep the default initial value of its data type,
// which this test does not exercise.
// The 5.052 release of Verilator reports the assignment to the input
// variable; Icarus Verilog 13.0 accepts it, so the expected rejection is
// recorded with Verilator alone.

module iv(input var logic [3:0] a, output logic [3:0] y);
  always @* begin
    a = 4'h1;
    y = a;
  end
endmodule

module test_23_extra_input_variable_write;
  logic [3:0] p = 4'h5, q;
  iv u(.a(p), .y(q));
endmodule
