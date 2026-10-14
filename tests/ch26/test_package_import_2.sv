/*
:name: test_package_import_2
:description: Package import variations
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_2.expected
*/
// IEEE 1800-2023 §26: Package import variations
// Tests different import styles and scopes

package pkg_math;
    function int add(int a, int b);
        return a + b;
    endfunction

    function int multiply(int a, int b);
        return a * b;
    endfunction

    typedef int signed_int_t;
    parameter int PKG_CONST = 100;
endpackage

package pkg_data;
    typedef struct packed {
        logic [7:0] id;
        logic [7:0] value;
    } data_t;

    typedef enum logic [1:0] {IDLE, ACTIVE, DONE} state_e;

    function automatic data_t create_data(logic [7:0] id, logic [7:0] val);
        data_t d;
        d.id = id;
        d.value = val;
        return d;
    endfunction
endpackage

module test_package_import;
    int pass_count = 0;
    int test_count = 0;

    // Wildcard import
    import pkg_math::*;

    // Selective import
    import pkg_data::data_t;
    import pkg_data::state_e;
    import pkg_data::IDLE;
    import pkg_data::ACTIVE;
    import pkg_data::DONE;

    initial begin
        // Test 1: Wildcard import - function
        test_count++;
        begin
            static int result = add(5, 3);
            if (result == 8) begin
                pass_count++;
                $display("Test 1 PASS: wildcard import function add()");
            end else begin
                $display("Test 1 FAIL: add(5,3) = %0d", result);
            end
        end

        // Test 2: Wildcard import - another function
        test_count++;
        begin
            static int result = multiply(4, 7);
            if (result == 28) begin
                pass_count++;
                $display("Test 2 PASS: wildcard import function multiply()");
            end else begin
                $display("Test 2 FAIL: multiply(4,7) = %0d", result);
            end
        end

        // Test 3: Wildcard import - typedef
        test_count++;
        begin
            static signed_int_t v = -42;
            if (v == -42) begin
                pass_count++;
                $display("Test 3 PASS: wildcard import typedef");
            end else begin
                $display("Test 3 FAIL: typedef value");
            end
        end

        // Test 4: Wildcard import - parameter
        test_count++;
        if (PKG_CONST == 100) begin
            pass_count++;
            $display("Test 4 PASS: wildcard import parameter");
        end else begin
            $display("Test 4 FAIL: parameter = %0d", PKG_CONST);
        end

        // Test 5: Selective import - struct typedef
        test_count++;
        begin
            data_t d;
            d.id = 8'hAB;
            d.value = 8'hCD;
            if (d.id == 8'hAB && d.value == 8'hCD) begin
                pass_count++;
                $display("Test 5 PASS: selective import struct typedef");
            end else begin
                $display("Test 5 FAIL: struct values");
            end
        end

        // Test 6: Selective import - enum typedef
        test_count++;
        begin
            static state_e s = IDLE;
            if (s == IDLE) begin
                s = ACTIVE;
                if (s == ACTIVE) begin
                    pass_count++;
                    $display("Test 6 PASS: selective import enum typedef");
                end else begin
                    $display("Test 6 FAIL: enum ACTIVE");
                end
            end else begin
                $display("Test 6 FAIL: enum IDLE");
            end
        end

        // Test 7: Explicit scope resolution for struct
        test_count++;
        begin
            pkg_data::data_t d2;
            d2.id = 8'h11;
            d2.value = 8'h22;
            if (d2.id == 8'h11 && d2.value == 8'h22) begin
                pass_count++;
                $display("Test 7 PASS: explicit scope resolution for struct");
            end else begin
                $display("Test 7 FAIL: explicit scope");
            end
        end

        // Test 8: Mixed import and explicit
        test_count++;
        begin
            static int sum = add(10, 20);  // From wildcard import
            static int prod = pkg_math::multiply(3, 4);  // Explicit
            if (sum == 30 && prod == 12) begin
                pass_count++;
                $display("Test 8 PASS: mixed import and explicit scope");
            end else begin
                $display("Test 8 FAIL: mixed access");
            end
        end

        $display("=== Package Import Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
