/*
:name: test_vpi_unpacked_union_rejects_whole_value_access
:description: A VPI caller can read and update the active union member and cannot access the whole unpacked union value
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.26 37.17 38.15 38.34
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_unpacked_union_rejects_whole_value_access.expected
:vpi_c: @test_vpi_unpacked_structure_rejects_whole_value_access.c
*/
`timescale 1ns/1ns
module test_vpi_unpacked_union_rejects_whole_value_access;
  typedef union {
    shortint narrow;
    int reading;
  } reading_t;
  reading_t packet;

  initial begin
    packet.reading = 17;
    #1 $vt_access();
    #1 $display("after write: reading=%0d", packet.reading);
  end
endmodule
