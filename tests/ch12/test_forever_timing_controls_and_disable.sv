/*
:name: test_forever_timing_controls_and_disable
:description: A bounded zero-delay forever ends with disable and a delayed forever permits peer events
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forever_timing_controls_and_disable.expected
*/
`timescale 1ns/1ns
module test_forever_timing_controls_and_disable;
  int immediate_visits = 0, delayed_visits = 0;

  initial begin
    #2;
    begin : bounded
      forever begin
        immediate_visits++;
        if (immediate_visits == 3) disable bounded;
      end
    end
    $display("immediate time=%0d visits=%0d", $time, immediate_visits);

    begin : waiting
      forever begin
        #2;
        delayed_visits++;
        $display("delayed time=%0d visits=%0d", $time, delayed_visits);
        if (delayed_visits == 3) disable waiting;
      end
    end
    $display("end time=%0d", $time);
    $finish(0);
  end

  initial begin
    #3 $display("peer time=%0d", $time);
    #2 $display("peer time=%0d", $time);
  end
endmodule
