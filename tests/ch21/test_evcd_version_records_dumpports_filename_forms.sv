/*
:name: test_evcd_version_records_dumpports_filename_forms
:description: Extended VCD headers record scope and filename syntax for literal, variable and expression arguments
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.4.1 21.7.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: three header files recorded
*/

`timescale 1ns/1ns
module header_ports(input wire a, output wire y);
  assign y = ~a;
endmodule

module test_evcd_version_records_dumpports_filename_forms;
  bit data = 0;
  wire a, b, c;
  string file_name = "variable.evcd";
  string prefix = "expression";
  header_ports literal_target(data, a), variable_target(data, b), expression_target(data, c);

  initial begin
    $dumpports(literal_target, "literal.evcd");
    $dumpports(variable_target, file_name);
    $dumpports(expression_target, {prefix, ".evcd"});
    #1 data = 1;
    #2 $display("three header files recorded");
  end
endmodule
