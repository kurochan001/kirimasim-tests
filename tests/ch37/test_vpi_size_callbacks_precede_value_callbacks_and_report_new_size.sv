/*
:name: test_vpi_size_callbacks_precede_value_callbacks_and_report_new_size
:description: Size callbacks report growth and shrinkage and precede value callbacks on the same string
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.17 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_size_callbacks_precede_value_callbacks_and_report_new_size.expected
:vpi_c: @test_vpi_size_callbacks_precede_value_callbacks_and_report_new_size.c
*/
`timescale 1ns/1ns

module test_vpi_size_callbacks_precede_value_callbacks_and_report_new_size;
  int dynamic_values[];
  int queued[$];
  int indexed[int];
  string text = "";
  bit [3:0] fixed_value = 0;

  initial begin
    #1 $vt_watch_resize;
    #4;
    dynamic_values = new[3];
    queued.push_back(4);
    indexed[5] = 6;
    text = "abc";
    fixed_value = 3;

    #5;
    dynamic_values[0] = 7;
    queued[0] = 8;
    indexed[5] = 9;
    text = "dog";
    fixed_value = 5;

    #5;
    dynamic_values = new[1];
    queued.delete();
    indexed.delete(5);
    text = "z";
    fixed_value = 0;

    #5 $vt_report_resize;
  end
endmodule
