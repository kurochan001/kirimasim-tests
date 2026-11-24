/*
:name: test_sdf_interconnect_keeps_twenty_four_queued_transitions
:description: An annotated interconnect delivers every transition when twenty-four edges are queued before the first delivery
:tags: ch32
:type: simulation
:lrm: 1800-2023 32.4.4 32.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sdf_interconnect_keeps_twenty_four_queued_transitions.expected
*/
`timescale 1ns/1ns

module queued_delay_source(input a, output y);
  buf (y, a);
endmodule

module queued_delay_load(input a, output y);
  assign y = a;
endmodule

module test_sdf_interconnect_keeps_twenty_four_queued_transitions;
  logic a = 0;
  wire connection, observed;
  int delivered = 0, mismatched = 0;
  integer first_time = -1, last_time = -1;
  integer fd;
  queued_delay_source s(a, connection);
  queued_delay_load l(connection, observed);

  // The initial 0 may itself be transported through a delay of 128.
  // Only departures from that settled value and later edges are counted.
  always @(l.a) begin
    if ($time >= 148 || ($time >= 20 && l.a === 1'b1)) begin
      if (delivered == 0) first_time = int'($time);
      last_time = int'($time);
      if ($time != 148 + 2 * delivered || l.a !== (delivered % 2 == 0))
        mismatched++;
      delivered++;
    end
  end

  initial begin
    fd = $fopen("queued_delays.sdf", "w");
    if (!fd) $fatal(1, "cannot create SDF fixture");
    $fdisplay(fd, "(DELAYFILE (SDFVERSION \"3.0\") (TIMESCALE 1ns)");
    $fdisplay(fd, "  (CELL (CELLTYPE \"%m\")");
    $fdisplay(fd, "    (INSTANCE) (DELAY (ABSOLUTE");
    $fdisplay(fd, "      (INTERCONNECT s.y l.a ((128) (0) (1)))))))");
    $fclose(fd);
    $sdf_annotate("queued_delays.sdf");

    // Source edges run from 20 to 66. The load edges run from 148 to 194.
    #18;
    repeat (24) #2 a = !a;
    #150;
    $display("delivered=%0d wrong=%0d first=%0d last=%0d",
             delivered, mismatched, first_time, last_time);
  end
endmodule
