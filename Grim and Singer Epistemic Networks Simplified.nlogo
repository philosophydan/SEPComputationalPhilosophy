breed [nodes node]

globals [finalfinalconverged finalfinalconvergedonhighest finalconvergedonhighest finalconverged converged run-number highest highest-yes total iteration curve start-point end-point counter component-size giant-component-size
  giant-start-node num finalperc superfinalperc superduperfinalperc maxperc minperc varperc meanperc finalperclist finalhighest
  finalfinalhighest clust-coeff clustcoeffsum numqualifyingnodes tot-links num-neighbors current-node finalclusterlist avcluster average-path-length
  av-av-pathlist mean-path-length av-giant-componentlist mean-giant-component average-path-length2 average-path-length2list mean-path-length-giant top bottom finalticks stoppinglist flag
  avstopping discoveryticks discoverylist avdiscovery ghighest-yes value2 warning]

nodes-own [my-recalcitrance my-speed my-uncertainty my-belief utility friends explored?]

to setup
  clear-all

  set-default-shape turtles "circle"
  set finalperclist []
  set finalclusterlist []
  set av-av-pathlist []
  set av-giant-componentlist []
  set average-path-length2list []
  set stoppinglist []
  set discoverylist []

  network-bit

  recolor-nodes
  reset-ticks
end



to go
  set ghighest-yes false
  let stopping-condition-met false

  ;;run each run like this:
  ask nodes [set utility find-utility my-belief]
  ask nodes [
    if any? friends
        [ if random 100 > recalcitrance [copy-belief] ]
    ]
  recolor-nodes
  tick
  ;do-plot

  ;;stop when:
  if stopping-condition = "length of run = 100" [
    if ticks >= 100 [stop]
  ]
  if stopping-condition = "convergence" [
    let bestbelief [my-belief] of max-one-of turtles [utility]
    if not any? turtles with [abs(((my-belief - bestbelief + 50) mod 100) - 50) > uncertainty] [
      set converged true
      stop
    ]
    if ticks >= 10000 [
      set converged false
      stop
    ]
  ]
end

to copy-belief
  ;;has agent move their belief towards their highest neighbor with uncertainty and speed
  let maxfriend max-one-of friends [utility]
  if utility < [utility] of maxfriend [ ;; only move if has a higher friend
    let focus-belief (([my-belief] of maxfriend) - (uncertainty / 2) + (random-float uncertainty)) mod 100 ;; mod wraps the focus-belief
    let dist ((focus-belief - my-belief + 50) mod 100) - 50 ;; sets dist to wrapped distance from my-belief to focus-belief (including sign)
    let dist-to-move dist * (speed / 100)
    set my-belief (my-belief + dist-to-move) mod 100
  ]
end

