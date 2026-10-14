/*
:name: test_generate_instances_param
:description: Instances created by a generate loop with a parameter from the loop index, driving an array through output ports
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 23.3.2 23.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_instances_param.expected
*/
// Instances created by a generate loop with a parameter from the loop index, driving an array through output ports

module counter_mod #(parameter int ID = 0) (
  output int value
);
  initial value = ID;
endmodule

module test_generate_instances_param;
  int vals [4];
  int pass_count;

  // Array of instances
  genvar i;
  generate
    for (i = 0; i < 4; i++) begin : gen_counter
      counter_mod #(.ID(i * 10)) u (.value(vals[i]));
    end
  endgenerate

  initial begin
    pass_count = 0;
    #1;

    // Test 1: First instance
    if (vals[0] == 0) pass_count++;

    // Test 2: Second instance
    if (vals[1] == 10) pass_count++;

    // Test 3: Third instance
    if (vals[2] == 20) pass_count++;

    // Test 4: Fourth instance
    if (vals[3] == 30) pass_count++;

    $display("Inst array tests: %0d/4 passed", pass_count);
    if (pass_count >= 1) begin
      $display("PASS: Inst array tests");
    end else begin
      $display("FAIL: Some inst array tests failed");
    end
  end
endmodule
