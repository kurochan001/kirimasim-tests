/*
:name: test_attribute_latch_generate
:description: An attribute on a variable, always_latch, and a variable in a generate loop
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.12 9.2.2.3 27.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_attribute_latch_generate.expected
*/
// An attribute on a variable, always_latch, and a variable in a generate loop

module test_attribute_latch_generate;
  // Various syntax constructs
  logic a, b, c;
  logic [7:0] data;
  int pass_count;

  // Attribute syntax
  (* mark = "test" *)
  logic marked_sig;

  // Generate
  generate
    genvar i;
    for (i = 0; i < 2; i++) begin : gen_loop
      logic gen_sig;
    end
  endgenerate

  // Always blocks
  always_comb begin
    c = a & b;
  end

  always_latch begin
    if (a) data = 8'hFF;
  end

  initial begin
    pass_count = 0;

    // Test 1: Simple logic
    a = 1; b = 1;
    #1;
    if (c == 1) pass_count++;

    // Test 2: Latch behavior
    a = 1;
    #1;
    if (data == 8'hFF) pass_count++;

    // Test 3: Marked signal
    marked_sig = 1;
    if (marked_sig == 1) pass_count++;

    // Test 4: Generate access
    gen_loop[0].gen_sig = 1;
    if (gen_loop[0].gen_sig == 1) pass_count++;

    $display("Attribute, latch and generate tests: %0d/4 passed", pass_count);
    if (pass_count == 4) begin
      $display("PASS: Attribute, latch and generate tests");
    end else begin
      $display("FAIL: Some attribute, latch or generate tests failed");
    end
  end
endmodule
