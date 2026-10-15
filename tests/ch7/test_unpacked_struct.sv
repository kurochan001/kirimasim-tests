/*
:name: test_unpacked_struct
:description: Unpacked Struct Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_struct.expected
*/
// IEEE 1800-2023 Section 7.2 - Unpacked Struct Tests
module test_unpacked_struct;
    int pass_count = 0;
    int fail_count = 0;

    typedef struct {
        int x;
        int y;
    } point_t;

    typedef struct {
        string name;
        int value;
    } named_val_t;

    initial begin
        point_t p1, p2;
        named_val_t nv;

        $display("=== IEEE 1800-2023 Unpacked Struct Tests ===");

        // Test 1: Assign fields
        $display("Test 1: Assign fields");
        p1.x = 10;
        p1.y = 20;
        if (p1.x == 10 && p1.y == 20) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        // Test 2: Pattern assign
        $display("Test 2: Pattern assign");
        p1 = '{30, 40};
        if (p1.x == 30 && p1.y == 40) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: x=%0d y=%0d", p1.x, p1.y); fail_count++; end

        // Test 3: Named assign
        $display("Test 3: Named assign");
        p1 = '{x: 50, y: 60};
        if (p1.x == 50 && p1.y == 60) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Copy struct
        $display("Test 4: Copy struct");
        p1 = '{100, 200};
        p2.x = p1.x;
        p2.y = p1.y;
        if (p2.x == 100 && p2.y == 200) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: String field
        $display("Test 5: String field");
        nv.name = "test";
        nv.value = 42;
        if (nv.name == "test" && nv.value == 42) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        // Test 6: Negative values
        $display("Test 6: Negative values");
        p1.x = -10;
        p1.y = -20;
        if (p1.x == -10 && p1.y == -20) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        // Test 7: Zero values
        $display("Test 7: Zero values");
        p1 = '{0, 0};
        if (p1.x == 0 && p1.y == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        // Test 8: Modify one field
        $display("Test 8: Modify one");
        p1 = '{5, 10};
        p1.x = 99;
        if (p1.x == 99 && p1.y == 10) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
