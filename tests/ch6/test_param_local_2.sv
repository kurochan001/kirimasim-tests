/*
:name: test_param_local_2
:description: Test: Localparam usage
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.4 6.20.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_local_2.expected
*/
// Test: Localparam usage
module test_param_local_2;
    // Basic localparam
    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    // Localparam derived from other localparams
    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int TOTAL_BITS = WIDTH * DEPTH;

    // Localparam with expressions
    localparam real PI = 3.14159;
    localparam real AREA = PI * 4.0 * 4.0;  // Circle area with r=4

    // Localparam arrays
    localparam int PRIMES [5] = '{2, 3, 5, 7, 11};

    // Localparam string
    localparam string MODULE_NAME = "test_param_local";

    // Signals using localparams
    logic [WIDTH-1:0] data;
    logic [ADDR_WIDTH-1:0] addr;
    logic [TOTAL_BITS-1:0] memory_flat;

    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic localparam value
        if (WIDTH == 8) begin
            $display("PASS: Test 1 - Basic localparam WIDTH = 8");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - WIDTH = %0d, expected 8", WIDTH);
            fail_count++;
        end

        // Test 2: Derived localparam (clog2)
        if (ADDR_WIDTH == 4) begin
            $display("PASS: Test 2 - Derived localparam ADDR_WIDTH = clog2(16) = 4");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - ADDR_WIDTH = %0d, expected 4", ADDR_WIDTH);
            fail_count++;
        end

        // Test 3: Expression-based localparam
        if (TOTAL_BITS == 128) begin
            $display("PASS: Test 3 - Expression localparam TOTAL_BITS = 8 * 16 = 128");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - TOTAL_BITS = %0d, expected 128", TOTAL_BITS);
            fail_count++;
        end

        // Test 4: Real localparam with calculation
        if (AREA > 50.0 && AREA < 51.0) begin
            $display("PASS: Test 4 - Real localparam AREA ~= 50.27");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - AREA = %f, expected ~50.27", AREA);
            fail_count++;
        end

        // Test 5: Localparam array access
        if (PRIMES[0] == 2 && PRIMES[2] == 5 && PRIMES[4] == 11) begin
            $display("PASS: Test 5 - Localparam array access works");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Localparam array values incorrect");
            fail_count++;
        end

        // Test 6: Localparam in signal sizing
        data = '1;
        if (data == 8'hFF) begin
            $display("PASS: Test 6 - Signal sized by localparam");
            pass_count++;
        end else begin
            $display("FAIL: Test 6 - data = %h, expected FF", data);
            fail_count++;
        end

        // Test 7: String localparam
        if (MODULE_NAME == "test_param_local") begin
            $display("PASS: Test 7 - String localparam works");
            pass_count++;
        end else begin
            $display("FAIL: Test 7 - String localparam incorrect");
            fail_count++;
        end

        $display("\n=== Localparam Test Summary ===");
        $display("PASS: %0d, FAIL: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
