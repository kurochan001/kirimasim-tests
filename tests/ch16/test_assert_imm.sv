/*
:name: test_assert_imm
:description: Immediate assertions with pass and fail action blocks
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assert_imm.expected
*/
// Immediate assertions with pass and fail action blocks

module test_assert_imm;
    int pass_count = 0;
    int total_tests = 0;

    // Test variables
    int a, b, result;
    logic [7:0] data;
    bit flag;
    int error_count = 0;

    // Task to check assertion behavior
    task automatic check_assert(input bit condition, input string name);
        total_tests++;
        if (condition) begin
            pass_count++;
            $display("PASS: %s", name);
        end else begin
            $display("FAIL: %s", name);
        end
    endtask

    initial begin
        // Test 1: simple assert true
        total_tests++;
        a = 5;
        assert(a == 5) pass_count++;
        else $display("FAIL: simple assert true");
        $display("PASS: simple assert true");

        // Test 2: assert with else action
        total_tests++;
        a = 10;
        assert(a > 5) begin
            pass_count++;
            $display("PASS: assert with else (pass path)");
        end else begin
            $display("FAIL: assert with else");
        end

        // Test 3: assert with expression
        total_tests++;
        a = 3;
        b = 4;
        result = a + b;
        assert(result == 7) begin
            pass_count++;
            $display("PASS: assert expression");
        end else $display("FAIL: assert expression");

        // Test 4: assert with comparison operators
        total_tests++;
        data = 8'hFF;
        assert(data >= 8'h00 && data <= 8'hFF) begin
            pass_count++;
            $display("PASS: assert range check");
        end else $display("FAIL: range check");

        // Test 5: assert with bitwise operation
        total_tests++;
        data = 8'b1010_0101;
        assert((data & 8'h0F) == 8'h05) begin
            pass_count++;
            $display("PASS: assert bitwise");
        end else $display("FAIL: bitwise");

        // Test 6: multiple assertions in sequence
        total_tests++;
        a = 1; b = 2;
        assert(a == 1);
        assert(b == 2);
        assert(a < b);
        pass_count++;
        $display("PASS: multiple assertions");

        // Test 7: assert with ternary
        total_tests++;
        flag = 1;
        assert(flag ? 1 : 0) begin
            pass_count++;
            $display("PASS: assert ternary");
        end else $display("FAIL: ternary");

        // Test 8: assert in conditional
        total_tests++;
        a = 100;
        if (a > 50) begin
            assert(a <= 200) begin
                pass_count++;
                $display("PASS: assert in conditional");
            end else $display("FAIL: in conditional");
        end

        // Test 9: assert with function call result
        total_tests++;
        a = check_value(42);
        assert(a == 84) begin
            pass_count++;
            $display("PASS: assert function result");
        end else $display("FAIL: function result");

        // Test 10: assert with logical operators
        total_tests++;
        a = 5; b = 10; flag = 1;
        assert((a < b) && flag && (b > 0)) begin
            pass_count++;
            $display("PASS: assert logical ops");
        end else $display("FAIL: logical ops");

        // Test 11: assert with negation
        total_tests++;
        a = 0;
        assert(!a) begin
            pass_count++;
            $display("PASS: assert negation");
        end else $display("FAIL: negation");

        // Test 12: assert with equality
        total_tests++;
        data = 8'hAB;
        assert(data === 8'hAB) begin
            pass_count++;
            $display("PASS: assert case equality");
        end else $display("FAIL: case equality");

        // Test 13: assert with inequality
        total_tests++;
        a = 5; b = 10;
        assert(a != b) begin
            pass_count++;
            $display("PASS: assert inequality");
        end else $display("FAIL: inequality");

        // Test 14: assert with reduction operator
        total_tests++;
        data = 8'b0000_0001;
        assert(|data) begin
            pass_count++;
            $display("PASS: assert reduction OR");
        end else $display("FAIL: reduction OR");

        $display("PASS: assert_imm (%0d/%0d)", pass_count, total_tests);
        $finish;
    end

    function int check_value(int x);
        return x * 2;
    endfunction
endmodule
