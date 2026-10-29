/*
:name: test_reactive_region_set_order
:description: in a program, #0 resumes the process in the Re-Inactive region, before the Re-NBA region updates a nonblocking assignment made in the Reactive region, and a program process woken by that update runs before the module process woken by it (IEEE 1800-2023 Sections 4.4.2.7, 4.4.2.8)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.7 4.4.2.8 4.5 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reactive_region_set_order.expected
*/
// IEEE 1800-2023 §24.3: the processes of a program run in the reactive region
// set. §4.4.2.8: a nonblocking assignment made there creates an update in the
// Re-NBA region. §4.4.2.7: #0 suspends the process until the Re-Inactive
// region, which comes before the Re-NBA region, so after #0 the variable
// still has its old value. §4.5: when the update in the Re-NBA region wakes a
// module process and a program process, the reactive region set is drained
// before returning to Active, so the program process logs first. Keep the
// program alive afterward: its last initial completing would terminate the
// simulation before the module process can run (24.3).

module test_reactive_region_set_order;
  int v = 0;
  string log_lines[$];

  function automatic void log(string s);
    log_lines.push_back(s);
  endfunction

  always @(v) log($sformatf("module: v changed to %0d", v));

  program p;
    initial begin
      #10;
      log("program: start");
      v <= 1;
      #0;
      log($sformatf("program: after #0, v = %0d", v));
      @(v);
      log($sformatf("program: v changed to %0d", v));
      #1;  // Let the pending module Active event run before program termination.
    end
  endprogram

  final foreach (log_lines[i]) $display("%s", log_lines[i]);
endmodule
