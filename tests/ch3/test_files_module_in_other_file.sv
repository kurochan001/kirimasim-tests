/*
:name: test_files_module_in_other_file
:description: A module declared in another source file of the same compilation is found when the test instantiates it, with its parameter overridden (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 3.13 23.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: files_module_in_other_file_adder.sv
:expected_stdout: @test_files_module_in_other_file.expected
*/
// IEEE 1800-2023 §3.12.1, §3.13: module names belong to the definitions name
// space, which is shared by all the files of a compilation, so a module
// declared in another source file can be instantiated whether the files form
// one compilation unit or several. The adder comes from the file that :files:
// names, and the instance sets its width to 4.

module test_files_module_in_other_file;
  logic [3:0] a = 4'd9, b = 4'd8;
  logic [4:0] sum;

  files_module_in_other_file_adder #(.W(4)) u(.a(a), .b(b), .sum(sum));

  initial #1 $display("%0d + %0d = %0d", a, b, sum);
endmodule
