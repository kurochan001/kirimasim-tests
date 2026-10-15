/*
:name: test_localparam
:description: Test: Localparam with expressions
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.4 6.20.3 20.8.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_localparam.expected
*/
// Test: Localparam with expressions
module test_localparam;
    int pass_count = 0;
    int fail_count = 0;

    // Basic localparams
    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    // Localparam with arithmetic expression
    localparam int TOTAL_BITS = WIDTH * DEPTH;

    // Localparam with function call
    localparam int LOG2_DEPTH = $clog2(DEPTH);

    // Localparam with conditional expression
    localparam int ALIGNMENT = (WIDTH >= 32) ? 32 : (WIDTH >= 16) ? 16 : 8;

    // Localparam with bitwise operations
    localparam logic [7:0] MASK = (1 << WIDTH) - 1;
    localparam logic [7:0] INV_MASK = ~MASK;

    // Localparam string
    localparam string MODULE_NAME = "test_localparam";

    // Localparam with type
    localparam type DATA_TYPE = logic [WIDTH-1:0];

    // Derived localparams
    localparam int ADDR_WIDTH = LOG2_DEPTH;
    localparam int TOTAL_SIZE = (1 << ADDR_WIDTH) * WIDTH;

    // Localparam array
    localparam int PRIMES[5] = '{2, 3, 5, 7, 11};

    // Complex expression
    localparam real PI = 3.14159;
    localparam real CIRCUMFERENCE = 2.0 * PI * 10.0;

    DATA_TYPE test_data;

    initial begin
        // Test 1: Basic localparam
        if (WIDTH == 8 && DEPTH == 16) begin
            $display("PASS: Basic localparam values");
            pass_count++;
        end else begin
            $display("FAIL: Basic - WIDTH=%0d, DEPTH=%0d", WIDTH, DEPTH);
            fail_count++;
        end

        // Test 2: Arithmetic expression
        if (TOTAL_BITS == 128) begin
            $display("PASS: Localparam arithmetic expression");
            pass_count++;
        end else begin
            $display("FAIL: TOTAL_BITS - expected 128, got %0d", TOTAL_BITS);
            fail_count++;
        end

        // Test 3: Function call in localparam
        if (LOG2_DEPTH == 4) begin
            $display("PASS: Localparam with $clog2");
            pass_count++;
        end else begin
            $display("FAIL: LOG2_DEPTH - expected 4, got %0d", LOG2_DEPTH);
            fail_count++;
        end

        // Test 4: Conditional expression
        if (ALIGNMENT == 8) begin
            $display("PASS: Localparam conditional expression");
            pass_count++;
        end else begin
            $display("FAIL: ALIGNMENT - expected 8, got %0d", ALIGNMENT);
            fail_count++;
        end

        // Test 5: Localparam string
        if (MODULE_NAME == "test_localparam") begin
            $display("PASS: Localparam string");
            pass_count++;
        end else begin
            $display("FAIL: MODULE_NAME - expected 'test_localparam', got '%s'", MODULE_NAME);
            fail_count++;
        end

        // Test 6: Derived localparam chain
        if (ADDR_WIDTH == 4 && TOTAL_SIZE == 128) begin
            $display("PASS: Derived localparam chain");
            pass_count++;
        end else begin
            $display("FAIL: Derived - ADDR_WIDTH=%0d, TOTAL_SIZE=%0d", ADDR_WIDTH, TOTAL_SIZE);
            fail_count++;
        end

        // Test 7: Localparam array
        if (PRIMES[0] == 2 && PRIMES[4] == 11) begin
            $display("PASS: Localparam array");
            pass_count++;
        end else begin
            $display("FAIL: PRIMES - [0]=%0d, [4]=%0d", PRIMES[0], PRIMES[4]);
            fail_count++;
        end

        // Test 8: Type localparam usage
        test_data = 8'hAB;
        if (test_data == 8'hAB && $bits(test_data) == WIDTH) begin
            $display("PASS: Localparam type");
            pass_count++;
        end else begin
            $display("FAIL: Type param - value=0x%02X, bits=%0d", test_data, $bits(test_data));
            fail_count++;
        end

        // Summary
        $display("Localparam test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All localparam tests passed");
        $finish;
    end
endmodule
