/*
:name: test_member_struct
:description: Test struct member access corner cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_struct.expected
*/
// Test struct member access corner cases
module test_member_struct;
    int pass_count = 0;
    int total_tests = 8;

    // Simple struct
    typedef struct {
        logic [7:0] data;
        logic valid;
    } simple_t;

    // Nested struct
    typedef struct {
        logic [15:0] addr;
        simple_t payload;
    } nested_t;

    // Packed struct
    typedef struct packed {
        logic [3:0] tag;
        logic [11:0] value;
    } packed_t;

    // Struct with array member
    typedef struct {
        logic [7:0] bytes[4];
        int count;
    } array_struct_t;

    // Deeply nested struct
    typedef struct {
        nested_t level1;
        packed_t level1_packed;
    } deep_t;

    simple_t simple_var;
    nested_t nested_var;
    packed_t packed_var;
    array_struct_t array_struct;
    deep_t deep_var;
    simple_t struct_array[3];

    initial begin
        // Test 1: Simple struct member access
        simple_var.data = 8'hAB;
        simple_var.valid = 1'b1;
        if (simple_var.data == 8'hAB && simple_var.valid == 1'b1) begin
            $display("Test 1 PASS: simple_var.data=%h, valid=%b", simple_var.data, simple_var.valid);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: Simple struct access failed");
        end

        // Test 2: Nested struct member access
        nested_var.addr = 16'hCAFE;
        nested_var.payload.data = 8'hCD;
        nested_var.payload.valid = 1'b0;
        if (nested_var.addr == 16'hCAFE && nested_var.payload.data == 8'hCD) begin
            $display("Test 2 PASS: Nested struct access works");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: Nested struct access failed");
        end

        // Test 3: Packed struct as whole
        packed_var = 16'hABCD;  // tag=A, value=BCD
        if (packed_var.tag == 4'hA && packed_var.value == 12'hBCD) begin
            $display("Test 3 PASS: packed_var.tag=%h, value=%h", packed_var.tag, packed_var.value);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: packed_var.tag=%h, value=%h", packed_var.tag, packed_var.value);
        end

        // Test 4: Packed struct member write
        packed_var.tag = 4'hF;
        packed_var.value = 12'h123;
        if (packed_var == 16'hF123) begin
            $display("Test 4 PASS: Packed struct as whole = %h", packed_var);
            pass_count++;
        end else begin
            $display("Test 4 FAIL: Packed struct = %h, expected F123", packed_var);
        end

        // Test 5: Struct with array member
        array_struct.bytes[0] = 8'h11;
        array_struct.bytes[1] = 8'h22;
        array_struct.bytes[2] = 8'h33;
        array_struct.bytes[3] = 8'h44;
        array_struct.count = 4;
        if (array_struct.bytes[2] == 8'h33 && array_struct.count == 4) begin
            $display("Test 5 PASS: Array member access works");
            pass_count++;
        end else begin
            $display("Test 5 FAIL: Array member access failed");
        end

        // Test 6: Deeply nested struct
        deep_var.level1.addr = 16'hDEAD;
        deep_var.level1.payload.data = 8'hBE;
        deep_var.level1_packed.tag = 4'hE;
        deep_var.level1_packed.value = 12'hF00;
        if (deep_var.level1.addr == 16'hDEAD && deep_var.level1.payload.data == 8'hBE) begin
            $display("Test 6 PASS: Deep nested struct access works");
            pass_count++;
        end else begin
            $display("Test 6 FAIL: Deep nested access failed");
        end

        // Test 7: Array of structs
        struct_array[0].data = 8'hAA;
        struct_array[0].valid = 1'b1;
        struct_array[1].data = 8'hBB;
        struct_array[1].valid = 1'b0;
        struct_array[2].data = 8'hCC;
        struct_array[2].valid = 1'b1;
        if (struct_array[1].data == 8'hBB && struct_array[2].valid == 1'b1) begin
            $display("Test 7 PASS: Array of structs access works");
            pass_count++;
        end else begin
            $display("Test 7 FAIL: Array of structs failed");
        end

        // Test 8: Struct member computed index
        begin
            static int idx = 1;
            struct_array[idx].data = 8'hDD;
            if (struct_array[1].data == 8'hDD) begin
                $display("Test 8 PASS: Computed index struct access works");
                pass_count++;
            end else begin
                $display("Test 8 FAIL: Computed index failed");
            end
        end

        if (pass_count == total_tests) $display("PASS: member_struct (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: member_struct (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
