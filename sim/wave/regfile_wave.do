onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /regfile_tb/clk
add wave -noupdate /regfile_tb/i
add wave -noupdate /regfile_tb/reg_write
add wave -noupdate -radix unsigned /regfile_tb/ws
add wave -noupdate -radix unsigned /regfile_tb/wd
add wave -noupdate -radix unsigned /regfile_tb/rs1
add wave -noupdate -radix unsigned /regfile_tb/rs2
add wave -noupdate -radix unsigned /regfile_tb/rd1
add wave -noupdate -radix unsigned /regfile_tb/rd2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59510386 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {501375 ns}
