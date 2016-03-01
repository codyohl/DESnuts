onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/clk
add wave -noupdate /DE1_SoC_testbench/dut/KEY
add wave -noupdate /DE1_SoC_testbench/dut/SW
add wave -noupdate /DE1_SoC_testbench/HEX2
add wave -noupdate /DE1_SoC_testbench/HEX3
add wave -noupdate /DE1_SoC_testbench/i
add wave -noupdate /DE1_SoC_testbench/j
add wave -noupdate /DE1_SoC_testbench/k
add wave -noupdate /DE1_SoC_testbench/HEX0
add wave -noupdate /DE1_SoC_testbench/dut/HEX5
add wave -noupdate /DE1_SoC_testbench/dut/HEX2
add wave -noupdate /DE1_SoC_testbench/dut/HEX3
add wave -noupdate /DE1_SoC_testbench/dut/HEX0
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {187 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 162
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2093 ps}
