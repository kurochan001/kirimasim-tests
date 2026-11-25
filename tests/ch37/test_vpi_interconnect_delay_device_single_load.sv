/*
:name: test_vpi_interconnect_delay_device_single_load
:description: An SDF interconnect exposes distinct input and output VPI delay terminals
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.45 37.46 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: delay_probe_top
:expected_stdout: @test_vpi_interconnect_delay_device_single_load.expected
:vpi_c: @test_vpi_interconnect_delay_device.c
*/
`timescale 1ns/1ns

module delay_probe_source(input wire drive, output wire o);
  assign o = drive;
endmodule

module delay_probe_target(input wire i, output wire observed);
  assign observed = i;
endmodule

module delay_probe_top;
  reg drive = 0;
  wire link, sink_value;
  delay_probe_source source(drive, link);
  delay_probe_target sink(link, sink_value);

  task automatic sample;
    $display("hdl time=%0d source=%b sink=%b", $time, link, sink.i);
    $vt_delay_snapshot("delay_probe_top.link", "delay_probe_top.sink.i", "delay_probe_top");
  endtask

  initial begin
    integer file;
    file = $fopen("single_load.sdf", "w");
    $fdisplay(file, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(file, "  (CELL (CELLTYPE \"delay_probe_top\") (INSTANCE)");
    $fdisplay(file, "    (DELAY (ABSOLUTE (INTERCONNECT source.o sink.i (5))))))");
    $fclose(file);
    $sdf_annotate("single_load.sdf", delay_probe_top);
    #8 sample();
    #2 drive = 1;
    #1 sample();
    #5 sample();
    #4 drive = 0;
    #1 sample();
    #5 sample();
  end
endmodule
