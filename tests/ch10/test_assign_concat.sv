/*
:name: test_assign_concat
:description: Concatenation assignments
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assign_concat.expected
*/
// IEEE 1800-2023 §10.4: Concatenation assignments
module test_assign_concat;
    int pass_count = 0;
    int fail_count = 0;
    logic [7:0] a, b;
    logic [15:0] wide;

    initial begin
        // Test 1: Concat to variable
        a = 8'hAB;
        b = 8'hCD;
        wide = {a, b};
        if (wide == 16'hABCD) begin
            $display("Test 1 PASS: concat to wide = %04h", wide);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %04h", wide);
            fail_count++;
        end

        // Test 2: Concat to wide (pack)
        a = 8'h11;
        b = 8'h22;
        wide = {a, b};
        if (wide == 16'h1122) begin
            $display("Test 2 PASS: pack = %04h", wide);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %04h", wide);
            fail_count++;
        end

        // Test 3: Concat with replication
        a = 8'hAA;
        wide = {2{a}};
        if (wide == 16'hAAAA) begin
            $display("Test 3 PASS: replicate = %04h", wide);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %04h", wide);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
