mcapture_record:
    type: task
    definitions: phase
    debug: false
    script:
    - define list <list>
    - define id <server.flag[motion_capture.cuid]>
    - flag <player> motion_capture.is_recording:true
    - if <definition[phase].exists>:
        - if <[phase]> == 1:
            - run phase1_start
            - runlater mcapture_stop delay:420t
        - else if <[phase]> == 2:
            - run phase2_start
            - runlater mcapture_stop delay:960t
    - while <player.has_flag[motion_capture.is_recording]>:
        # actionbar
        - actionbar "<gold>Recording... <gray>Duration: <gold><[loop_index].div[20].round_to_precision[0.1]>s" targets:<player>
        # record list
        - define list:->:<player.location>
        # record actions
        - if <player.has_flag[motion_capture.action.swing_arm]>:
            - define actlist:->:[action=swing_arm;tick=<[loop_index]>]
            - flag <player> motion_capture.action.swing_arm:!
        # if player
        - wait 1t
    - narrate "<gray>[<gold>Motion Capture<gray>] <green>Recording Done!"
    - yaml create id:mcr<[id]>
    - foreach <[list]> as:loc:
        - yaml id:mcr<[id]> set locations:->:<[loc]>
    - foreach <[actlist]> as:action:
        - yaml id:mcr<[id]> set actions:->:<[action]>
    - ~yaml savefile:mcapture/mcr<[id]>.yml id:mcr<[id]>
    - yaml unload id:mcr<[id]>
    - narrate "<gray>[<gold>Motion Capture<gray>] <green>Recording Saved!"

mcapture_stop:
    type: task
    debug: false
    script:
    - flag server motion_capture.cuid:++
    - flag <player> motion_capture.is_recording:!

mcapture_play:
    type: task
    definitions: file|npc
    debug: false
    script:
    - ~yaml load:mcapture/<[file]>.yml id:<[file]>
    - foreach <yaml[<[file]>].read[actions]> as:action:
        - define map <[action].parsed.as[map]>
        - run mcapture_play_action delay:<[map].get[tick]>t def.action:<[map].get[action]> def.npc:<[npc]>
    - foreach <yaml[<[file]>].read[locations].parsed> as:loc:
       - teleport <npc[<[npc]>]> <[loc]>
       - wait 1t
    - narrate "<gray>[<gold>Motion Capture<gray>] <green><[file]> playback finished!"

