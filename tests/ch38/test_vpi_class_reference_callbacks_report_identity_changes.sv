/*
:name: test_vpi_class_reference_callbacks_report_identity_changes
:description: Class variable callbacks observe reference identity changes and expose no value data
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.33 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_class_reference_callbacks_report_identity_changes.c
:expected_stdout: @test_vpi_class_reference_callbacks_report_identity_changes.expected
*/
`timescale 1ns/1ns
module test_vpi_class_reference_callbacks_report_identity_changes;
  class payload;
    int member;
    function new(input int initial_value);
      member = initial_value;
    endfunction
  endclass

  payload picked, first_ref, second_ref;
  bit pulse;

  initial begin
    first_ref = new(11);
    second_ref = new(22);
    #1 $watch_class_reference;
    #1 picked = first_ref;
    pulse = !pulse;
    #1 picked = first_ref;
    pulse = !pulse;
    #1 first_ref.member = 44;
    pulse = !pulse;
    #1 picked = second_ref;
    pulse = !pulse;
    #1 picked = null;
    pulse = !pulse;
    #1 picked = first_ref;
    pulse = !pulse;
    #1 picked = new(33);
    pulse = !pulse;
    #1;
    $display("design values=%0d/%0d/%0d", first_ref.member, second_ref.member, picked.member);
    $report_class_reference;
    $finish(0);
  end
endmodule
