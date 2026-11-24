/*
:name: test_illegal_data_address_operator_does_not_create_object_handle
:description: A reduction of a SystemVerilog variable cannot be used as a class object handle
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: unary ampersand is an integral reduction and does not convert data storage to a class handle
:expected_stderr_regex: test_illegal_data_address_operator_does_not_create_object_handle\.sv:24:(?:\d+:)?[^\n]*(?i:class|object|non-class|convert|BadAssignment|logic[^\n]*assigned to type[^\n]*entry)
*/
module test_illegal_data_address_operator_does_not_create_object_handle;
  class entry;
    int value;
  endclass
  logic [3:0] source = 4'hf;
  entry object;
  bit reduction_result;

  initial begin
    reduction_result = &source;
    object = &source;
    $display("unexpected object with reduction=%0b", reduction_result);
  end
endmodule
