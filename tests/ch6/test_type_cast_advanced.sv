/*
:name: test_type_cast_advanced
:description: Advanced Type Casting Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_type_cast_advanced.expected
*/
// IEEE 1800-2023 Section 6.24 - Advanced Type Casting Tests
// Tests: Sign extension, truncation, width conversion

module test_type_cast_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Various types for testing
    byte b;
    shortint si;
    int i;
    longint li;
    logic [7:0] l8;
    logic [15:0] l16;
    logic [31:0] l32;
    logic [63:0] l64;

    initial begin
        $display("=== IEEE 1800-2023 Advanced Type Casting Tests ===");

        // Test 1: Byte to int (sign extension)
        $display("Test 1: Byte to int (sign extension)");
        b = -50;
        i = int'(b);
        if (i == -50) begin
            $display("Test 1 PASS: int'(-50 byte)=%0d", i);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", i);
            fail_count++;
        end

        // Test 2: Int to byte (truncation)
        $display("Test 2: Int to byte (truncation)");
        i = 300;  // > 127
        b = byte'(i);
        if (b == 44) begin  // 300 mod 256 = 44
            $display("Test 2 PASS: byte'(300)=%0d", b);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0d", b);
            fail_count++;
        end

        // Test 3: Unsigned to signed conversion
        $display("Test 3: Unsigned to signed");
        l8 = 8'hFF;  // 255 unsigned
        b = byte'(l8);  // Should be -1 as signed
        if (b == -1) begin
            $display("Test 3 PASS: byte'(8'hFF)=%0d", b);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", b);
            fail_count++;
        end

        // Test 4: Shortint to longint (sign extension)
        $display("Test 4: Shortint to longint");
        si = -1000;
        li = longint'(si);
        if (li == -1000) begin
            $display("Test 4 PASS: longint'(-1000 shortint)=%0d", li);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: got %0d", li);
            fail_count++;
        end

        // Test 5: Logic to int
        $display("Test 5: Logic to int");
        l32 = 32'hDEADBEEF;
        i = int'(l32);
        if (i == -559038737) begin  // 0xDEADBEEF as signed
            $display("Test 5 PASS: int'(DEADBEEF)=%0d", i);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %0d", i);
            fail_count++;
        end

        // Test 6: Narrowing cast
        $display("Test 6: Narrowing cast (64->32)");
        l64 = 64'h123456789ABCDEF0;
        l32 = l64[31:0];
        if (l32 == 32'h9ABCDEF0) begin
            $display("Test 6 PASS: lower 32 bits=%h", l32);
            pass_count++;
        end else begin
            $display("Test 6 FAIL: got %h", l32);
            fail_count++;
        end

        // Test 7: Widening cast
        $display("Test 7: Widening cast (8->32)");
        l8 = 8'hAB;
        l32 = {24'b0, l8};
        if (l32 == 32'h000000AB) begin
            $display("Test 7 PASS: widened=%h", l32);
            pass_count++;
        end else begin
            $display("Test 7 FAIL: got %h", l32);
            fail_count++;
        end

        // Test 8: Cast in expression
        $display("Test 8: Cast in expression");
        l8 = 8'd100;
        l16 = 16'd200;
        i = int'(l8) + int'(l16);
        if (i == 300) begin
            $display("Test 8 PASS: int'(100)+int'(200)=%0d", i);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %0d", i);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