to-report find-utility [value]
  let result 0

  if distribution = "single-mode" [
    set result ((.6 + (sin (3.3 * value))) + 1) * 30
  ]

  if distribution = "bimodal" [
    set result 90 - ((0.6 * sin (7 * value)) + ((.6 + (sin (3.3 * value))) + 1.5)) * 30
  ]

  if distribution = "bimodal-spiked-2" [
    set result max list  (100 - abs (600 - (40 * (value)))) (80 - ((0.7 * sin (7 * value)) + ((.6 + (sin (3.3 * value))) + 1.1)) * 30)
  ]

  if distribution = "bimodal-spiked" [
    set result max list  (100 - abs (600 - (40 * (value)))) (90 - ((0.7 * sin (7 * value)) + ((.6 + (sin (3.3 * value))) + 1.1)) * 30)
  ]

  if distribution = "bimodal-spiked-3" [
    set result max list  (100 - abs (600 - (40 * (value)))) (70 - ((0.7 * sin (7 * value)) + ((.6 + (sin (3.3 * value))) + 1.1)) * 30)
  ]

  if distribution = "bimodal-spiked-4" [
    set result max list  (100 - abs (600 - (40 * (value)))) (60 - ((0.7 * sin (7 * value)) + ((.6 + (sin (3.3 * value))) + 1.1)) * 30)
  ]

  if distribution = "bimodal-spiked narrow" [
    set result max list  (100 - 2 * abs (600 - (40 * (value)))) (90 - ((0.7 * sin (7 * value)) + ((.6 + (sin (3.3 * value))) + 1.1)) * 30)
  ]

  if distribution = "custom" [
    if value < 10 [
      set result 100 * (.95 * (1 - 2 * (abs((10 * (value / 100)) - .5))) ^ zed)
    ]
    if value >= 10 [

      if value > 99 [set value 99]
      set result 100 * (.85 * (1 - 2 * abs (( (10 / 9) * ( value / 100 - .1 )) - .5)) ^ ( 1 / zed ))
    ]
  ]

  if distribution = "custom-2" [

    if value <= 90 [set value2 (value + 10)]
    if value > 90 [set value2 (value - 90)]


    if value2 >= 45 and value2 < 55 [
      set result 100 * (.95 * (1 - 2 * (abs (( 10 * ( (value2) / 100 - .45)) - .5 ))) ^ zed)
    ]
    if value2 >= 55 [
      set result 100 * (.85 * (1 - 2 * (abs (((10 / 9) * (( (value2 ) / 100 - .45 ) - .1)) - .5))) ^ (1 / zed))
    ]
    if value2 < 45 [
      set result 100 * (.85 * (1 - 2 * (abs (((10 / 9) * (( (value2 ) / 100 + .55 ) - .1)) - .5))) ^ (1 / zed))
    ]
  ]

  report result
end

to do-plot
  set-current-plot "Belief Distribution"
  set-current-plot-pen "Beliefs"
  histogram [my-belief] of nodes
end

to do-utility-plot
  set-current-plot "The Epistemic Landscape"
  set-current-plot-pen "Utility"
  let index 1
  repeat 99 [
    plotxy (index) (find-utility index)
    set index index + 1
  ]
end


to add-edge
  let node1 one-of turtles
  let node2 one-of turtles
  ask node1 [
    ifelse link-neighbor? node2 or node1 = node2
    ;; if there's already an edge there, then go back
    ;; and pick new turtles
    [ add-edge ]
    ;; else, go ahead and make it
    [ create-link-with node2 ]
  ]
end

to draw-network

  set-default-shape turtles "circle"
  set finalperclist []
  set finalclusterlist []
  set av-av-pathlist []
  set av-giant-componentlist []
  set average-path-length2list []
  set stoppinglist []
  set discoverylist []

  network-bit

end

to recolor-nodes



  ask nodes [
    ifelse (distribution != "custom-2") [set color red]

    [

      if my-belief <= 90 [set value2 (my-belief + 10)]
      if my-belief > 90 [set value2 (my-belief - 90)]


      if value2 >= 45 and value2 < 55 [
        set color scale-color red (100 * (.95 * (1 - 2 * (abs (( 10 * ( (value2) / 100 - .45)) - .5 ))) ^ zed)) -50 150
      ]
      if value2 >= 55 [
        set color scale-color blue (100 * (.85 * (1 - 2 * (abs (((10 / 9) * (( (value2 ) / 100 - .45 ) - .1)) - .5))) ^ (1 / zed))) 1500 -500
      ]
      if value2 < 45 [
        set color scale-color blue (100 * (.85 * (1 - 2 * (abs (((10 / 9) * (( (value2 ) / 100 + .55 ) - .1)) - .5))) ^ (1 / zed))) 1500 -500
      ]
    ]
  ]
end


