/*
:name: test_cast_bit
:description: 2-state type casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 10.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_bit.expected
*/
// IEEE 1800-2023 §6.24: 2-state type casts
module test_cast_bit;
    int pass_count = 0;
    int fail_count = 0;
    bit [7:0] bval;
    logic [7:0] lval;
    int ival;

    initial begin
        // Test 1: Int to bit array
        ival = 255;
        bval = ival;  // Implicit conversion
        if (bval == 8'hFF) begin
            $display("Test 1 PASS: int to bit = %02h", bval);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %02h", bval);
            fail_count++;
        end

        // Test 2: Logic to bit array
        lval = 8'hAB;
        bval = lval;  // Implicit conversion
        if (bval == 8'hAB) begin
            $display("Test 2 PASS: logic to bit = %02h", bval);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %02h", bval);
            fail_count++;
        end

        // Test 3: Zero value
        ival = 0;
        bval = ival;
        if (bval == 8'h00) begin
            $display("Test 3 PASS: zero = %02h", bval);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %02h", bval);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
