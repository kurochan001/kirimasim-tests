/*
:name: test_evcd_close_waits_for_finish_even_when_dumping_is_paused
:description: Two extended VCD files close at explicit finish even when one dump is paused
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.3.6.1 21.7.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evcd_close_waits_for_finish_even_when_dumping_is_paused.expected
*/
`timescale 1ns/1ns
module evcd_close_leaf(input wire data, output wire mirror);
  assign mirror = data;
endmodule

module test_evcd_close_waits_for_finish_even_when_dumping_is_paused;
  bit source;
  wire first, second;
  evcd_close_leaf active_dump(source, first);
  evcd_close_leaf paused_dump(source, second);

  function automatic int recorded_close(string filename);
    int fd;
    string token;
    fd = $fopen(filename, "r");
    if (fd == 0)
      return -1;
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$vcdclose") begin
        $fclose(fd);
        return 1;
      end
    end
    $fclose(fd);
    return 0;
  endfunction

  initial begin
    $dumpports(active_dump, "active.evcd");
    $dumpports(paused_dump, "paused.evcd");
    #6 $dumpportsoff("paused.evcd");
    #5 source = 1'b1;
    #2 $dumpportsflush;
    $display("closed before finish active=%0d paused=%0d",
             recorded_close("active.evcd"), recorded_close("paused.evcd"));
    #16 $display("explicit finish=%0d", $time);
    $finish(0);
  end
endmodule
