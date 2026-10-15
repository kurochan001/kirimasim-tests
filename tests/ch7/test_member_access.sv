/*
:name: test_member_access
:description: Test for member access
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_member_access.expected
*/
// Test for member access
// IEEE 1800-2023 §7.2

module test_member_access;
    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
        logic [15:0] c;
    } my_struct;

    my_struct s;
    logic [7:0] arr[4];
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Struct member write
        test_count++;
        s.a = 8'hAA;
        s.b = 8'hBB;
        s.c = 16'hCCDD;
        if (s.a == 8'hAA) begin
            $display("Test 1: Struct write PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL s.a=%h", s.a);
        end

        // Test 2: Struct member read
        test_count++;
        if (s.b == 8'hBB && s.c == 16'hCCDD) begin
            $display("Test 2: Struct read PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Array element write
        test_count++;
        arr[0] = 8'h10;
        arr[1] = 8'h20;
        arr[2] = 8'h30;
        arr[3] = 8'h40;
        if (arr[0] == 8'h10) begin
            $display("Test 3: Array write PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Array element read
        test_count++;
        if (arr[1] == 8'h20 && arr[3] == 8'h40) begin
            $display("Test 4: Array read PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Indexed access with variable
        test_count++;
        begin
            static int idx = 2;
            if (arr[idx] == 8'h30) begin
                $display("Test 5: Variable index PASS");
                pass_count++;
            end else begin
                $display("Test 5: FAIL arr[%0d]=%h", idx, arr[idx]);
            end
        end

        // Test 6: Struct to bits
        test_count++;
        if ($bits(s) == 32) begin
            $display("Test 6: Struct bits PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL bits=%0d", $bits(s));
        end

        // Test 7: Nested struct access simulation
        test_count++;
        s.a = s.b;
        if (s.a == 8'hBB) begin
            $display("Test 7: Member copy PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL");
        end

        // Test 8: Array bounds
        test_count++;
        if ($size(arr) == 4) begin
            $display("Test 8: Array size PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL size=%0d", $size(arr));
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
