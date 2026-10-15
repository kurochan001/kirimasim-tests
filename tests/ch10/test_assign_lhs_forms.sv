/*
:name: test_assign_lhs_forms
:description: Assignments to bit selects, part selects, indexed part selects, array elements and struct members
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1 11.5.1 7.4 10.9.1
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_lhs_forms.expected
*/
// Assignments to bit selects, part selects, indexed part selects, array elements and struct members

module test_assign_lhs_forms;
    int pass_count = 0;
    int fail_count = 0;

    // Test variables
    logic [31:0] vec;
    logic [7:0] byte_arr[4];
    logic [3:0][7:0] packed_2d;
    int int_arr[3];

    // Struct for member assignment
    typedef struct {
        logic [7:0] a;
        logic [7:0] b;
        logic [15:0] c;
    } my_struct_t;

    my_struct_t s;

    initial begin
        $display("=== Assignment Patterns Test ===");

        // Test simple assignment
        vec = 32'hDEADBEEF;
        if (vec == 32'hDEADBEEF) begin
            $display("PASS: Simple assignment vec = 32'hDEADBEEF");
            pass_count++;
        end else begin
            $display("FAIL: Simple assignment");
            fail_count++;
        end

        // Test bit select assignment
        vec = 32'h00000000;
        vec[0] = 1'b1;
        vec[31] = 1'b1;
        if (vec == 32'h80000001) begin
            $display("PASS: Bit select assignment vec[0]=1, vec[31]=1");
            pass_count++;
        end else begin
            $display("FAIL: Bit select assignment, got %h", vec);
            fail_count++;
        end

        // Test part select assignment
        vec = 32'h00000000;
        vec[15:8] = 8'hAB;
        if (vec == 32'h0000AB00) begin
            $display("PASS: Part select assignment vec[15:8]=8'hAB");
            pass_count++;
        end else begin
            $display("FAIL: Part select assignment, got %h", vec);
            fail_count++;
        end

        // Test indexed part select (ascending)
        vec = 32'h00000000;
        vec[8+:8] = 8'hCD;
        if (vec[15:8] == 8'hCD) begin
            $display("PASS: Indexed part select (ascending) vec[8+:8]=8'hCD");
            pass_count++;
        end else begin
            $display("FAIL: Indexed part select ascending, got vec[15:8]=%h", vec[15:8]);
            fail_count++;
        end

        // Test indexed part select (descending)
        vec = 32'h00000000;
        vec[23-:8] = 8'hEF;
        if (vec[23:16] == 8'hEF) begin
            $display("PASS: Indexed part select (descending) vec[23-:8]=8'hEF");
            pass_count++;
        end else begin
            $display("FAIL: Indexed part select descending, got vec[23:16]=%h", vec[23:16]);
            fail_count++;
        end

        // Test array element assignment
        byte_arr[0] = 8'h11;
        byte_arr[1] = 8'h22;
        byte_arr[2] = 8'h33;
        byte_arr[3] = 8'h44;
        if (byte_arr[0] == 8'h11 && byte_arr[3] == 8'h44) begin
            $display("PASS: Array element assignment");
            pass_count++;
        end else begin
            $display("FAIL: Array element assignment");
            fail_count++;
        end

        // Test packed 2D array assignment
        packed_2d[0] = 8'hAA;
        packed_2d[1] = 8'hBB;
        packed_2d[2] = 8'hCC;
        packed_2d[3] = 8'hDD;
        if (packed_2d == 32'hDDCCBBAA) begin
            $display("PASS: Packed 2D array assignment");
            pass_count++;
        end else begin
            $display("FAIL: Packed 2D array assignment, got %h", packed_2d);
            fail_count++;
        end

        // Test struct member assignment
        s.a = 8'h12;
        s.b = 8'h34;
        s.c = 16'h5678;
        if (s.a == 8'h12 && s.b == 8'h34 && s.c == 16'h5678) begin
            $display("PASS: Struct member assignment");
            pass_count++;
        end else begin
            $display("FAIL: Struct member assignment");
            fail_count++;
        end

        // Test array literal assignment
        int_arr = '{100, 200, 300};
        if (int_arr[0] == 100 && int_arr[1] == 200 && int_arr[2] == 300) begin
            $display("PASS: Array literal assignment");
            pass_count++;
        end else begin
            $display("FAIL: Array literal assignment");
            fail_count++;
        end

        // Test variable index assignment
        begin
            int idx;
            idx = 1;
            int_arr[idx] = 999;
            if (int_arr[1] == 999) begin
                $display("PASS: Variable index assignment");
                pass_count++;
            end else begin
                $display("FAIL: Variable index assignment");
                fail_count++;
            end
        end

        // Test chained bit select assignment
        vec = 32'h00000000;
        begin
            int i;
            for (i = 0; i < 8; i++) begin
                vec[i] = 1'b1;
            end
        end
        if (vec[7:0] == 8'hFF) begin
            $display("PASS: Chained bit select in loop");
            pass_count++;
        end else begin
            $display("FAIL: Chained bit select in loop, got %h", vec[7:0]);
            fail_count++;
        end

        // Summary
        $display("\n=== Assignment Patterns Test Summary ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;
    end
endmodule
