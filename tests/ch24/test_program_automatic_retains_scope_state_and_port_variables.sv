/*
:name: test_program_automatic_retains_scope_state_and_port_variables
:description: Automatic program subroutines retain per-instance program-scope state and drive program nets and variable ports
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 6.21
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_automatic_retains_scope_state_and_port_variables.expected
*/
program automatic program_signal_source #(parameter int BASE = 0)(output int result);
  typedef logic [7:0] local_word_t;
  local_word_t total = BASE;
  wire [15:0] doubled = total * 2;

  function int step(int increment);
    int per_call = 0;
    ++per_call;
    total += increment;
    return per_call;
  endfunction

  initial begin
    int first, second;
    first = step(3);
    #1 second = step(4);
    result = total + first + second;
    #5;
  end
endprogram

program program_signal_peer;
  typedef logic [4:0] local_word_t;
  local_word_t local_sample;

  initial begin
    #2;
    $display("peer type width=%0d", $bits(local_sample));
    $display("first state=%0d bits=%0d net=%0d port=%0d",
             test_program_automatic_retains_scope_state_and_port_variables.first.total,
             $bits(test_program_automatic_retains_scope_state_and_port_variables.first.total),
             test_program_automatic_retains_scope_state_and_port_variables.first.doubled,
             test_program_automatic_retains_scope_state_and_port_variables.first.result);
    $display("second state=%0d net=%0d port=%0d",
             test_program_automatic_retains_scope_state_and_port_variables.second.total,
             test_program_automatic_retains_scope_state_and_port_variables.second.doubled,
             test_program_automatic_retains_scope_state_and_port_variables.second.result);
  end
endprogram

module test_program_automatic_retains_scope_state_and_port_variables;
  wire [31:0] first_output, second_output;
  program_signal_source #(.BASE(10)) first(first_output);
  program_signal_source #(.BASE(20)) second(second_output);
  program_signal_peer peer();
  initial #3 $display("connected ports=%0d %0d", first_output, second_output);
endmodule
