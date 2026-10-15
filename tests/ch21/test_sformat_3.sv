/*
:name: test_sformat_3
:description: $sformat, $sformatf string formatting
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.3 21.2.1.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sformat_3.expected
*/
// $sformat, $sformatf string formatting
module test_sformat;
    string str1, str2, str3;
    reg [31:0] value;
    real rval;
    integer pass_count;

    initial begin
        pass_count = 0;
        value = 32'hDEADBEEF;
        rval = 3.14159;

        // Test 1: $sformat with hex
        $sformat(str1, "Value: %h", value);
        if (str1 == "Value: deadbeef") begin
            $display("Test 1: $sformat hex - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 1: $sformat hex - FAIL (got '%s')", str1);
        end

        // Test 2: $sformatf with decimal
        str2 = $sformatf("Decimal: %0d", 12345);
        if (str2 == "Decimal: 12345") begin
            $display("Test 2: $sformatf decimal - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 2: $sformatf decimal - FAIL (got '%s')", str2);
        end

        // Test 3: $sformatf with multiple arguments
        str3 = $sformatf("A=%0d B=%h C=%b", 10, 8'hAB, 4'b1010);
        if (str3 == "A=10 B=ab C=1010") begin
            $display("Test 3: $sformatf multi-arg - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 3: $sformatf multi-arg - FAIL (got '%s')", str3);
        end

        // Test 4: $sformat with string argument
        $sformat(str1, "Hello %s!", "World");
        if (str1 == "Hello World!") begin
            $display("Test 4: $sformat string arg - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 4: $sformat string arg - FAIL (got '%s')", str1);
        end

        // Test 5: $sformatf with real number
        str2 = $sformatf("Pi = %f", rval);
        // %f follows the C format: six digits after the point (21.2.1.1)
        if (str2 == "Pi = 3.141590") begin
            $display("Test 5: $sformatf real - PASS");
            pass_count = pass_count + 1;
        end else begin
            $display("Test 5: $sformatf real - FAIL (got '%s')", str2);
        end

        if (pass_count == 5)
            $display("All sformat tests PASS");
        else
            $display("Some tests FAIL: %0d/5 passed", pass_count);

        $finish;
    end
endmodule
