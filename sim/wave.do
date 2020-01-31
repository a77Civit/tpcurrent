onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tpcurrent_vlg_tst/eachvec
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/mclk
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/cs_n
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/r_n_w
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/adcdata
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/current_sta
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/next_sta
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/rest_cnt
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/time_cnt
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/contro_set_flg
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/wait_six_flg
add wave -noupdate -radix unsigned /tpcurrent_vlg_tst/i1/u_AD7760/ready_data_flg
add wave -noupdate /tpcurrent_vlg_tst/command
add wave -noupdate /tpcurrent_vlg_tst/i1/wrreq
add wave -noupdate /tpcurrent_vlg_tst/i1/drdy_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {773727 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {2359296 ps}
