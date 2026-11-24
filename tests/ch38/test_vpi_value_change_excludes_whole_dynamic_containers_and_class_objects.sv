/*
:name: test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects
:description: Value-change callbacks ignore whole dynamic containers and class objects while observing an integral variable and a class reference
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects.expected
:vpi_c: @test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects.c
*/
`timescale 1ns/1ns

module test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects;
  class item;
    int payload;
    function new(int x);
      payload = x;
    endfunction
  endclass

  int dynamic_values[];
  string text;
  int queue_values[$];
  int associative_values[string];
  item reference_handle, original;
  int scalar;

  initial begin
    dynamic_values = new[1];
    dynamic_values[0] = 2;
    text = "old";
    queue_values.push_back(3);
    associative_values["old"] = 4;
    reference_handle = new(31);
    original = reference_handle;
    #1 $vt_value_change_watch_exclusions;

    #9;
    dynamic_values = new[2](dynamic_values);
    text = "new text";
    queue_values.push_back(15);
    associative_values["new"] = 16;
    original.payload = 33;
    scalar = 11;

    #10;
    dynamic_values[0] = 21;
    text = "new item";
    queue_values[0] = 23;
    associative_values["old"] = 24;
    reference_handle = new(55);
    scalar = 22;

    #10 reference_handle = null;
    #10;
    $display("changed=%0d %s %0d %0d %0d", dynamic_values[0], text,
             queue_values[0], associative_values["old"], original.payload);
    $vt_value_change_report_exclusions;
  end
endmodule
