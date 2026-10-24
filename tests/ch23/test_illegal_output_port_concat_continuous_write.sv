/*
:name: test_illegal_output_port_concat_continuous_write
:description: A variable in a concatenation connected to a variable output port of an instance cannot also be the target of a continuous assignment (IEEE 1800-2023 Section 23.3.3.2)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the variable lo, part of the concatenation connected to the output port o of u, is also the target of a continuous assignment
:expected_stderr_regex: test_illegal_output_port_concat_continuous_write\.sv:(29|30):
*/
// IEEE 1800-2023 §23.3.3.2: the connection of a variable output port to a
// variable or a concatenation of variables implies a continuous assignment to
// them, and a further procedural or continuous assignment to such a variable
// is illegal. The instance ok connects r, which nothing else assigns; u
// connects {hi, lo}, and lo is also driven by an assign statement.
// Oracle checks: the 5.052 release of Verilator accepts the design.

module occ_child(output logic [1:0] o);
  assign o = 2'b10;
endmodule

module test_illegal_output_port_concat_continuous_write;
  logic hi, lo;
  logic [1:0] r;
  occ_child ok (.o(r));
  occ_child u (.o({hi, lo}));   // the error can also be reported here
  assign lo = 1'b1;   // illegal: lo is driven by the output port of u
endmodule
