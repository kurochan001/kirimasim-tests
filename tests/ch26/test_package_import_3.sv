/*
:name: test_package_import_3
:description: Test: Package import, export, wildcard
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_3.expected
*/
// Test: Package import, export, wildcard
package pkg_constants;
    parameter int MAX_SIZE = 100;
    parameter int MIN_SIZE = 10;
    typedef logic [7:0] byte_t;
endpackage

package pkg_types;
    typedef struct packed {
        logic [3:0] field1;
        logic [3:0] field2;
    } pair_t;

    typedef enum logic [1:0] {
        STATE_IDLE = 2'b00,
        STATE_RUN  = 2'b01,
        STATE_DONE = 2'b10
    } state_e;
endpackage

package pkg_functions;
    function automatic int add(int a, int b);
        return a + b;
    endfunction

    function automatic int multiply(int a, int b);
        return a * b;
    endfunction
endpackage

package pkg_combined;
    import pkg_constants::*;
    import pkg_types::pair_t;
    import pkg_functions::add;

    // Re-export
    export pkg_constants::MAX_SIZE;

    function automatic int get_range();
        return MAX_SIZE - MIN_SIZE;
    endfunction
endpackage

module test_package_import;
    import pkg_constants::*;
    import pkg_types::*;  // Import all types including enum values
    import pkg_functions::add;
    import pkg_functions::multiply;

    int pass_count = 0;
    int fail_count = 0;

    byte_t my_byte;
    pair_t my_pair;
    state_e my_state;

    initial begin
        // Test 1: Import parameter constant
        if (MAX_SIZE == 100) begin
            $display("PASS: Import parameter constant");
            pass_count++;
        end else begin
            $display("FAIL: MAX_SIZE - expected 100, got %0d", MAX_SIZE);
            fail_count++;
        end

        // Test 2: Import typedef
        my_byte = 8'hAB;
        if (my_byte == 8'hAB) begin
            $display("PASS: Import typedef byte_t");
            pass_count++;
        end else begin
            $display("FAIL: byte_t - expected 0xAB, got 0x%02X", my_byte);
            fail_count++;
        end

        // Test 3: Import struct typedef
        my_pair.field1 = 4'hC;
        my_pair.field2 = 4'hD;
        if (my_pair == 8'hCD) begin
            $display("PASS: Import struct typedef pair_t");
            pass_count++;
        end else begin
            $display("FAIL: pair_t - expected 0xCD, got 0x%02X", my_pair);
            fail_count++;
        end

        // Test 4: Import enum typedef
        my_state = STATE_RUN;
        if (my_state == 2'b01) begin
            $display("PASS: Import enum typedef state_e");
            pass_count++;
        end else begin
            $display("FAIL: state_e - expected 1, got %0d", my_state);
            fail_count++;
        end

        // Test 5: Import function
        if (add(5, 7) == 12) begin
            $display("PASS: Import function add");
            pass_count++;
        end else begin
            $display("FAIL: add(5,7) - expected 12, got %0d", add(5, 7));
            fail_count++;
        end

        // Test 6: Import multiple functions
        if (multiply(3, 4) == 12) begin
            $display("PASS: Import function multiply");
            pass_count++;
        end else begin
            $display("FAIL: multiply(3,4) - expected 12, got %0d", multiply(3, 4));
            fail_count++;
        end

        // Summary
        $display("Package import test: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All package import tests passed");
        $finish;
    end
endmodule
