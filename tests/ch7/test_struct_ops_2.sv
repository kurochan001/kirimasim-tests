/*
:name: test_struct_ops_2
:description: Test for struct operations
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_ops_2.expected
*/
// Test for struct operations
// IEEE 1800-2023 §7.2

module test_struct_ops_2;
    typedef struct {
        int x;
        int y;
        logic [7:0] data;
    } point_t;

    typedef struct packed {
        logic [7:0] a;
        logic [7:0] b;
    } packed_t;

    point_t p1, p2;
    packed_t pk;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Struct initialization
        test_count++;
        p1.x = 10;
        p1.y = 20;
        p1.data = 8'hAB;
        if (p1.x == 10 && p1.y == 20) begin
            $display("Test 1: Struct init PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Struct assignment
        test_count++;
        p2 = p1;
        if (p2.x == 10 && p2.data == 8'hAB) begin
            $display("Test 2: Struct assignment PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Packed struct
        test_count++;
        pk.a = 8'h11;
        pk.b = 8'h22;
        if (pk.a == 8'h11 && pk.b == 8'h22) begin
            $display("Test 3: Packed struct PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Struct literal
        test_count++;
        p1 = '{100, 200, 8'hCD};
        if (p1.x == 100 && p1.y == 200) begin
            $display("Test 4: Struct literal PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Struct member modify
        test_count++;
        p1.x = p1.x + 1;
        if (p1.x == 101) begin
            $display("Test 5: Struct member modify PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
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
