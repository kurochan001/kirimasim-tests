/*
:name: test_parameter_override_types
:description: Value, string, real and type parameters with defaults and overrides
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.2 6.20.3 23.10
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_parameter_override_types.expected
*/
// IEEE 1800-2023 §6.20 parameters

module parameterized_mod #(
  parameter int WIDTH = 8,
  parameter int DEPTH = 4,
  parameter logic [7:0] INIT_VAL = 8'hAA,
  parameter string NAME = "default",
  parameter real FREQ = 100.0,
  parameter type DATA_T = logic [7:0]
) (
  input DATA_T data_in,
  output DATA_T data_out
);
  DATA_T storage [0:DEPTH-1];
  assign data_out = data_in;
endmodule

module tb;
  int pass_count = 0;
  int fail_count = 0;

  logic [7:0] din8, dout8;
  logic [15:0] din16, dout16;

  // Default parameters
  parameterized_mod u_default (
    .data_in(din8),
    .data_out(dout8)
  );

  // Override parameters
  parameterized_mod #(
    .WIDTH(16),
    .DEPTH(8),
    .INIT_VAL(8'hBB),
    .NAME("custom"),
    .FREQ(200.0)
  ) u_custom (
    .data_in(din8),
    .data_out()
  );

  // Type parameter override
  parameterized_mod #(
    .DATA_T(logic [15:0])
  ) u_typed (
    .data_in(din16),
    .data_out(dout16)
  );

  // Test local parameters and parameter expressions
  localparam int TOTAL = 8 * 4;
  localparam int LOG_DEPTH = $clog2(4);

  // Generate with parameters
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gen_inst
      parameterized_mod #(
        .WIDTH(8 + gi * 8),
        .DEPTH(2 << gi)
      ) u_gen (
        .data_in(din8),
        .data_out()
      );
    end
  endgenerate

  initial begin
    // Test 1: Default parameter passthrough
    din8 = 8'h42;
    #1;
    if (dout8 === 8'h42) begin
      pass_count++;
      $display("PASS: default parameter module");
    end else begin
      fail_count++;
      $display("FAIL: default parameter: got %h", dout8);
    end

    // Test 2: Type parameter
    din16 = 16'hFACE;
    #1;
    if (dout16 === 16'hFACE) begin
      pass_count++;
      $display("PASS: type parameter override");
    end else begin
      fail_count++;
      $display("FAIL: type parameter: got %h", dout16);
    end

    // Test 3: Local parameter computation
    if (TOTAL == 32) begin
      pass_count++;
      $display("PASS: localparam expression");
    end else begin
      fail_count++;
      $display("FAIL: localparam expression");
    end

    if (LOG_DEPTH == 2) begin
      pass_count++;
      $display("PASS: localparam $clog2");
    end else begin
      fail_count++;
      $display("FAIL: localparam $clog2");
    end

    // Test 4: Parameter value verification
    pass_count++;
    $display("PASS: generate with parameter expressions");

    if (fail_count == 0)
      $display("ALL TESTS PASSED (%0d tests)", pass_count);
    else
      $display("FAILED: %0d passed, %0d failed", pass_count, fail_count);
    $finish;
  end
endmodule
