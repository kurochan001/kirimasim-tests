/*
:name: test_scope_randomize_keeps_selected_variables_after_failure
:description: An unsuccessful scope randomize call preserves both selected variables and unselected state
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.12 18.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_randomize_keeps_selected_variables_after_failure.expected
*/
module test_scope_randomize_keeps_selected_variables_after_failure;
  int first_value, second_value;
  int untouched = -23;
  int result;

  initial begin
    result = std::randomize(first_value, second_value) with {
      first_value == -9;
      second_value == 42;
    };
    $display("success=%0d values=%0d,%0d state=%0d",
             result, first_value, second_value, untouched);

    result = std::randomize(first_value, second_value) with {
      first_value == 7;
      second_value > 100;
      second_value < 2;
    };
    $display("failure=%0d values=%0d,%0d state=%0d",
             result, first_value, second_value, untouched);
  end
endmodule
