/*
:name: test_cast_packed_struct_member
:description: , Section 7.2 - $cast with packed struct member access
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 7.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_packed_struct_member.expected
*/
// IEEE 1800-2023 Section 6.24.2, Section 7.2 - $cast with packed struct member access
// Test case for $cast to packed struct members

module test_cast_packed_struct_member;

    // Define packed struct types
    typedef struct packed {
        logic [7:0] high;
        logic [7:0] low;
    } word_t;

    typedef struct packed {
        logic [3:0] tag;
        logic [11:0] data;
    } tagged_data_t;

    // Nested packed struct
    typedef struct packed {
        word_t word;
        logic [15:0] extra;
    } nested_packed_t;

    // Class to hold packed struct
    class Container;
        word_t word_member;
        tagged_data_t tagged_member;

        function new();
            word_member = 16'h0000;
            tagged_member = 16'h0000;
        endfunction
    endclass

    initial begin
        word_t w;
        tagged_data_t t;
        nested_packed_t n;
        Container c;
        int success;
        static int test_count = 0;
        static int pass_count = 0;

        $display("=== Test 1: $cast to packed struct high byte ===");
        test_count++;
        w = 16'h0000;
        success = $cast(w.high, 8'hAB);
        if (success && w.high == 8'hAB) begin
            $display("PASS: $cast(w.high, 8'hAB) succeeded, w.high = %0h", w.high);
            pass_count++;
        end else begin
            $display("FAIL: $cast(w.high, 8'hAB) failed or value mismatch");
        end

        $display("");
        $display("=== Test 2: $cast to packed struct low byte ===");
        test_count++;
        success = $cast(w.low, 8'hCD);
        if (success && w.low == 8'hCD) begin
            $display("PASS: $cast(w.low, 8'hCD) succeeded, w.low = %0h", w.low);
            pass_count++;
        end else begin
            $display("FAIL: $cast(w.low, 8'hCD) failed or value mismatch");
        end

        $display("");
        $display("=== Test 3: Verify full packed struct value ===");
        test_count++;
        if (w == 16'hABCD) begin
            $display("PASS: w = %0h (expected ABCD)", w);
            pass_count++;
        end else begin
            $display("FAIL: w = %0h (expected ABCD)", w);
        end

        $display("");
        $display("=== Test 4: $cast to tagged_data struct fields ===");
        test_count++;
        t = 16'h0000;
        success = $cast(t.tag, 4'hF);
        if (success && t.tag == 4'hF) begin
            $display("PASS: $cast(t.tag, 4'hF) succeeded, t.tag = %0h", t.tag);
            pass_count++;
        end else begin
            $display("FAIL: $cast(t.tag, 4'hF) failed or value mismatch");
        end

        $display("");
        $display("=== Test 5: $cast to tagged_data data field ===");
        test_count++;
        success = $cast(t.data, 12'hBEE);
        if (success && t.data == 12'hBEE) begin
            $display("PASS: $cast(t.data, 12'hBEE) succeeded, t.data = %0h", t.data);
            pass_count++;
        end else begin
            $display("FAIL: $cast(t.data, 12'hBEE) failed or value mismatch");
        end

        $display("");
        $display("=== Test 6: $cast to class's packed struct member ===");
        test_count++;
        c = new();
        success = $cast(c.word_member.high, 8'h12);
        if (success && c.word_member.high == 8'h12) begin
            $display("PASS: $cast(c.word_member.high, 8'h12) succeeded (success=%0d)", success);
            pass_count++;
        end else begin
            $display("FAIL: $cast(c.word_member.high, 8'h12) failed (success=%0d)", success);
        end

        $display("");
        $display("=== Test 7: $cast to nested packed struct ===");
        test_count++;
        n = 32'h0;
        success = $cast(n.word.high, 8'hDE);
        if (success && n.word.high == 8'hDE) begin
            $display("PASS: $cast(n.word.high, 8'hDE) succeeded");
            pass_count++;
        end else begin
            $display("FAIL: $cast(n.word.high, 8'hDE) failed or value mismatch");
        end

        $display("");
        $display("=== Test Summary ===");
        $display("Tests: %0d/%0d passed", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("SUCCESS: All packed struct $cast tests passed");
        end else begin
            $display("FAIL: Some tests failed");
            $fatal(1, "Test failure");
        end

        $finish;
    end

endmodule
