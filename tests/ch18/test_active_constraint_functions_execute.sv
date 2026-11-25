/*
:name: test_active_constraint_functions_execute
:description: Active constraint functions execute without relying on call order
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_active_constraint_functions_execute
:expected_stdout: @test_active_constraint_functions_execute.expected
*/
`timescale 1ns/1ns
module test_active_constraint_functions_execute;
  class proposal;
    int base = 7;
    rand int left, right;

    function automatic int left_bound();
      return base + 4;
    endfunction

    function automatic int right_bound();
      return base * 3;
    endfunction

    constraint calls {
`ifdef REVERSE_CONSTRAINT_ORDER
      right == right_bound();
      left == left_bound();
`else
      left == left_bound();
      right == right_bound();
`endif
    }
    constraint domain { left inside {[10:12]}; right inside {[20:22]}; }
  endclass

  proposal candidate;

  initial begin
    candidate = new;
    if ($test$plusargs("direct")) begin
      $display("direct first: %0d %0d",
               candidate.left_bound(), candidate.right_bound());
      candidate.base = 8;
      $display("direct second: %0d %0d",
               candidate.left_bound(), candidate.right_bound());
    end else begin
      if ($test$plusargs("inactive"))
        candidate.calls.constraint_mode(0);
      if (!candidate.randomize())
        $fatal(1, "could not solve independent constraints");
      if ($test$plusargs("inactive"))
        $display("disabled in domain: %0d",
                 candidate.left inside {[10:12]} && candidate.right inside {[20:22]});
      else
        $display("enabled: %0d %0d", candidate.left, candidate.right);
    end
    $finish(0);
  end
endmodule
