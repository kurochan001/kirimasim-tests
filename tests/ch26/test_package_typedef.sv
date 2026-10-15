/*
:name: test_package_typedef
:description: Package typedefs test
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 6.18 7.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_typedef.expected
*/
// Package typedefs test
package typedef_pkg;
    // Basic typedefs
    typedef logic [7:0] byte_t;
    typedef logic [15:0] halfword_t;
    typedef logic [31:0] word_t;
    typedef logic [63:0] dword_t;

    // Signed typedefs
    typedef logic signed [7:0] sbyte_t;
    typedef logic signed [31:0] sword_t;

    // Enum typedef
    typedef enum logic [1:0] {
        STATE_IDLE = 2'b00,
        STATE_RUN  = 2'b01,
        STATE_DONE = 2'b10,
        STATE_ERR  = 2'b11
    } state_t;

    // Struct typedef
    typedef struct packed {
        logic [7:0] tag;
        logic [23:0] data;
    } tagged_data_t;

    // Union typedef (packed array dimension)
    typedef union packed {
        word_t as_word;
        byte_t [3:0] as_bytes;
    } word_union_t;

    // Array typedef
    typedef byte_t byte_array_t[4];

    // Nested typedef
    typedef tagged_data_t tagged_array_t[2];
endpackage

module test_package_typedef;
    import typedef_pkg::*;

    int pass_count = 0;
    int fail_count = 0;

    // Test variables
    byte_t b1;
    halfword_t hw1;
    word_t w1;
    sbyte_t sb1;
    state_t st1;
    tagged_data_t td1;
    word_union_t wu1;
    byte_array_t ba1;

    initial begin
        #1;

        // Test 1: Basic typedefs
        b1 = 8'hAB;
        hw1 = 16'hCDEF;
        w1 = 32'h12345678;
        if (b1 == 8'hAB && hw1 == 16'hCDEF && w1 == 32'h12345678) begin
            $display("PASS: Test 1 - Basic typedefs (b=%h, hw=%h, w=%h)", b1, hw1, w1);
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic typedefs failed");
            fail_count++;
        end

        // Test 2: Signed typedefs
        sb1 = -100;
        if (sb1 == -100 && sb1 < 0) begin
            $display("PASS: Test 2 - Signed typedef (sb=%0d)", sb1);
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Signed typedef failed");
            fail_count++;
        end

        // Test 3: Enum typedef
        st1 = STATE_RUN;
        if (st1 == STATE_RUN && st1 == 2'b01) begin
            $display("PASS: Test 3 - Enum typedef (state=%b)", st1);
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Enum typedef failed");
            fail_count++;
        end

        // Test 4: Struct typedef
        td1.tag = 8'hFF;
        td1.data = 24'hABCDEF;
        if (td1.tag == 8'hFF && td1.data == 24'hABCDEF) begin
            $display("PASS: Test 4 - Struct typedef (tag=%h, data=%h)", td1.tag, td1.data);
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Struct typedef failed");
            fail_count++;
        end

        // Test 5: Union typedef
        wu1.as_word = 32'hDEADBEEF;
        if (wu1.as_bytes[0] == 8'hEF && wu1.as_bytes[3] == 8'hDE) begin
            $display("PASS: Test 5 - Union typedef (word=%h, byte0=%h, byte3=%h)",
                     wu1.as_word, wu1.as_bytes[0], wu1.as_bytes[3]);
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Union typedef failed");
            fail_count++;
        end

        $display("Test Summary: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
