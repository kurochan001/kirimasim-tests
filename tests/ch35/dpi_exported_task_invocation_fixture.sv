`timescale 1ns/1ns

module dpi_exported_task_invocation_fixture;
  import "DPI-C" context task br_enter_task(input int tag, output int status);
  import "DPI-C" context function int br_enter_function(input int tag);
  export "DPI-C" task br_sv_action;

  task automatic br_sv_action(input int tag);
    $display("task entered tag=%0d time=%0d", tag, $time);
`ifdef DPI_FIXTURE_TIMED_ACTION
    #1;
`endif
    $display("task completed tag=%0d time=%0d", tag, $time);
  endtask

  initial begin
    int status;
    br_enter_task(5, status);
    $display("legal task status=%0d time=%0d", status, $time);
    $display("attempting exported task from imported function");
    void'(br_enter_function(7));
  end
endmodule
