; The following script will plot a load test on your battery pack and calculate your cells internal resistance which will be printed

; It's recomended you be careful with this test and increase your phase amps target slowly 
; and check your wires and connectors as you do it to make sure they are not over heating
; It drives an open loop current on your motor at 0rpm can generate a lot of heat, 
; so I've limited the test to 4 sec or 74c on your controller which ever comes first 
; in the event your settings don't reach the desired bat load current

; This may require adjsuting the phase current gains to get your bat current draw consistent, you can check the plots to see it.
; the resistance values don't take into account your connectors, wiring harness, or nickle cell to cell connections 
; so the result is skewed a few percent, but works great for 
;  - checking varous configurations aginst each other
;  - validating power delivery
;  - determining relationship between loaded and unloaded voltages under amp load
;  - cell health checkup as it ages

(defun plot-data (graph-index x y) (progn
  (plot-set-graph graph-index)
  (plot-send-points x y)
  (sleep 0.01)
))

(defun cal-load-res (unl ul i) ;utility for calculating the test load
  (def rl (/ ul i)))           

(defun cal-cell-res (unl ul i) { ;utility for calculating the battery or cell resistance
  (def ui (- unl ul))
   (def ri (if (= i 0) 0.0 (/ ui (* 1.0 i))))})

(plot-init "Time" "Value")
(plot-add-graph "temp")
(plot-add-graph "v-in")
(plot-add-graph "amps in")
(plot-add-graph "amps phase")


(def s-count 24) ;pack number of cells in series
(def p-count 1)  ;pack number of cells in parallel

(def start 0)    ;Use the lisp Console REPL and enter (def start 1) to begin test

(loopwhile t {
    (def ts (systime))                      ;start time
    (def ts2 (systime))                     ;plotting timescale
    (def unloaded-v (/ (get-vin) s-count))  ;starting voltage
    (def amps 67.4)                         ;start current
(loopwhile (= start 1) {
    (if (< (get-current-in) 10) (def ts3 (systime)));input current measurement timestamp
    (def temp (get-temp-fet))
    
    (if (< (secs-since ts3) 0.95) {                 ;primary end condition as the time in seconds while input current at threshold
            (if (<= (get-current-in) 10.05) 
                (def amps (+ amps 0.05))            ;positive current gains
                ;(def amps (- amps 0.01))           ;negative current gains
                )
                (foc-openloop amps 0)}
            { 
                (print "test time" (secs-since ts))
                (def v-sag (- unloaded-v (/ (get-vin) s-count)))
                (def end-v (/ (get-vin) s-count))
                (def cell-amps (/ (get-current-in) p-count))
                
                (print "end phase current" (get-current))
                (set-current-rel 0 -1)
                
                (print "start voltage" unloaded-v)
                (print "end voltage" end-v)
                (print "v-sag" v-sag)
                (print "Cell Load at the following amps:" cell-amps)
                (print "VESC Load Resistance mOhms at 20khz switch mode" (cal-load-res unloaded-v end-v cell-amps))
                (print "cell mOhms" (cal-cell-res unloaded-v end-v cell-amps))
                (sleep 100000)}) ;shutdown
                
    (if (or (> temp 74) (> (secs-since ts2) 4)){         ;test conditions not right, time based at 4 sec or tempature over 74c
        (set-current-rel 0 -1)
        (print "test failed to maintain target load current, try adjsuting the gains or start current")
        (sleep 100000)})
    (sleep 0.01)
    
    (if (> (secs-since ts2) 0.02) {                      ;plot every 0.02 sec of the test
        (def ts2 (systime))
        (plot-data 0 (secs-since ts) temp)
        (plot-data 1 (secs-since ts) (/ (get-vin) s-count))
        (plot-data 2 (secs-since ts) (/ (get-current-in) p-count))
        (plot-data 3 (secs-since ts) (get-current))
    })})})
    
    
    
; Expected output would look like this if the script is running right:
Parsing 2647 characters
> 1
"test time"
2.359900f32
"end phase current"
68.875969f32
"start voltage"
3.423788f32
"end voltage"
3.227900f32
"v-sag"
0.195851f32
"Cell Load at the following amps:"
10.196529f32
"VESC Load Resistance mOhms at 20khz switch mode"
0.316568f32
"cell mOhms"
0.019211f32