to network-bit

  if network-type = "connected"
    [
      create-ordered-nodes population [
        make-node
        fd max-pxcor - 1  ;;puts them in a circle
        create-links-with nodes with [who < [who] of myself] []
      ]

    ]


  if network-type = "lattice"      ;; creates a regular 4-edge graph on a square lattice with the closest possible number of nodes
    [
      let side-length floor sqrt population
      let lattice-population side-length * side-length
      let spacing world-width / (side-length )
      let index1 0
      let index2 0
      repeat side-length [
        set index1 index1 + 1
        set index2 0
        repeat side-length [
          set index2 index2 + 1
          create-nodes 1 [
            make-node
            set xcor (index1 * spacing) - (spacing / 2) - max-pxcor
            set ycor (index2 * spacing) - (spacing / 2) - max-pycor
          ]
        ]
      ]
      ask nodes [
        let other-nodes nodes in-radius (spacing + 0.1) with [self != myself]
        create-links-with other-nodes with [link-neighbor? myself = false] []
      ]
      ask nodes with-max [xcor] [
        let partner-nodes nodes with [ycor = [ycor] of myself]
        let buddy partner-nodes with-min [xcor]
        create-link-with one-of buddy []
      ]
      ask nodes with-max [ycor] [
        let partner-nodes nodes with [xcor = [xcor] of myself]
        let buddy partner-nodes with-min [ycor]
        create-link-with one-of buddy []
      ]
    ]


  if network-type = "hub"
    [
      create-ordered-nodes 1 [
        make-node
      ]
      create-ordered-nodes population - 1 [
        make-node
        fd max-pxcor - 1  ;;puts them in a circle
        create-link-with node 0 []
      ]
    ]


  if network-type = "random"    ;;REMOVE?
    [
      create-ordered-nodes population [
        make-node
        fd max-pxcor - 1  ;;puts them in a circle
        let other-nodes nodes with [who < [who] of myself]
        let index 0
        repeat count other-nodes [
          if random 100 < edge-prob [ create-link-with node index [] ]
          set index index + 1
        ]
      ]
      ;;repeat 7 [ layout ]
    ]


  if network-type = "random2"
    [
      create-ordered-nodes population [
        make-node
        fd max-pxcor - 1 ];;puts them in a circle
      repeat number-links [add-edge]
      ask links [ set color [color] of end1 ]
      ;;ask nodes [recolor]
    ]


  if network-type = "ring"
    [
      create-ordered-nodes population [
        make-node
        fd max-pxcor - 1  ;;puts them in a circle
      ]
      ask nodes [
        let index 1
        repeat radius [
          create-link-with node (([who] of self + index) mod population) []
          set index index + 1
        ]
      ]
      if rewire-prob > 0 [
        repeat radius * population * rewire-prob * .01 [  ;;for each edge in the graph
          ask one-of nodes
          [ create-link-with one-of other nodes ]  ;; if link already exists, nothing happens
          ask one-of links [ die ] ]

      ]

    ]


  if network-type = "wheel"
    [
      create-ordered-nodes population - 1 [
        make-node
        fd max-pxcor - 1  ;;puts them in a circle
      ]
      ask nodes [
        create-link-with node (([who] of self + 1) mod (population - 1)) []
      ]
      create-nodes 1 [
        make-node
        set size 2
        create-links-with nodes with [who != [who] of myself] []
      ]
    ]
  ask nodes [
    set friends link-neighbors
  ]


  do-utility-plot

end

to make-node
  set my-recalcitrance recalcitrance
  set my-speed speed
  set my-uncertainty uncertainty
  set my-belief random-float 100
  set utility 0
end
@#$#@#$#@
GRAPHICS-WINDOW
893
78
1127
313
-1
-1
3.705
1
10
1
1
1
0
0
0
1
-30
30
-30
30
1
1
1
ticks
10000.0

SLIDER
20
26
192
59
population
population
0
100
50.0
1
1
NIL
HORIZONTAL

CHOOSER
20
62
158
107
network-type
network-type
"connected" "hub" "random" "ring" "wheel" "lattice" "random2"
2

SLIDER
20
110
192
143
edge-prob
edge-prob
0
100
5.5
.5
1
NIL
HORIZONTAL

SLIDER
20
146
192
179
radius
radius
0
4
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
197
113
256
141
for random \nnetwork
11
0.0
0

TEXTBOX
197
150
240
181
for ring\nnetwork
11
0.0
0

BUTTON
372
11
435
44
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
304
11
368
44
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
182
192
215
rewire-prob
rewire-prob
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
197
186
281
214
to make ring a\nsmall world
11
0.0
0

