/*
:name: test_cast_logic
:description: Logic type casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_logic.expected
*/
// IEEE 1800-2023 §6.24: Logic type casts
module test_cast_logic;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] lval8;
    logic [15:0] lval16;
    int ival;

    initial begin
        // Test 1: Int to 8-bit logic
        ival = 255;
        lval8 = 8'(ival);
        if (lval8 == 8'hFF) begin
            $display("Test 1 PASS: int to 8-bit = %02h", lval8);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", lval8);
            fail_count++;
        end

        // Test 2: Int to 16-bit logic
        ival = 32'hABCD;
        lval16 = 16'(ival);
        if (lval16 == 16'hABCD) begin
            $display("Test 2 PASS: int to 16-bit = %04h", lval16);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %04h", lval16);
            fail_count++;
        end

        // Test 3: Truncation on cast
        ival = 32'h12345678;
        lval8 = 8'(ival);
        if (lval8 == 8'h78) begin
            $display("Test 3 PASS: truncate to 8-bit = %02h", lval8);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", lval8);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
