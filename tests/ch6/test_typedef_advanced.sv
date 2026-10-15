/*
:name: test_typedef_advanced
:description: Advanced Typedef Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_typedef_advanced.expected
*/
// IEEE 1800-2023 Section 6.18 - Advanced Typedef Tests
// Tests: Type definitions, struct types, array types

module test_typedef_advanced;
    int pass_count = 0;
    int fail_count = 0;

    // Simple typedefs
    typedef logic [7:0] byte_t;
    typedef logic [15:0] hword_t;
    typedef logic [31:0] word_t;

    // Struct typedef
    typedef struct packed {
        logic [7:0] r;
        logic [7:0] g;
        logic [7:0] b;
        logic [7:0] a;
    } rgba_t;

    // Array typedef
    typedef byte_t byte_array_t[4];

    // Nested typedef
    typedef struct packed {
        hword_t x;
        hword_t y;
    } point_t;

    byte_t b1;
    hword_t h1;
    word_t w1;
    rgba_t color;
    byte_array_t arr;
    point_t pt;

    initial begin
        $display("=== IEEE 1800-2023 Advanced Typedef Tests ===");

        // Test 1: Simple typedef
        $display("Test 1: Simple typedef byte_t");
        b1 = 8'hAB;
        if (b1 == 8'hAB) begin
            $display("Test 1 PASS: byte_t=%h", b1);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %h", b1);
            fail_count++;
        end

        // Test 2: Half-word typedef
        $display("Test 2: Half-word typedef");
        h1 = 16'h1234;
        if (h1 == 16'h1234) begin
            $display("Test 2 PASS: hword_t=%h", h1);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %h", h1);
            fail_count++;
        end

        // Test 3: Word typedef
        $display("Test 3: Word typedef");
        w1 = 32'hDEADBEEF;
        if (w1 == 32'hDEADBEEF) begin
            $display("Test 3 PASS: word_t=%h", w1);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %h", w1);
            fail_count++;
        end

        // Test 4: Struct typedef members
        $display("Test 4: Struct typedef members");
        color.r = 8'hFF;
        color.g = 8'h00;
        color.b = 8'h00;
        color.a = 8'hFF;
        if (color.r == 8'hFF && color.g == 8'h00) begin
            $display("Test 4 PASS: rgba_t r=%h g=%h b=%h a=%h",
                     color.r, color.g, color.b, color.a);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: Struct as packed value
        $display("Test 5: Struct as packed value");
        color = 32'h00FF00FF;  // g=FF, a=FF
        if (color.g == 8'hFF && color.a == 8'hFF) begin
            $display("Test 5 PASS: packed rgba=%h", color);
            pass_count++;
        end else begin
            $display("Test 5 FAIL: got %h", color);
            fail_count++;
        end

        // Test 6: Array typedef
        $display("Test 6: Array typedef");
        arr[0] = 8'h11;
        arr[1] = 8'h22;
        arr[2] = 8'h33;
        arr[3] = 8'h44;
        if (arr[0] == 8'h11 && arr[3] == 8'h44) begin
            $display("Test 6 PASS: arr[0]=%h arr[3]=%h", arr[0], arr[3]);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: Nested struct typedef
        $display("Test 7: Nested struct typedef");
        pt.x = 16'h0100;
        pt.y = 16'h0200;
        if (pt.x == 16'h0100 && pt.y == 16'h0200) begin
            $display("Test 7 PASS: point x=%h y=%h", pt.x, pt.y);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: Typedef in expression
        $display("Test 8: Typedef in expression");
        b1 = 8'h10;
        h1 = {b1, b1};
        if (h1 == 16'h1010) begin
            $display("Test 8 PASS: {byte,byte}=%h", h1);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", h1);
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
