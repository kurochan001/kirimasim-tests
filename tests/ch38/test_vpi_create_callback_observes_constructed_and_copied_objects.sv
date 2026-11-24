/*
:name: test_vpi_create_callback_observes_constructed_and_copied_objects
:description: A class creation callback sees the initialized members of construction and shallow copy for only its registered type
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.33 8.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_create_callback_observes_constructed_and_copied_objects.expected
:vpi_c: @test_vpi_create_callback_observes_constructed_and_copied_objects.c
*/
module test_vpi_create_callback_observes_constructed_and_copied_objects;
  class observed_type;
    int token = 1;
    int derived;
    function new(int value);
      token = value;
      derived = 3 * value + 4;
    endfunction
  endclass

  class other_type;
    int token = 29;
  endclass

  observed_type original, alias_handle, replica;
  other_type control;

  initial begin
    $vt_create_setup;
    original = new(11);
    $display("constructor %0d %0d", original.token, original.derived);
    alias_handle = original;
    control = new;
    replica = new original;
    $display("copy %0d %0d distinct=%b", replica.token, replica.derived, replica != alias_handle);
    original.token = 99;
    $display("after write original=%0d copy=%0d", original.token, replica.token);
    $vt_create_report;
  end
endmodule
