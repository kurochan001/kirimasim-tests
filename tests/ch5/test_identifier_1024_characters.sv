/*
:name: test_identifier_1024_characters
:description: An implementation that limits the length of identifiers accepts names of 1024 characters and keeps them apart when only their last character differs (IEEE 1800-2023 Section 5.6)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 21.2.1.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: identifier_1024_characters.svh
:expected_stdout: @test_identifier_1024_characters.expected
*/
// IEEE 1800-2023 §5.6: an implementation may limit the length of
// identifiers, but the limit is at least 1024 characters.
// The include file declares two variables whose names have 1024 characters
// and differ only in the last one, x and y, so a tool that cut names shorter
// would see one name declared twice. A named block with a 1024-character
// name increments x and prints both variables, and the length and last
// character of its hierarchical name from %m: the module name, a dot and
// the 1024 characters of the block name ending in z (32 + 1024 = 1056).
// The names are in the include file because a line of this file is at most
// 100 columns.
// The release 5.052 of Verilator prints a shortened name of 83 characters
// for the block with %m (21.2.1.5), which should be the full hierarchical
// name.

module test_identifier_1024_characters;
`include "identifier_1024_characters.svh"
endmodule