SLIDER
282
50
454
83
recalcitrance
recalcitrance
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
281
91
453
124
speed
speed
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
282
131
454
164
uncertainty
uncertainty
0
100
8.0
1
1
NIL
HORIZONTAL

PLOT
472
176
879
415
Belief Distribution
belief
count
0.0
100.0
0.0
10.0
true
false
"set-histogram-num-bars 50" ""
PENS
"Beliefs" 1.0 1 -16777216 true "" "histogram [my-belief] of nodes"

PLOT
473
27
880
171
The Epistemic Landscape
epistemic payoff
utility
0.0
100.0
0.0
100.0
false
false
"" ""
PENS
"Utility" 1.0 0 -16777216 true "" ""

CHOOSER
282
176
454
221
distribution
distribution
"single-mode" "bimodal" "bimodal-spiked" "custom" "bimodal-spiked-2" "bimodal-spiked-3" "bimodal-spiked-4" "bimodal-spiked narrow" "custom-2"
8

SLIDER
20
218
192
251
number-links
number-links
0
(population * 32)
60.0
1
1
NIL
HORIZONTAL

INPUTBOX
287
287
337
347
zed
1.5
1
0
Number

CHOOSER
289
229
446
274
stopping-condition
stopping-condition
"convergence" "length of run = 100"
0

TEXTBOX
197
229
347
247
for rand2 net
11
0.0
1

MONITOR
352
290
431
335
NIL
converged
17
1
11

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="top-right">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="top-left">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-right">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-left">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="top-right">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="top-left">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-right">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-left">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="2ring" repetitions="100" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <timeLimit steps="1"/>
    <metric>highest-yes</metric>
    <enumeratedValueSet variable="top-left">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="top-right">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="iterations">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-left">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bottom-right">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="51"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random2 increasing links1" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="10" step="10" last="100"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random2 increasing links2.1" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="5" step="5" last="60"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random2 increasing links2.2" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="65" step="5" last="125"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random2 increasing links2.3" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="130" step="5" last="200"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random2 increasing links2.4" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="205" step="5" last="280"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="random2 increasing links2.5" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="285" step="5" last="300"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="narrow random increasing links 1" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <metric>avcluster</metric>
    <metric>mean-path-length</metric>
    <metric>mean-giant-component</metric>
    <metric>mean-path-length-giant</metric>
    <enumeratedValueSet variable="curve7">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;bimodal-spiked narrow&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="forth">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve4">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ninth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="eighth">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sixth">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve1">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="third">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="fifth">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve5">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seventh">
      <value value="120"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="second">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve6">
      <value value="&quot;down-deep&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve10">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve8">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve2">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve9">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-point">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="curve3">
      <value value="&quot;line&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="number-links" first="5" step="5" last="60"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="last-point">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tenth">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment hub zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;hub&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment random 2 zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="4.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment wheel zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;wheel&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="4.5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment ring-2 zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment random 9 zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="radius">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;random2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment connected zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;connected&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment lattice zed 2" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;lattice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
  </experiment>
  <experiment name="experiment stopping 3c lattice zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>avstopping</metric>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;lattice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment stopping zed ring" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>avstopping</metric>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment stopping 3 ring zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>avstopping</metric>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 23 stopping lattice zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>avstopping</metric>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;lattice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment 23 sm world zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>avstopping</metric>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;ring&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="test-mark">
      <value value="86"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="9"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="shifted lattice zed" repetitions="1" runMetricsEveryStep="false">
    <setup>draw-network</setup>
    <go>go</go>
    <metric>finalfinalhighest</metric>
    <enumeratedValueSet variable="test-mark">
      <value value="90"/>
    </enumeratedValueSet>
    <steppedValueSet variable="zed" first="0.5" step="0.5" last="10"/>
    <enumeratedValueSet variable="network-type">
      <value value="&quot;lattice&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="runs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recalcitrance">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="uncertainty">
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="distribution">
      <value value="&quot;custom-2&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="radius">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-links">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="edge-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="rewire-prob">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
