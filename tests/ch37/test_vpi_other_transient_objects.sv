/*
:name: test_vpi_other_transient_objects
:description: A forked thread observes an outdated reference, a scoped reference, an iterator, a scheduled event, and timer callbacks
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.7 13.5.2 37.44 38.34 38.36.1 38.39 38.40
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_other_transient_objects.c
:expected_stdout: @test_vpi_other_transient_objects.expected
*/
`timescale 1ns/1ns

module test_vpi_other_transient_objects;
  int values[];
  int target = 0;

  task automatic hold(ref int item, const ref int scoped);
    $vt_transient_sample(1, item);
    #2 item = 43;
    $display("holder outdated=%0d scoped=%0d", item, scoped);
    $vt_transient_sample(2, item);
  endtask

  initial begin
    values = new[2];
    values[1] = 17;
    fork
      begin
        begin : lexical_region
          automatic int local_value = 23;
          hold(values[1], local_value);
          $display("caller scoped=%0d replacement=%0d", local_value, values[1]);
        end
        #2 $vt_transient_sample(3, values[1]);
      end
      begin
        #1 values = new[3];
        values[1] = 69;
      end
    join
    #1 $vt_transient_sample(4, values[1]);
    $finish(0);
  end
endmodule
