/*
:name: test_vpi_systf_shared_routine_user_data
:description: Two system functions registered with the same compiletf and calltf routines tell themselves apart by the user data of their registration, which the tool passes to both routines (IEEE 1800-2023 Section 36.8.4)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.8.4 36.9.1 36.8.2 36.8.3 38.37.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_shared_routine_user_data.c
:expected_stdout: @test_vpi_systf_shared_routine_user_data.expected
*/
// IEEE 1800-2023 §36.8.4: compiletf and calltf get one argument, the
// user_data of the s_vpi_systf_data structure used to register the system
// task or function (38.37.1); §36.9.1 lists this data argument among what a
// registration defines. $vt_plus_one and $vt_plus_ten share both routines and
// differ only in their user data, which holds the number to add and a count
// of compiletf calls. compiletf runs once for each call in the source
// (36.8.2): twice for $vt_plus_one and once for $vt_plus_ten; calltf runs at
// each call (36.8.3).

module test_vpi_systf_shared_routine_user_data;
  int x = 4;

  initial begin
    $display("plus one: %0d", $vt_plus_one(x));
    $display("plus ten: %0d", $vt_plus_ten(x));
    x = 20;
    $display("plus one: %0d", $vt_plus_one(x));
    $vt_report;
  end
endmodule
