/*
:name: test_bind_assertion_basic
:description: Test for bind directive with assertions
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 16.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_assertion_basic.expected
*/
// Test for bind directive with assertions
// IEEE 1800-2023 Section 23.11

// Simple DUT module
module dut (
    input logic clk,
    input logic rst_n,
    input logic valid,
    input logic [7:0] data,
    output logic ready
);
    logic [7:0] reg_data;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_data <= 8'h00;
            ready <= 1'b0;
        end else if (valid) begin
            reg_data <= data;
            ready <= 1'b1;
        end else begin
            ready <= 1'b0;
        end
    end
endmodule

// Assertion module to be bound
module dut_assertions (
    input logic clk,
    input logic rst_n,
    input logic valid,
    input logic ready
);
    // Property: When valid, ready should be high on next cycle
    property valid_ready_check;
        @(posedge clk) disable iff (!rst_n)
        valid |=> ready;
    endproperty

    // Assert the property
    assert property (valid_ready_check)
        else $error("Valid-ready protocol violation");

    // Cover the property
    cover property (valid_ready_check);
endmodule

// Bind the assertion module to DUT
bind dut dut_assertions dut_assert_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid(valid),
    .ready(ready)
);

// Testbench
module test_bind_assertion_basic;
    logic clk;
    logic rst_n;
    logic valid;
    logic [7:0] data;
    logic ready;

    int pass_count = 0;
    int fail_count = 0;

    // Instantiate DUT
    dut u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid(valid),
        .data(data),
        .ready(ready)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("=== Bind Assertion Basic Test ===");
        clk = 0;
        rst_n = 0;
        valid = 0;
        data = 8'h00;

        // Test 1: Reset behavior
        $display("Test 1: Reset behavior");
        @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        if (!ready) begin
            $display("Test 1 PASS: ready is low after reset");
            pass_count++;
        end else begin
            $display("Test 1 FAIL: ready should be low");
            fail_count++;
        end

        // Test 2: Valid-ready protocol (should trigger assertion pass)
        // DUT sets ready high on same cycle as valid, then low when valid is low
        $display("Test 2: Valid-ready protocol");
        valid = 1;
        data = 8'hAB;
        @(posedge clk);
        // Check ready right after the edge - it should be high now
        #1;  // Small delay to allow signal to propagate
        if (ready) begin
            $display("Test 2 PASS: ready high when valid is high");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: ready should be high");
            fail_count++;
        end
        valid = 0;
        @(posedge clk);

        // Test 3: Another valid pulse
        $display("Test 3: Another valid pulse");
        valid = 1;
        data = 8'hCD;
        @(posedge clk);
        #1;
        if (ready) begin
            $display("Test 3 PASS: ready high for second pulse");
            pass_count++;
        end else begin
            $display("Test 3 FAIL: ready should be high");
            fail_count++;
        end
        valid = 0;
        @(posedge clk);

        // Summary
        $display("");
        $display("=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
