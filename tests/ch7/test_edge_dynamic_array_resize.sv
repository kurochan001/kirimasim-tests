/*
:name: test_edge_dynamic_array_resize
:description: Dynamic array resizing with new[] and new[](old), including new[0]
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.5.1 7.5.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_dynamic_array_resize.expected
*/
module test_edge_dynamic_array_resize;
  int dyn[];

  initial begin
    dyn = new[0];
    if (dyn.size() != 0) begin
      $fatal(1, "Expected empty array after new[0], size=%0d", dyn.size());
    end

    dyn = new[5];
    if (dyn.size() != 5) begin
      $fatal(1, "Expected size 5 after resize, size=%0d", dyn.size());
    end
    foreach (dyn[i]) begin
      dyn[i] = i;
    end

    dyn = new[2](dyn);
    if (dyn.size() != 2 || dyn[0] != 0 || dyn[1] != 1) begin
      $fatal(1, "Resize with initialization failed: size=%0d values=%p", dyn.size(), dyn);
    end

    $display("PASS: dynamic array resize behaved as expected");
    $finish;
  end
endmodule
