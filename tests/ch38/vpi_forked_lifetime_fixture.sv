`timescale 1ns/1ns

module vpi_forked_lifetime_fixture #(bit OBJECT_ONLY = 0);
  task automatic observed_task(int index, int delay_ticks);
    int local_value = 10 * (index + 1);
    $vt_track_frame(index, OBJECT_ONLY);
    #delay_ticks local_value += 7;
  endtask

  initial begin
    fork
      observed_task(0, 5);
      begin
        #1;
        observed_task(1, 6);
      end
    join
    #1 $vt_report_frames;
  end
endmodule
