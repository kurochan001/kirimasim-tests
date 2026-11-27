/*
:name: test_vpi_automatic_frame_lifetime
:description: Two overlapping automatic task frames retire before their enclosing threads
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.7 37.3.8 37.43 37.44 38.36.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_automatic_frame_lifetime.expected
:files: vpi_frame_lifetime/driver.cpp vpi_frame_lifetime/reference.expected
*/
`timescale 1ns/1ps

module test_vpi_automatic_frame_lifetime;
`ifdef REFERENCE_FRAME_LIFETIME
  import "DPI-C" function void observe_body(input int branch, input int stamp,
                                             input byte vector, input bit leaving);
  import "DPI-C" function void observe_phase(input int phase);
`endif

  task automatic work(input int branch, input int delay_ns);
    /* verilator no_inline_task */
    int stamp = 53 + branch;
    byte vector = 8'h25 + 8'(branch);
`ifdef REFERENCE_FRAME_LIFETIME
    observe_body(branch, stamp, vector, 0);
`endif
    $display("start branch=%0d stamp=%0d vector=%0d", branch, stamp, vector);
    #(delay_ns);
    vector ^= 8'h10;
`ifdef REFERENCE_FRAME_LIFETIME
    observe_body(branch, stamp, vector, 1);
`endif
    $display("finish branch=%0d stamp=%0d vector=%0d", branch, stamp, vector);
  endtask

  task automatic sample(input int phase);
`ifdef REFERENCE_FRAME_LIFETIME
    observe_phase(phase);
`endif
    $display("sample %0d", phase);
  endtask

  initial begin
    sample(0);
    fork
      begin
        work(0, 3);
        #2 sample(2);
      end
      begin
        #1 work(1, 5);
        #2 sample(4);
      end
    join_none
    #0.5 sample(6);
    #1.5 sample(1);
    #5 sample(3);
    wait fork;
    #1 sample(5);
    $finish(0);
  end
endmodule
