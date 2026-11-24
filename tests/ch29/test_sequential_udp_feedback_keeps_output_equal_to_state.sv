/*
:name: test_sequential_udp_feedback_keeps_output_equal_to_state
:description: Sequential primitive feedback retains each of the three possible output values
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_sequential_udp_feedback_keeps_output_equal_to_state.expected
*/
primitive output_state_feedback(state, enable, select_hi, select_lo);
  output state;
  reg state;
  input enable, select_hi, select_lo;
  initial state = 1'b0;
  table
    0 ? ? : 0 : 0;
    0 ? ? : 1 : 1;
    0 ? ? : x : x;
    1 0 1 : ? : 1;
    1 1 0 : ? : 0;
    1 1 1 : ? : x;
  endtable
endprimitive

module test_sequential_udp_feedback_keeps_output_equal_to_state;
  logic enable;
  logic [1:0] command;
  wire state;
  output_state_feedback dut(state, enable, command[1], command[0]);

  task automatic apply_command(input logic [1:0] next_command);
    command = next_command;
    #1 enable = 1'b1;
    #1 enable = 1'b0;
    #1;
  endtask

  initial begin
    enable = 1'b0;
    apply_command(2'b10);
    $display("initial=%b", state);
    apply_command(2'b01);
    $display("set=%b", state);
    command = 2'b10;
    #1 $display("retain set=%b", state);
    apply_command(2'b11);
    $display("unknown=%b", state);
    command = 2'b01;
    #1 $display("retain unknown=%b", state);
    apply_command(2'b10);
    $display("clear=%b", state);
    command = 2'b01;
    #1 $display("retain clear=%b", state);
  end
endmodule
