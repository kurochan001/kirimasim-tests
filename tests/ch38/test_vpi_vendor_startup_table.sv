/*
:name: test_vpi_vendor_startup_table
:description: Two user registrations extend the vendor VPI startup table and run alongside a standard system task
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.37.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: vendor_startup_fixture/application.c vendor_startup_fixture/extended.expected
:expected_stdout: @test_vpi_vendor_startup_table.expected
*/
`timescale 1ns/1ns

module test_vpi_vendor_startup_table;
  initial begin
    #2 $display("stock system task time=%0d", $time);
`ifdef VENDOR_STARTUP_EXTENDED
    $vendor_startup_first;
    $vendor_startup_second;
`endif
  end
endmodule
