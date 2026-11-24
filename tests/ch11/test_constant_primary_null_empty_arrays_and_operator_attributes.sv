/*
:name: test_constant_primary_null_empty_arrays_and_operator_attributes
:description: Constant expressions accept a null handle, empty unpacked arrays and attributed operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 A.8.4 10.10 8.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_primary_null_empty_arrays_and_operator_attributes.expected
*/
class grammar_marker;
endclass

module test_constant_primary_null_empty_arrays_and_operator_attributes;
  localparam grammar_marker NULL_MARKER = null;
  localparam int EMPTY_QUEUE[$] = {};
  localparam int EMPTY_DYNAMIC[] = {};
  localparam string TITLE = "delta";
  localparam int OFFSET = - (* grammar_unary *) 4;
  localparam int VALUE = OFFSET < 0 ? (* grammar_conditional *) 1 + (* grammar_binary *) 3 : 0;

  initial begin
    $display("null=%b queue=%0d dynamic=%0d title=%s value=%0d",
             NULL_MARKER == null, EMPTY_QUEUE.size(), EMPTY_DYNAMIC.size(), TITLE, VALUE);
    $finish(0);
  end
endmodule
