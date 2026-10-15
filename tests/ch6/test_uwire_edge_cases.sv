/*
:name: test_uwire_edge_cases
:description: uwire nets with a single continuous assignment
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_uwire_edge_cases.expected
*/
// IEEE 1800-2023 §6.6.2: Uwire edge cases
// Tests for unresolved wire type (single driver only)

module test_uwire_edge_cases;
    int pass_count = 0;
    int test_count = 0;

    uwire uw;
    uwire [7:0] uwvec;

    logic driver;
    logic [7:0] vec_driver;

    assign uw = driver;
    assign uwvec = vec_driver;

    initial begin
        driver = 0;
        vec_driver = 0;
        #1;

        // Test 1: Uwire low
        test_count++;
        if (uw == 0) begin
            pass_count++;
            $display("Test 1 PASS: uw = %b", uw);
        end else begin
            $display("Test 1 FAIL: uw unexpected = %b", uw);
        end

        // Test 2: Uwire high
        test_count++;
        driver = 1;
        #1;
        if (uw == 1) begin
            pass_count++;
            $display("Test 2 PASS: uw = %b", uw);
        end else begin
            $display("Test 2 FAIL: uw unexpected = %b", uw);
        end

        // Test 3: Vector low
        test_count++;
        vec_driver = 8'h00;
        #1;
        if (uwvec == 8'h00) begin
            pass_count++;
            $display("Test 3 PASS: uwvec = %h", uwvec);
        end else begin
            $display("Test 3 FAIL: uwvec unexpected = %h", uwvec);
        end

        // Test 4: Vector pattern
        test_count++;
        vec_driver = 8'hAA;
        #1;
        if (uwvec == 8'hAA) begin
            pass_count++;
            $display("Test 4 PASS: uwvec = %h", uwvec);
        end else begin
            $display("Test 4 FAIL: uwvec unexpected = %h", uwvec);
        end

        // Test 5: Vector all high
        test_count++;
        vec_driver = 8'hFF;
        #1;
        if (uwvec == 8'hFF) begin
            pass_count++;
            $display("Test 5 PASS: uwvec = %h", uwvec);
        end else begin
            $display("Test 5 FAIL: uwvec unexpected = %h", uwvec);
        end

        // Test 6: Bit select
        test_count++;
        vec_driver = 8'b1010_0101;
        #1;
        if (uwvec[0] == 1 && uwvec[7] == 1) begin
            pass_count++;
            $display("Test 6 PASS: Bits correct");
        end else begin
            $display("Test 6 FAIL: Bit unexpected");
        end

        // Test 7: Part select
        test_count++;
        if (uwvec[3:0] == 4'h5) begin
            pass_count++;
            $display("Test 7 PASS: [3:0] = %h", uwvec[3:0]);
        end else begin
            $display("Test 7 FAIL: Part unexpected");
        end

        // Test 8: Upper part select
        test_count++;
        if (uwvec[7:4] == 4'hA) begin
            pass_count++;
            $display("Test 8 PASS: [7:4] = %h", uwvec[7:4]);
        end else begin
            $display("Test 8 FAIL: Part unexpected");
        end

        // Test 9: Value change
        test_count++;
        vec_driver = 8'h12;
        #1;
        if (uwvec == 8'h12) begin
            pass_count++;
            $display("Test 9 PASS: Change = %h", uwvec);
        end else begin
            $display("Test 9 FAIL: Change unexpected = %h", uwvec);
        end

        // Test 10: Back to zero
        test_count++;
        vec_driver = 8'h00;
        #1;
        if (uwvec == 8'h00) begin
            pass_count++;
            $display("Test 10 PASS: Zero = %h", uwvec);
        end else begin
            $display("Test 10 FAIL: Zero unexpected = %h", uwvec);
        end

        $display("=== Uwire Edge Cases ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
