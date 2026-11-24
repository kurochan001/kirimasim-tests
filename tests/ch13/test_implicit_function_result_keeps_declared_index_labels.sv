/*
:name: test_implicit_function_result_keeps_declared_index_labels
:description: A function call uses the declared ascending and descending ranges when its result is selected
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implicit_function_result_keeps_declared_index_labels.expected
*/
module test_implicit_function_result_keeps_declared_index_labels;
  typedef logic [11:8] descending_type;
  typedef logic [3:6] ascending_type;

  function automatic descending_type descending();
    return 4'b1010;
  endfunction

  function automatic ascending_type ascending();
    return 4'b0101;
  endfunction

  initial begin
    $display("descending bits=%b%b select=%b",
             descending()[11], descending()[8], descending()[10:9]);
    $display("ascending bits=%b%b select=%b",
             ascending()[3], ascending()[6], ascending()[4:5]);
  end
endmodule
