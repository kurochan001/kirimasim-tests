/*
:name: test_struct_literal
:description: Struct Literal Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_literal.expected
*/
// IEEE 1800-2023 Section 7.2 - Struct Literal Tests
module test_struct_literal;
    int pass_count = 0;
    int fail_count = 0;

    typedef struct {
        int x;
        int y;
    } point_t;

    typedef struct {
        logic [7:0] data;
        logic valid;
    } packet_t;

    initial begin
        point_t p1, p2;
        packet_t pkt;

        $display("=== IEEE 1800-2023 Struct Literal Tests ===");

        $display("Test 1: Named init");
        p1 = '{x: 10, y: 20};
        if (p1.x == 10 && p1.y == 20) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Positional init");
        p2 = '{30, 40};
        if (p2.x == 30 && p2.y == 40) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Packet init");
        pkt = '{data: 8'hAB, valid: 1'b1};
        if (pkt.data == 8'hAB && pkt.valid == 1'b1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Modify field");
        p1.x = 100;
        if (p1.x == 100 && p1.y == 20) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Copy struct");
        p2 = p1;
        if (p2.x == 100 && p2.y == 20) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end

        $display("Test 6: Zero init");
        pkt = '{data: 8'h0, valid: 1'b0};
        if (pkt.data == 0 && pkt.valid == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Field compare");
        p1 = '{x: 5, y: 5};
        if (p1.x == p1.y) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Field sum");
        p1 = '{x: 3, y: 7};
        if (p1.x + p1.y == 10) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
