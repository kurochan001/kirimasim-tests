/*
:name: test_inside_operator_2
:description: Tests inside operator with ranges, arrays, and expressions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_inside_operator_2.expected
*/
// Tests inside operator with ranges, arrays, and expressions
`timescale 1ns/1ps

module test_inside_operator_2;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Basic inside with values
    task test_basic_inside();
        static int val = 5;
        logic result;

        result = val inside {1, 3, 5, 7, 9};

        if (result == 1) begin
            $display("PASS: Basic inside with values works");
            pass_count++;
        end else begin
            $display("FAIL: Basic inside failed");
            fail_count++;
        end
    endtask

    // Test 2: Inside with range
    task test_inside_range();
        static int val = 50;
        logic result;

        result = val inside {[1:100]};

        if (result == 1) begin
            $display("PASS: Inside with range works");
            pass_count++;
        end else begin
            $display("FAIL: Inside range failed");
            fail_count++;
        end
    endtask

    // Test 3: Inside with mixed values and ranges
    task test_mixed_inside();
        static int val = 150;
        logic result;

        result = val inside {0, [10:20], [100:200], 500};

        if (result == 1) begin
            $display("PASS: Mixed inside works");
            pass_count++;
        end else begin
            $display("FAIL: Mixed inside failed");
            fail_count++;
        end
    endtask

    // Test 4: Inside returns false
    task test_inside_false();
        static int val = 50;
        logic result;

        result = val inside {[0:10], [100:200]};

        if (result == 0) begin
            $display("PASS: Inside correctly returns false");
            pass_count++;
        end else begin
            $display("FAIL: Inside should have returned false");
            fail_count++;
        end
    endtask

    // Test 5: Inside with negative values
    task test_inside_negative();
        static int val = -5;
        logic result;

        result = val inside {[-10:-1]};

        if (result == 1) begin
            $display("PASS: Inside with negative range works");
            pass_count++;
        end else begin
            $display("FAIL: Inside negative failed");
            fail_count++;
        end
    endtask

    // Test 6: Inside with array
    task test_inside_array();
        static int val = 30;
        static int arr[] = '{10, 20, 30, 40, 50};
        logic result;

        result = val inside {arr};

        if (result == 1) begin
            $display("PASS: Inside with array works");
            pass_count++;
        end else begin
            $display("FAIL: Inside array failed");
            fail_count++;
        end
    endtask

    // Test 7: Inside with logic values
    task test_inside_logic();
        static logic [3:0] val = 4'hA;
        logic result;

        result = val inside {4'h0, 4'h5, 4'hA, 4'hF};

        if (result == 1) begin
            $display("PASS: Inside with logic values works");
            pass_count++;
        end else begin
            $display("FAIL: Inside logic failed");
            fail_count++;
        end
    endtask

    // Test 8: Inside in if statement
    task test_inside_if();
        static int val = 25;
        string category;

        if (val inside {[0:10]})
            category = "small";
        else if (val inside {[11:50]})
            category = "medium";
        else
            category = "large";

        if (category == "medium") begin
            $display("PASS: Inside in if statement works");
            pass_count++;
        end else begin
            $display("FAIL: Inside if failed");
            fail_count++;
        end
    endtask

    // Test 9: Inside with case
    task test_inside_case();
        static int val = 7;
        string result;

        case (1)
            val inside {[0:3]}: result = "range 0-3";
            val inside {[4:6]}: result = "range 4-6";
            val inside {[7:9]}: result = "range 7-9";
            default: result = "other";
        endcase

        if (result == "range 7-9") begin
            $display("PASS: Inside with case works");
            pass_count++;
        end else begin
            $display("FAIL: Inside case failed");
            fail_count++;
        end
    endtask

    // Test 10: Inside with open range
    task test_open_range();
        static int val = 1000;
        logic result;

        result = val inside {[100:$]};  // 100 to max value

        if (result == 1) begin
            $display("PASS: Inside with open range works");
            pass_count++;
        end else begin
            $display("FAIL: Inside open range failed");
            fail_count++;
        end
    endtask

    // Test 11: Negated inside
    task test_negated_inside();
        static int val = 50;
        logic result;

        result = !(val inside {[0:10], [100:200]});

        if (result == 1) begin
            $display("PASS: Negated inside works");
            pass_count++;
        end else begin
            $display("FAIL: Negated inside failed");
            fail_count++;
        end
    endtask

    // Test 12: Inside with single value
    task test_single_value();
        static int val = 42;
        logic result;

        result = val inside {42};

        if (result == 1) begin
            $display("PASS: Inside with single value works");
            pass_count++;
        end else begin
            $display("FAIL: Inside single value failed");
            fail_count++;
        end
    endtask

    // Test 13: Inside with enum
    task test_inside_enum();
        typedef enum {RED, GREEN, BLUE, YELLOW} color_t;
        static color_t c = GREEN;
        logic result;

        result = c inside {RED, GREEN};

        if (result == 1) begin
            $display("PASS: Inside with enum works");
            pass_count++;
        end else begin
            $display("FAIL: Inside enum failed");
            fail_count++;
        end
    endtask

    initial begin
        $display("=== Inside Operator Corner Cases Test ===");

        test_basic_inside();
        test_inside_range();
        test_mixed_inside();
        test_inside_false();
        test_inside_negative();
        test_inside_array();
        test_inside_logic();
        test_inside_if();
        test_inside_case();
        test_open_range();
        test_negated_inside();
        test_single_value();
        test_inside_enum();

        $display("");
        $display("=== Summary ===");
        $display("Passed: %0d, Failed: %0d", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
