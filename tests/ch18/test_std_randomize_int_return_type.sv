/*
:name: test_std_randomize_int_return_type
:description: Scope randomize has signed int type for successful and unsuccessful calls
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.12 G.5
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_randomize_int_return_type.expected
*/
// Use type equivalence as well as the values of successful and failed calls.
module test_std_randomize_int_return_type;
  int value;
  int succeeded, failed;

  initial begin
    $display("int_result=%0d", type(std::randomize(value)) == type(int));
    succeeded = std::randomize(value) with {value == -17;};
    $display("success=%0d value=%0d", succeeded, value);
    failed = std::randomize(value) with {value == 2; value == 5;};
    $display("failure=%0d", failed);
  end
endmodule
