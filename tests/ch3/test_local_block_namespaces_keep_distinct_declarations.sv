/*
:name: test_local_block_namespaces_keep_distinct_declarations
:description: Named blocks, unnamed blocks, subroutines, and specify blocks keep separate local declarations
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 6.20.5 30.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_block_namespaces_keep_distinct_declarations.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
module namespace_delay_cell(input wire source, output wire sink);
  assign sink = source;
  specify
    specparam path_delay = 3;
    (source => sink) = path_delay;
  endspecify
endmodule

module test_local_block_namespaces_keep_distinct_declarations;
  logic source = 0;
  wire sink;
  localparam int path_delay = 17;
  namespace_delay_cell transfer(source, sink);

  function automatic int local_function();
    int token = 23;
    return token;
  endfunction

  task automatic local_task(output int result);
    int token = 31;
    result = token;
  endtask

  initial begin : named_block
    int token;
    int task_result;
    token = 41;
    local_task(task_result);
    $display("named=%0d function=%0d task=%0d", token, local_function(), task_result);
    begin
      int token;
      token = 52;
      $display("unnamed=%0d", token);
    end
    $display("restored=%0d enclosing value=%0d", token, path_delay);
    #20;
    source = 1;
    #2;
    $display("before local delay=%0b", sink);
    #2;
    $display("after local delay=%0b", sink);
  end
endmodule
