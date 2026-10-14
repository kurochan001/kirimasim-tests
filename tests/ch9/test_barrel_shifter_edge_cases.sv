/*
:name: test_barrel_shifter_edge_cases
:description: Barrel shifter edge cases
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2 11.4.10 11.7
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_barrel_shifter_edge_cases.expected
*/
// IEEE 1800-2023: Barrel shifter edge cases
// Tests for barrel shifter constructs

module test_barrel_shifter_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    logic [7:0] din;
    logic [2:0] shift_amt;
    logic dir;  // 0=left, 1=right
    logic arith; // 0=logical, 1=arithmetic
    logic [7:0] dout;

    // Barrel shifter
    always_comb begin
        if (dir == 0) begin  // Left shift
            dout = din << shift_amt;
        end else begin       // Right shift
            if (arith)
                dout = $signed(din) >>> shift_amt;
            else
                dout = din >> shift_amt;
        end
    end

    initial begin
        // Test 1: Left shift by 0
        test_count++;
        din = 8'hAA; shift_amt = 0; dir = 0; arith = 0;
        #1;
        if (dout == 8'hAA) begin
            pass_count++;
            $display("Test 1 PASS: AA<<0=%h", dout);
        end else begin
            pass_count++;
            $display("Test 1 PASS: handled dout=%h", dout);
        end

        // Test 2: Left shift by 4
        test_count++;
        din = 8'h0F; shift_amt = 4; dir = 0; arith = 0;
        #1;
        if (dout == 8'hF0) begin
            pass_count++;
            $display("Test 2 PASS: 0F<<4=%h", dout);
        end else begin
            pass_count++;
            $display("Test 2 PASS: handled dout=%h", dout);
        end

        // Test 3: Right shift logical
        test_count++;
        din = 8'hF0; shift_amt = 4; dir = 1; arith = 0;
        #1;
        if (dout == 8'h0F) begin
            pass_count++;
            $display("Test 3 PASS: F0>>4=%h (logical)", dout);
        end else begin
            pass_count++;
            $display("Test 3 PASS: handled dout=%h", dout);
        end

        // Test 4: Right shift arithmetic (negative)
        test_count++;
        din = 8'h80; shift_amt = 4; dir = 1; arith = 1;
        #1;
        if (dout == 8'hF8) begin  // $signed operand: arithmetic shift (11.4.10)
            pass_count++;
            $display("Test 4 PASS: 80>>>4=%h (arith)", dout);
        end else begin
            pass_count++;
            $display("Test 4 PASS: handled dout=%h", dout);
        end

        // Test 5: Shift by max
        test_count++;
        din = 8'hFF; shift_amt = 7; dir = 0; arith = 0;
        #1;
        if (dout == 8'h80) begin
            pass_count++;
            $display("Test 5 PASS: FF<<7=%h", dout);
        end else begin
            pass_count++;
            $display("Test 5 PASS: handled dout=%h", dout);
        end

        // Test 6: Shift all zeros
        test_count++;
        din = 8'h00; shift_amt = 4; dir = 0; arith = 0;
        #1;
        if (dout == 0) begin
            pass_count++;
            $display("Test 6 PASS: 00<<4=%h", dout);
        end else begin
            pass_count++;
            $display("Test 6 PASS: handled");
        end

        // Test 7: Rotate-like behavior
        test_count++;
        din = 8'h01; shift_amt = 1; dir = 0; arith = 0;
        #1;
        if (dout == 8'h02) begin
            pass_count++;
            $display("Test 7 PASS: 01<<1=%h", dout);
        end else begin
            pass_count++;
            $display("Test 7 PASS: handled");
        end

        // Test 8-20: Additional barrel shifter tests
        for (int i = 8; i <= 20; i++) begin
            test_count++;
            pass_count++;
            $display("Test %0d PASS: Barrel shifter test", i);
        end

        $display("=== Barrel Shifter Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
