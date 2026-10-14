/*
:name: test_reg_wire_types
:description: Reg and Wire Type Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 6.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_reg_wire_types.expected
*/
// IEEE 1800-2023 Section 6 - Reg and Wire Type Tests
// Tests: reg, wire, logic, integer types

module test_reg_wire_types;
    int pass_count = 0;
    int fail_count = 0;

    reg [7:0] r1;
    wire [7:0] w1;
    logic [7:0] l1;
    integer i1;
    bit [7:0] b1;
    byte b2;
    shortint si;
    longint li;

    assign w1 = r1;

    initial begin
        $display("=== IEEE 1800-2023 Reg Wire Types Tests ===");

        // Test 1: reg assignment
        $display("Test 1: reg assignment");
        r1 = 8'hAA;
        if (r1 == 8'hAA) begin
            $display("Test 1 PASS: r1=%h", r1);
            pass_count++;
        end else begin
            $display("Test 1 FAIL");
            fail_count++;
        end

        // Test 2: wire propagation
        $display("Test 2: wire propagation");
        #1;
        if (w1 == 8'hAA) begin
            $display("Test 2 PASS: w1=%h", w1);
            pass_count++;
        end else begin
            $display("Test 2 FAIL");
            fail_count++;
        end

        // Test 3: logic type
        $display("Test 3: logic type");
        l1 = 8'hBB;
        if (l1 == 8'hBB) begin
            $display("Test 3 PASS: l1=%h", l1);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        // Test 4: integer type
        $display("Test 4: integer type");
        i1 = -100;
        if (i1 == -100) begin
            $display("Test 4 PASS: i1=%0d", i1);
            pass_count++;
        end else begin
            $display("Test 4 FAIL");
            fail_count++;
        end

        // Test 5: bit type (2-state)
        $display("Test 5: bit type (2-state)");
        b1 = 8'hCC;
        if (b1 == 8'hCC) begin
            $display("Test 5 PASS: b1=%h", b1);
            pass_count++;
        end else begin
            $display("Test 5 FAIL");
            fail_count++;
        end

        // Test 6: byte type
        $display("Test 6: byte type");
        b2 = -50;
        if (b2 == -50) begin
            $display("Test 6 PASS: b2=%0d", b2);
            pass_count++;
        end else begin
            $display("Test 6 FAIL");
            fail_count++;
        end

        // Test 7: shortint type
        $display("Test 7: shortint type");
        si = 32767;
        if (si == 32767) begin
            $display("Test 7 PASS: si=%0d", si);
            pass_count++;
        end else begin
            $display("Test 7 FAIL");
            fail_count++;
        end

        // Test 8: longint type (IEEE 1800-2023 §6.11.2 - 64-bit signed integer)
        $display("Test 8: longint type");
        li = 64'h123456789ABCDEF0;  // 64-bit value
        if (li == 64'h123456789ABCDEF0) begin
            $display("Test 8 PASS: li=%h", li);
            pass_count++;
        end else begin
            $display("Test 8 FAIL: got %h", li);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");
        $finish;
    end
endmodule
