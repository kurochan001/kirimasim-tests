/*
:name: test_annex_tf_identifier_list
:description: Old style task declarations preserve individual port dimensions
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 A.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_annex_tf_identifier_list
:expected_stdout: @test_annex_tf_identifier_list.expected
*/
`timescale 1ns/1ns
module test_annex_tf_identifier_list;
  task automatic show_single;
    input int only_arg;
    $display("single=%0d", only_arg);
  endtask

  task automatic show_many;
    input logic [3:0] scalar, vector[2], matrix[2][2];
    $display("scalar=%0d vector=%0d,%0d matrix=%0d,%0d,%0d,%0d",
             scalar, vector[0], vector[1], matrix[0][0], matrix[0][1],
             matrix[1][0], matrix[1][1]);
  endtask

  initial begin
    show_single(19);
    show_many(4, '{1, 2}, '{'{3, 4}, '{5, 6}});
    $finish(0);
  end
endmodule