mcapture_guide:
    type: task
    definitions: file|e
    debug: false
    script:
    - ~yaml load:mcapture/<[file]>.yml id:<[file]>
    - foreach <yaml[<[file]>].read[locations].parsed> as:loc:
       - playeffect effect:spell_mob at:<[loc]> quantity:1 offset:0,0,0 visibility:256 velocity:0.38,1,0.38 targets:<[e]>
       - playeffect effect:redstone at:<[loc]> quantity:1 special_data:2.8|<&color[#76ff21]> offset:0,0,0 visibility:256 targets:<[e]>
       - wait 1t
    - narrate "<gray>[<gold>Motion Capture<gray>] <green><[file]> playback guide finished!"

mcapture_play_action:
    type: task
    definitions: action|npc
    debug: false
    script:
    - if <[action]> == swing_arm:
        - animate <[npc]> animation:ARM_SWING
        - if <[npc].id> == 1:
            - define e <npc[1]>
            - shoot SNOWBALL origin:<[e].location.above[1.4].forward[0.6]> speed:1.5 no_rotate save:p
            - define follow <entry[p].shot_entity>
            - adjust <[follow]> hide_from_players
            - run phase2_suluntulu_fx def.e:<entry[p].shot_entity>
        - if <[npc].id> == 2:
            - ratelimit <npc[2]> 20t
            - define e <npc[2]>
            - playeffect effect:enchantment_table at:<[e].location.above[1]> visibility:256 quantity:48 data:7 offset:0,0,0
            - animate <[e]> animation:CRIT
            - wait 6t
            - animate <[e]> animation:CRIT
            - wait 6t
            - animate <[e]> animation:CRIT
            - wait 8t
            - playeffect effect:flash at:<[e].location.above[0.13]> quantity:1 offset:0,0,0 visibility:256
            - playeffect effect:crit at:<[e].location.above[1.1]> quantity:24 data:1.13 offset:0.28,0,0.28 visibility:256
            - foreach <[e].location.above[1].points_around_y[radius=0.1;points=16]> as:point:
                - define v <[e].location.above[1.02].sub[<[point]>]>
                - playeffect effect:smoke_normal at:<[point]> visibility:256 quantity:3 offset:0,0,0 velocity:<[v].mul[-1].mul[3.0]>
        - if <[npc].id> == 3:
            - define e <npc[4]>
            - define points <[e].location.forward[0.6].above[1.0].right[0.3].points_between[<[e].location.forward[0.6].above[1.6].ray_trace[range=16;return=precise;entities=*;ignore=<[e]>;nonsolids=true].if_null[<[e].location.forward[16.6].above[1.6]>]>]>
            - define witherhit <[e].eye_location.ray_trace[default=air;range=16;ignore=<[e]>]||null>
            - playeffect effect:flash at:<[witherhit]> quantity:1 offset:0,0,0 visibility:256
            - playeffect effect:crit at:<[witherhit]> quantity:11 data:1.1 offset:0,0,0 visibility:256
            - playeffect effect:cloud at:<[witherhit]> quantity:4 data:0.07 offset:0,0,0 visibility:256
            - playeffect effect:wax_off at:<[witherhit]> quantity:7 offset:0,0,0 visibility:256 data:28.6
            - playeffect effect:fireworks_spark at:<[points]> quantity:1 offset:0,0,0 visibility:256 data:0.01
            - playeffect effect:wax_off at:<[points]> quantity:1 offset:0,0,0 visibility:256 data:3.4
        - if <[npc].id> == 4:
            - define e <npc[4]>
            - define el <[e].location.above[1.4].forward[0.66]>
            - shoot arrow origin:<[el]> speed:1.8 save:arrow0
            - shoot arrow origin:<[el].with_yaw[<[el].yaw.add[7]>]> speed:1.8 save:arrow1
            - shoot arrow origin:<[el].with_yaw[<[el].yaw.add[-7]>]> speed:1.8 save:arrow2
            - flag <entry[arrow0].shot_entity> arrow
            - flag <entry[arrow1].shot_entity> arrow
            - flag <entry[arrow2].shot_entity> arrow
            - run phase2_5a7_fx def.e:<entry[arrow0].shot_entity>
            - run phase2_5a7_fx def.e:<entry[arrow1].shot_entity>
            - run phase2_5a7_fx def.e:<entry[arrow2].shot_entity>
            - if <npc[4].flag[salvation]> == 2:
                - flag <npc[4]> salvation:0
                - define rt <[el].ray_trace[default=air;fluids=true;nonsolids=true;range=32]>
                - playeffect effect:redstone at:<[el].points_between[<[rt]>].distance[0.5]> quantity:1 special_data:1.2|<&color[#ff0000]> offset:0.05,0.05,0.05 visibility:256
                - playeffect effect:drip_lava at:<[el].points_between[<[rt]>].distance[0.5]> quantity:1 offset:0.05,0.05,0.05 visibility:256
                - playeffect effect:smoke_large at:<[el].points_between[<[rt]>].distance[1.8]> quantity:1 offset:0.13,0.13,0.13 visibility:256
                - playeffect effect:electric_spark at:<[el].points_between[<[rt]>].distance[2.5]> quantity:1 offset:0.13,0.13,0.13 visibility:256
                - wait 1t
                - playeffect effect:electric_spark at:<[el].points_between[<[rt]>].distance[5]> quantity:1 offset:0.25,0.25,0.25 visibility:256
            - else:
                - flag <npc[4]> salvation:++

mcapture_events:
    type: world
    debug: false
    events:
        on player left clicks block:
        - if <player.has_flag[motion_capture.is_recording]>:
            - ratelimit <player> 1t
            - flag <player> motion_capture.action.swing_arm:true