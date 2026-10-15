/*
:name: test_struct_basic_edge_cases
:description: Struct basic edge cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 10.9.2 11.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_basic_edge_cases.expected
*/
// IEEE 1800-2023 §7.2: Struct basic edge cases
// Tests for struct types

module test_struct_basic_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    typedef struct {
        int x;
        int y;
    } point_t;

    typedef struct {
        logic [7:0] data;
        logic valid;
        logic [3:0] addr;
    } packet_t;

    typedef struct {
        int a, b, c;
    } triple_t;

    initial begin
        point_t p1, p2;
        packet_t pkt;
        triple_t tr;

        // Test 1: Struct member assignment
        test_count++;
        p1.x = 10;
        p1.y = 20;
        if (p1.x == 10 && p1.y == 20) begin
            pass_count++;
            $display("Test 1 PASS: Point x=%0d y=%0d", p1.x, p1.y);
        end else begin
            $display("Test 1 FAIL: Point unexpected");
        end

        // Test 2: Struct copy
        test_count++;
        p2 = p1;
        if (p2.x == 10 && p2.y == 20) begin
            pass_count++;
            $display("Test 2 PASS: Copy x=%0d y=%0d", p2.x, p2.y);
        end else begin
            $display("Test 2 FAIL: Copy unexpected");
        end

        // Test 3: Independent after copy
        test_count++;
        p2.x = 100;
        if (p1.x == 10 && p2.x == 100) begin
            pass_count++;
            $display("Test 3 PASS: Independent p1=%0d p2=%0d", p1.x, p2.x);
        end else begin
            $display("Test 3 FAIL: Indep unexpected");
        end

        // Test 4: Packet struct
        test_count++;
        pkt.data = 8'hAB;
        pkt.valid = 1;
        pkt.addr = 4'h5;
        if (pkt.data == 8'hAB && pkt.valid == 1) begin
            pass_count++;
            $display("Test 4 PASS: Packet data=%h valid=%b", pkt.data, pkt.valid);
        end else begin
            $display("Test 4 FAIL: Packet unexpected");
        end

        // Test 5: Triple struct
        test_count++;
        tr.a = 1;
        tr.b = 2;
        tr.c = 3;
        if (tr.a + tr.b + tr.c == 6) begin
            pass_count++;
            $display("Test 5 PASS: Triple sum = %0d", tr.a + tr.b + tr.c);
        end else begin
            $display("Test 5 FAIL: Triple unexpected");
        end

        // Test 6: Zero init
        test_count++;
        p1 = '{0, 0};
        if (p1.x == 0 && p1.y == 0) begin
            pass_count++;
            $display("Test 6 PASS: Zero init");
        end else begin
            $display("Test 6 FAIL: Zero unexpected");
        end

        // Test 7: Named init
        test_count++;
        p1 = '{x: 5, y: 10};
        if (p1.x == 5 && p1.y == 10) begin
            pass_count++;
            $display("Test 7 PASS: Named init x=%0d y=%0d", p1.x, p1.y);
        end else begin
            $display("Test 7 FAIL: Named unexpected");
        end

        // Test 8: Default values
        test_count++;
        p1 = '{default: 42};
        if (p1.x == 42 && p1.y == 42) begin
            pass_count++;
            $display("Test 8 PASS: Default all = %0d", p1.x);
        end else begin
            $display("Test 8 FAIL: Default unexpected");
        end

        // Test 9: Struct in expression
        test_count++;
        p1.x = 3;
        p1.y = 4;
        begin
            static int dist_sq;
            // Assigned here so the result does not depend on the order of static initializers.
            dist_sq = p1.x * p1.x + p1.y * p1.y;
            if (dist_sq == 25) begin
                pass_count++;
                $display("Test 9 PASS: Distance sq = %0d", dist_sq);
            end else begin
                $display("Test 9 FAIL: Dist unexpected = %0d", dist_sq);
            end
        end

        // Test 10: Struct comparison
        test_count++;
        p1.x = 1;
        p1.y = 2;
        p2.x = 1;
        p2.y = 2;
        if (p1 == p2) begin
            pass_count++;
            $display("Test 10 PASS: Struct equal");
        end else begin
            $display("Test 10 FAIL: Equal unexpected");
        end

        $display("=== Struct Basic Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
