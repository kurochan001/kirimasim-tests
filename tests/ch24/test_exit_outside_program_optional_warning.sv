/*
:name: test_exit_outside_program_optional_warning
:description: An optional outside-program exit leaves the module and program running
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exit_outside_program_optional_warning.expected
*/
`timescale 1ns/1ns
program later_exit;
  initial begin
    #3 $display("program exits at t=%0d", $time);
    $exit;
  end
endprogram

module test_exit_outside_program_optional_warning;
  later_exit other();
  initial begin
    #1;
    if ($test$plusargs("observe_module_exit")) begin
      $display("module calls exit at t=%0d", $time);
      $exit;
    end
    #1 $display("module continues at t=%0d", $time);
  end
endmodule
