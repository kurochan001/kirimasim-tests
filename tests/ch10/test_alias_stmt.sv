/*
:name: test_alias_stmt
:description: Test: alias net statement
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_alias_stmt.expected
*/
// Test: alias net statement
// Tests bidirectional net aliasing

module test_alias_stmt;
    wire [7:0] net_a;
    wire [7:0] net_b;
    wire [7:0] net_c;

    wire [3:0] alias_x;
    wire [3:0] alias_y;

    wire single_a, single_b;

    reg [7:0] driver_a;
    reg [7:0] driver_b;
    reg [3:0] driver_x;
    reg single_driver;

    int pass_count = 0;
    int fail_count = 0;

    // Alias declarations
    alias net_a = net_b;
    alias alias_x = alias_y;
    alias single_a = single_b;

    // Drivers
    assign net_a = driver_a;
    assign alias_x = driver_x;
    assign single_a = single_driver;

    initial begin
        // Initialize drivers
        driver_a = 8'h00;
        driver_b = 8'h00;
        driver_x = 4'h0;
        single_driver = 1'b0;
        #1;

        // Test 1: Basic alias - drive one, read other
        driver_a = 8'hAB;
        #1;
        if (net_b == 8'hAB) begin
            $display("PASS: Test 1 - Alias propagates value (net_a->net_b)");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - expected 0xAB on net_b, got 0x%0h", net_b);
            fail_count++;
        end

        // Test 2: Change driver, alias follows
        driver_a = 8'h55;
        #1;
        if (net_b == 8'h55) begin
            $display("PASS: Test 2 - Alias follows driver changes");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - expected 0x55, got 0x%0h", net_b);
            fail_count++;
        end

        // Test 3: Narrower alias
        driver_x = 4'hC;
        #1;
        if (alias_y == 4'hC) begin
            $display("PASS: Test 3 - 4-bit alias works");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - expected 0xC, got 0x%0h", alias_y);
            fail_count++;
        end

        // Test 4: Single-bit alias
        single_driver = 1'b1;
        #1;
        if (single_b == 1'b1) begin
            $display("PASS: Test 4a - Single-bit alias (1)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4a - expected 1, got %0b", single_b);
            fail_count++;
        end

        single_driver = 1'b0;
        #1;
        if (single_b == 1'b0) begin
            $display("PASS: Test 4b - Single-bit alias (0)");
            pass_count++;
        end else begin
            $display("FAIL: Test 4b - expected 0, got %0b", single_b);
            fail_count++;
        end

        // Test 5: Multiple value changes
        driver_a = 8'h11;
        #1;
        driver_a = 8'h22;
        #1;
        driver_a = 8'h33;
        #1;
        if (net_b == 8'h33) begin
            $display("PASS: Test 5 - Alias tracks multiple changes");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - expected 0x33, got 0x%0h", net_b);
            fail_count++;
        end

        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All alias statement tests passed");
        else
            $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
