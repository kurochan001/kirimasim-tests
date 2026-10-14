/*
:name: test_union_basic_edge_cases
:description: Union basic edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_union_basic_edge_cases.expected
*/
// IEEE 1800-2023 §7.3: Union basic edge cases
// Tests for union types

module test_union_basic_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] high;
            logic [15:0] low;
        } halves;
        struct packed {
            logic [7:0] b3, b2, b1, b0;
        } bytes;
    } data32_u;

    typedef union packed {
        logic [7:0] u8;
        struct packed {
            logic [3:0] high;
            logic [3:0] low;
        } nibbles;
    } byte_u;

    initial begin
        data32_u d;
        byte_u b;

        // Test 1: Set as word
        test_count++;
        d.word = 32'h12345678;
        if (d.word == 32'h12345678) begin
            pass_count++;
            $display("Test 1 PASS: Word = %h", d.word);
        end else begin
            $display("Test 1 FAIL: Word unexpected = %h", d.word);
        end

        // Test 2: Read as bytes
        test_count++;
        if (d.bytes.b0 == 8'h78 && d.bytes.b3 == 8'h12) begin
            pass_count++;
            $display("Test 2 PASS: Bytes b0=%h b3=%h", d.bytes.b0, d.bytes.b3);
        end else begin
            $display("Test 2 FAIL: Bytes unexpected");
        end

        // Test 3: Read as halves
        test_count++;
        if (d.halves.low == 16'h5678 && d.halves.high == 16'h1234) begin
            pass_count++;
            $display("Test 3 PASS: Halves low=%h high=%h", d.halves.low, d.halves.high);
        end else begin
            $display("Test 3 FAIL: Halves unexpected");
        end

        // Test 4: Set as byte, read as nibbles
        test_count++;
        b.u8 = 8'hAB;
        if (b.nibbles.high == 4'hA && b.nibbles.low == 4'hB) begin
            pass_count++;
            $display("Test 4 PASS: Nibbles high=%h low=%h", b.nibbles.high, b.nibbles.low);
        end else begin
            $display("Test 4 FAIL: Nibbles unexpected");
        end

        // Test 5: Set nibbles, read byte
        test_count++;
        b.nibbles.high = 4'hC;
        b.nibbles.low = 4'hD;
        if (b.u8 == 8'hCD) begin
            pass_count++;
            $display("Test 5 PASS: Byte from nibbles = %h", b.u8);
        end else begin
            $display("Test 5 FAIL: Byte unexpected = %h", b.u8);
        end

        // Test 6: Modify byte in union
        test_count++;
        d.bytes.b0 = 8'hFF;
        if (d.bytes.b0 == 8'hFF) begin
            pass_count++;
            $display("Test 6 PASS: Byte mod = %h", d.bytes.b0);
        end else begin
            $display("Test 6 FAIL: Mod unexpected");
        end

        // Test 7: Check word after byte mod
        test_count++;
        begin
            static logic [7:0] low_byte;
            // Assigned here so the result does not depend on the order of static initializers.
            low_byte = d.word[7:0];
            if (low_byte == 8'hFF) begin
                pass_count++;
                $display("Test 7 PASS: Word low byte = %h", low_byte);
            end else begin
                $display("Test 7 FAIL: Low unexpected = %h", low_byte);
            end
        end

        // Test 8: Zero union
        test_count++;
        d.word = 0;
        if (d.bytes.b0 == 0 && d.bytes.b3 == 0) begin
            pass_count++;
            $display("Test 8 PASS: Zeroed union");
        end else begin
            $display("Test 8 FAIL: Zero unexpected");
        end

        // Test 9: Max value
        test_count++;
        d.word = 32'hFFFFFFFF;
        if (d.halves.low == 16'hFFFF && d.halves.high == 16'hFFFF) begin
            pass_count++;
            $display("Test 9 PASS: Max halves");
        end else begin
            $display("Test 9 FAIL: Max unexpected");
        end

        // Test 10: Pattern
        test_count++;
        d.word = 32'hAAAA5555;
        if (d.halves.low == 16'h5555 && d.halves.high == 16'hAAAA) begin
            pass_count++;
            $display("Test 10 PASS: Pattern check");
        end else begin
            $display("Test 10 FAIL: Pattern unexpected");
        end

        $display("=== Union Basic Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
