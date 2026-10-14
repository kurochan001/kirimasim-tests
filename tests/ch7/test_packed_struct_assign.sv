/*
:name: test_packed_struct_assign
:description: Packed Structures
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 10.9.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_struct_assign.expected
*/
// IEEE 1800-2023 §7.2 Packed Structures
// Tests packed struct assignments and field access

module test_packed_struct_assign;
    int pass_count = 0;
    int fail_count = 0;

    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } pair_t;

    typedef struct packed {
        logic [3:0] a;
        logic [3:0] b;
        logic [3:0] c;
        logic [3:0] d;
    } quad_t;

    pair_t pair;
    quad_t quad;
    logic [15:0] word;
    logic [15:0] result;

    initial begin
        // Test 1: Assign to packed struct as whole
        pair = 16'hABCD;
        if (pair.high == 8'hAB && pair.low == 8'hCD) begin
            $display("PASS: Assign word to packed struct");
            pass_count++;
        end else begin
            $display("FAIL: Struct assign - high=%h, low=%h", pair.high, pair.low);
            fail_count++;
        end

        // Test 2: Assign to struct fields
        pair.high = 8'h11;
        pair.low = 8'h22;
        word = pair;
        if (word == 16'h1122) begin
            $display("PASS: Read packed struct as word");
            pass_count++;
        end else begin
            $display("FAIL: Struct to word - word=%h", word);
            fail_count++;
        end

        // Test 3: Struct literal assignment
        pair = '{8'hFF, 8'h00};
        if (pair.high == 8'hFF && pair.low == 8'h00) begin
            $display("PASS: Struct literal assignment");
            pass_count++;
        end else begin
            $display("FAIL: Struct literal - high=%h, low=%h", pair.high, pair.low);
            fail_count++;
        end

        // Test 4: Multi-field struct
        quad = 16'h1234;
        if (quad.a == 4'h1 && quad.b == 4'h2 &&
            quad.c == 4'h3 && quad.d == 4'h4) begin
            $display("PASS: Multi-field struct assignment");
            pass_count++;
        end else begin
            $display("FAIL: Quad struct - a=%h, b=%h, c=%h, d=%h",
                     quad.a, quad.b, quad.c, quad.d);
            fail_count++;
        end

        // Test 5: Modify single field
        quad.b = 4'hF;
        if (quad == 16'h1F34) begin
            $display("PASS: Single field modification");
            pass_count++;
        end else begin
            $display("FAIL: Single field mod - quad=%h", quad);
            fail_count++;
        end

        // Test 6: Struct comparison
        pair = 16'h5555;
        if (pair == 16'h5555) begin
            $display("PASS: Struct comparison with word");
            pass_count++;
        end else begin
            $display("FAIL: Struct comparison failed");
            fail_count++;
        end

        // Test 7: Struct in expression
        pair = 16'h0100;
        result = pair + 16'h0001;
        if (result == 16'h0101) begin
            $display("PASS: Struct in arithmetic expression");
            pass_count++;
        end else begin
            $display("FAIL: Struct arithmetic - result=%h", result);
            fail_count++;
        end

        $display("");
        $display("=== Packed Struct Assignment Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
