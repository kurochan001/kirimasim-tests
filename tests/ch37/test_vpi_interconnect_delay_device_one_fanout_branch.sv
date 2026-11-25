/*
:name: test_vpi_interconnect_delay_device_one_fanout_branch
:description: The VPI delay terminals follow only the selected branch with asymmetric interconnect delay
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.45 37.46 32.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: delay_probe_top
:expected_stdout: @test_vpi_interconnect_delay_device_one_fanout_branch.expected
:vpi_c: @test_vpi_interconnect_delay_device.c
*/
`timescale 1ns/1ns

module delay_probe_source(input wire drive, output wire o);
  buf driver(o, drive);
endmodule

module delay_probe_target(input wire i, output wire observed);
  buf load(observed, i);
endmodule

module delay_probe_top;
  reg drive = 0;
  wire link, delayed_value, direct_value;
  delay_probe_source source(drive, link);
  delay_probe_target delayed_sink(link, delayed_value);
  delay_probe_target direct_sink(link, direct_value);

  task automatic sample;
    $display("hdl time=%0d source=%b delayed=%b direct=%b",
             $time, link, delayed_sink.i, direct_sink.i);
    $vt_delay_snapshot("delay_probe_top.link", "delay_probe_top.delayed_sink.i",
                      "delay_probe_top", "delay_probe_top.direct_sink.i");
  endtask

  initial begin
    integer file;
    file = $fopen("one_fanout_branch.sdf", "w");
    $fdisplay(file, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(file, "  (CELL (CELLTYPE \"delay_probe_top\") (INSTANCE)");
    $fdisplay(file, "    (DELAY (ABSOLUTE (INTERCONNECT source.o delayed_sink.i (4) (7))))))");
    $fclose(file);
    $sdf_annotate("one_fanout_branch.sdf", delay_probe_top);
    #8 sample();
    #2 drive = 1;
    #1 sample();
    #4 sample();
    #5 drive = 0;
    #1 sample();
    #5 sample();
    #2 sample();
  end
endmodule
