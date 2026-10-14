/*
:name: test_package_import_chain
:description: A package that imports another package, and a module that imports both
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 26.2
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_import_chain.expected
*/
// IEEE 1800-2023 §26.6 Package export
// Test: Package export functionality (simplified)
package base_pkg;
    typedef logic [7:0] byte_t;
    parameter int BASE_VERSION = 1;

    function automatic logic [7:0] invert(logic [7:0] b);
        return ~b;
    endfunction
endpackage

package extended_pkg;
    import base_pkg::*;

    typedef logic [15:0] word_t;
    parameter int EXT_VERSION = 2;

    function automatic logic [15:0] extend(logic [7:0] b);
        return {8'h00, b};
    endfunction

    // Function that uses base_pkg function
    function automatic logic [15:0] invert_extend(logic [7:0] b);
        return extend(invert(b));
    endfunction
endpackage

module test_package_import_chain;
    import base_pkg::*;
    import extended_pkg::*;

    int errors = 0;
    byte_t b;
    word_t w;

    initial begin
        // Test 1: Access type from base_pkg
        b = 8'hA5;
        if (b !== 8'hA5) begin
            $display("FAIL: byte_t should work");
            errors++;
        end

        // Test 2: Access function from base_pkg
        if (invert(8'hF0) !== 8'h0F) begin
            $display("FAIL: invert(0xF0) should be 0x0F");
            errors++;
        end

        // Test 3: Access parameter from base_pkg
        if (BASE_VERSION !== 1) begin
            $display("FAIL: BASE_VERSION should be 1");
            errors++;
        end

        // Test 4: Access extended_pkg items
        w = extend(8'hAB);
        if (w !== 16'h00AB) begin
            $display("FAIL: extend(0xAB) should be 0x00AB");
            errors++;
        end

        if (EXT_VERSION !== 2) begin
            $display("FAIL: EXT_VERSION should be 2");
            errors++;
        end

        // Test 5: Cross-package function call
        w = invert_extend(8'h00);
        if (w !== 16'h00FF) begin
            $display("FAIL: invert_extend(0x00) should be 0x00FF");
            errors++;
        end

        // Test 6: Multiple imports work together
        b = invert(8'hAA);  // From base_pkg
        w = extend(b);       // From extended_pkg
        if (w !== 16'h0055) begin
            $display("FAIL: Combined calls should give 0x0055");
            errors++;
        end

        if (errors == 0) begin
            $display("TEST PASSED: Package export tests passed");
        end else begin
            $display("TEST FAILED: %0d errors", errors);
        end
        $finish;
    end
endmodule
