/*
:name: test_function_disable_caller_observation
:description: A function can disable its own block and observe a caller disable in separate builds
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_disable_caller_observation.expected
*/
module test_function_disable_caller_observation;
  function automatic int choose_value();
    begin : early_end
      choose_value = 23;
      disable early_end;
      choose_value = 99;
    end
`ifdef OBSERVE_CALLER_TASK
    $display("before disabling caller task");
    disable caller;
`elsif OBSERVE_CALLER_BLOCK
    $display("before disabling caller block");
    disable test_function_disable_caller_observation.caller_block;
`endif
  endfunction

  task caller;
    int answer;
    $display("caller task begins");
    answer = choose_value();
    $display("caller task received=%0d", answer);
  endtask

  initial begin
    begin : caller_block
`ifdef OBSERVE_CALLER_BLOCK
      int answer;
      $display("caller block begins");
      answer = choose_value();
      $display("caller block received=%0d", answer);
`else
      caller();
`endif
    end
    $display("caller block ended");
    $finish(0);
  end
endmodule
