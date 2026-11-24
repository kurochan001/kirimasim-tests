/*
:name: test_vpi_reset_defers_until_return_and_restores_initial_state
:description: VPI reset runs after its requesting routine returns and restores the time-zero state
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.4 38.36.3 38.14 38.33 D.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_reset_defers_until_return_and_restores_initial_state.expected
:expected_exit: 0
:vpi_c: @test_vpi_reset_defers_until_return_and_restores_initial_state.c
*/
`timescale 1ns/1ns
module test_vpi_reset_defers_until_return_and_restores_initial_state;
  int state = 19;
  wire [7:0] mirrored_state = 8'(state);

  task observe_link(input int stage);
    $probe_reset_userdata(stage);
  endtask

  initial begin
    if ($reset_count == 0) begin
      observe_link(0);
      #1 observe_link(1);
      #5;
      state = 71;
      #1 $request_vpi_reset;
      $display("unexpected return to the original initial block");
    end
    else begin
      $display("initial t=%0d state=%0d reset count=%0d reset value=%0d",
               $time, state, $reset_count, $reset_value);
      observe_link(2);
      #1 observe_link(3);
      $finish(0);
    end
  end

  initial #20 $finish(1);
endmodule
