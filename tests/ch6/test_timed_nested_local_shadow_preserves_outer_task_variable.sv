/*
:name: test_timed_nested_local_shadow_preserves_outer_task_variable
:description: A timed nested block preserves the outer automatic task variable (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 9.3.1 13.5.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timed_nested_local_shadow_preserves_outer_task_variable.expected
:expected_exit: 0
*/
// The nested block declares a new variable of the same name and waits
// in a method call. Leaving the block restores the outer task variable.

module test_timed_nested_local_shadow_preserves_outer_task_variable;
  class memory;
    task read(output int data);
      #1;
      data = 7;
    endtask
  endclass

  class field;
    memory mem = new;

    task write();
      int segments, data;
      mem.read(data);
      segments = 1;
      if (segments > 0) begin
        longint unsigned segments;
        if (segments != 0) $fatal(1, "inner variable was not initialized");
        mem.read(data);
      end
      $display("CHECK outer=%0d data=%0d", segments, data);
      if (segments != 1 || data != 7) $fatal(1, "outer local lost after read");
    endtask
  endclass

  initial begin
    automatic field value = new;
    value.write();
    $display("CHECK pass");
    $finish;
  end
endmodule
