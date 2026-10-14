/*
:name: test_struct_union
:description: Packed Struct (§7.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2.1 7.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_union.expected
*/
// IEEE 1800-2023 Packed Struct (§7.2)
// Tests packed struct types

module test_struct_union;
    // Packed struct
    typedef struct packed {
        logic [7:0] field_a;
        logic [7:0] field_b;
        logic [7:0] field_c;
        logic [7:0] field_d;
    } data_struct_t;

    // Simple packed union
    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] high;
            logic [15:0] low;
        } halves;
    } simple_union_t;

    initial begin
        data_struct_t ds;
        simple_union_t su;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Struct field assignment
        ds.field_a = 8'hAA;
        ds.field_b = 8'hBB;
        ds.field_c = 8'hCC;
        ds.field_d = 8'hDD;

        if (ds.field_a == 8'hAA && ds.field_d == 8'hDD) begin
            $display("PASS: Struct field assignment works");
            pass_count++;
        end else begin
            $display("FAIL: Struct field assignment failed");
            fail_count++;
        end

        // Test 2: Struct as packed value
        if (ds == 32'hAABBCCDD) begin
            $display("PASS: Struct as packed value = 0x%08X", ds);
            pass_count++;
        end else begin
            $display("FAIL: Struct packed value wrong: 0x%08X", ds);
            fail_count++;
        end

        // Test 3: Struct $bits
        if ($bits(ds) == 32) begin
            $display("PASS: Packed struct is 32 bits");
            pass_count++;
        end else begin
            $display("FAIL: Packed struct size wrong");
            fail_count++;
        end

        // Test 4: Union word access
        su.word = 32'h12345678;
        if (su.word == 32'h12345678) begin
            $display("PASS: Union word = 0x%08X", su.word);
            pass_count++;
        end else begin
            $display("FAIL: Union word wrong");
            fail_count++;
        end

        // Test 5: Union halves access
        if (su.halves.high == 16'h1234) begin
            $display("PASS: Union halves.high = 0x%04X", su.halves.high);
            pass_count++;
        end else begin
            $display("FAIL: Union halves.high wrong: 0x%04X", su.halves.high);
            fail_count++;
        end

        if (su.halves.low == 16'h5678) begin
            $display("PASS: Union halves.low = 0x%04X", su.halves.low);
            pass_count++;
        end else begin
            $display("FAIL: Union halves.low wrong: 0x%04X", su.halves.low);
            fail_count++;
        end

        $display("");
        $display("=== Struct/Union Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
