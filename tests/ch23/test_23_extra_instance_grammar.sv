/*
:name: test_23_extra_instance_grammar
:description: A module instantiation names the module, gives an optional named parameter value assignment, and lists two named instances and an instance array, each with its mandatory connection parentheses (IEEE 1800-2023 Section 23.3.2)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.2 23.3.3.5 A.4.1.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_instance_grammar.expected
*/
// IEEE 1800-2023 §23.3.2 and A.4.1.1: a module_instantiation is the module
// identifier, an optional parameter_value_assignment, and one or more
// hierarchical_instance items separated by commas. A hierarchical_instance
// is a name_of_instance, which is an instance identifier followed by zero or
// more unpacked dimensions, and then parentheses with the port connections;
// the parentheses are required even for a module without ports. One
// parameter_value_assignment applies to every instance of the statement.
// The statement ig #(.W(2)) i0 (...) , i1 (...) gives the named parameter W
// to both instances: i0 drives y0 with a0, i1 leaves its output
// unconnected. The second statement ig arr [1:0] (...) has one unpacked
// dimension and an ordered parameter value assignment would be unnecessary
// because W keeps its default; every element of the array receives a0.
// Only y0 is printed, so the result is the same whether the unconnected
// output and the array elements are visible.

module ig #(parameter int W = 2) (
    input logic [W-1:0] a,
    output logic [W-1:0] y);
  assign y = a;
endmodule

module test_23_extra_instance_grammar;
  logic [1:0] a0 = 2'd3;
  wire [1:0] y0;

  ig #(.W(2)) i0 (.a(a0), .y(y0)), i1 (.a(2'd2), .y());
  ig arr [1:0] (.a(a0), .y());

  initial #1 $display("y0=%0d", y0);
endmodule
