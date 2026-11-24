/*
:name: test_process_final_class_enum_values_are_distinct_and_typed
:description: All built-in process states are distinct values of the process state enum
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7 G.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_final_class_enum_values_are_distinct_and_typed.expected
*/
module test_process_final_class_enum_values_are_distinct_and_typed;
  process owner;
  process::state expected_states[5];
  process::state observed_states[5];
  initial begin
    expected_states = '{process::FINISHED, process::RUNNING, process::WAITING,
                        process::SUSPENDED, process::KILLED};
    observed_states[0] = expected_states[0].first();
    for (int i = 1; i < 5; i++)
      observed_states[i] = observed_states[i - 1].next();
    owner = process::self();
    $display("self running=%0d enum matches=%0d",
             owner.status() == expected_states[1], expected_states == observed_states);
  end
endmodule
