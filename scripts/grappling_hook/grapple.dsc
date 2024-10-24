grappling_hook:
    type: item
    material: breeze_rod
    mechanisms:
      unbreakable: true
      hides: ALL
    display name: <aqua>Grappling Hook
    lore:
    - <gray>A Grappling Hook.
    flags:
      id: grappling_hook
      uuid: <util.random_uuid>

double_hook:
    type: item
    material: breeze_rod
    mechanisms:
      unbreakable: true
      hides: ALL
    display name: <aqua>Double Hook
    lore:
    - <gray>A Grappling Hook that has <green>2 <gray>Hooks!
    flags:
      id: double_hook
      uuid: <util.random_uuid>

double_grapple_events:
    type: world
    debug: false
    events:
        on player right clicks block:
        - if !<player.item_in_hand.has_flag[id]>:
            - stop
        - if <player.item_in_hand.flag[id]> != double_hook:
            - stop
        - ratelimit <player> 1t
        # projectile
        - playsound <player> sound:item_crossbow_shoot volume:1.0 pitch:1.8
        - shoot arrow[pickup_status=DISALLOWED] origin:<player.location.above[1.5].forward[0.43]> speed:5.5 save:proj
        - define proj <entry[proj].shot_entity>
        # - adjust <[proj]> hide_from_players
        - flag <[proj]> shooter:<player>
        - flag <[proj]> id:projectile_doublehook_right
        - run grapple_proj_tick def.proj:<[proj]>
        on player left clicks block:
        - if !<player.item_in_hand.has_flag[id]>:
            - stop
        - if <player.item_in_hand.flag[id]> != double_hook:
            - stop
        - ratelimit <player> 1t
        # projectile
        - playsound <player> sound:item_crossbow_shoot volume:1.0 pitch:1.8
        - shoot arrow[pickup_status=DISALLOWED] origin:<player.location.above[1.5].forward[0.4]> speed:5.5 save:proj
        - define proj <entry[proj].shot_entity>
        # - adjust <[proj]> hide_from_players
        - flag <[proj]> shooter:<player>
        - flag <[proj]> id:projectile_doublehook_left
        - run grapple_proj_tick def.proj:<[proj]>
        on player swaps items:
        - if !<player.item_in_hand.has_flag[id]>:
            - stop
        - determine cancelled passively
        - flag <player> item.doublehook.right:!
        - flag <player> item.doublehook.left:!
        on entity unleashed:
        - determine cancelled passively
        on projectile hits:
        - if !<context.projectile.has_flag[id]>:
            - stop
        - if <context.projectile.has_flag[shooter]>:
            - define player <context.projectile.flag[shooter]>
        - choose <context.projectile.flag[id]>:
            - case projectile_doublehook_right:
                - define uuid <util.random_uuid>
                - flag <[player]> item.doublehook.right.uuid:<[uuid]>
                - flag <[player]> item.doublehook.right.loc:<context.hit_block.center>
                - run doublehook_hooked def.uuid:<[uuid]> def.hook:right def.player:<[player]>
                - run doublehook_pull def.uuid:<[uuid]> def.hook:right def.player:<[player]>
            - case projectile_doublehook_left:
                - define uuid <util.random_uuid>
                - flag <[player]> item.doublehook.left.uuid:<[uuid]>
                - flag <[player]> item.doublehook.left.loc:<context.hit_block.center>
                - run doublehook_hooked def.uuid:<[uuid]> def.hook:left def.player:<[player]>
                - run doublehook_pull def.uuid:<[uuid]> def.hook:left def.player:<[player]>
grapple_proj_tick:
    type: task
    debug: false
    definitions: proj
    script:
    - while <[proj].is_spawned>:
        - if <[proj].location.distance[<[proj].flag[shooter].location>]> > 64:
            - remove <[proj]>
            - while stop
        - playeffect at:<[proj].location> effect:crit offset:0.0,0.0,0.0 visibility:768
        - wait 1t

doublehook_hooked:
    type: task
    debug: false
    definitions: player|hook|uuid
    script:
    - define hl <[player].flag[item.doublehook.<[hook]>.loc]>
    - spawn silverfish[has_ai=false;gravity=false;silent=true;invulnerable=true] <[hl]> save:leashentity
    - cast invisibility <entry[leashentity].spawned_entity> duration:infinite hide_particles no_ambient
    - leash <entry[leashentity].spawned_entity> holder:<[player]>
    - while <[player].flag[item.doublehook.<[hook]>.uuid].if_null[false]> == <[uuid]>:
        - if <[hook]> == left:
            - define pl <[player].location.above[0.83].left[0.24]>
        - else:
            - define pl <[player].location.above[0.83].right[0.24]>
        - define v <[hl].sub[<[pl]>].mul[0.014].mul[-1]>
        - playeffect at:<[pl].points_between[<[hl]>].distance[0.4]> effect:crit offset:0,0,0 velocity:<[v]>
        - wait 4t
    - remove <entry[leashentity].spawned_entity>

doublehook_pull:
    type: task
    debug: false
    definitions: hook|uuid|player
    script:
    - if !<[player].has_flag[item.doublehook.pull]>:
        - flag <player> item.doublehook.pull:<queue>
    - else if <[player].flag[item.doublehook.pull]> != <queue>:
        - queue stop <[player].flag[item.doublehook.pull]>
        - flag <[player]> item.doublehook.pull:<queue>
    # if hook is still the same one.
    - while <[player].flag[item.doublehook.<[hook]>.uuid].if_null[false]> == <[uuid]>:
        - define loc <[player].location>
        - define sneak <location[0,0,0]>
        - define yred <location[0,0,0]>
        - if <[player].has_flag[item.doublehook.right]> && <[player].has_flag[item.doublehook.left]>:
            - define rloc <[player].flag[item.doublehook.right.loc]>
            - define lloc <[player].flag[item.doublehook.left.loc]>
            - if <[player].is_sneaking>:
                - playsound <[player]> sound:item_firecharge_use volume:0.02 pitch:0.878 sound_category:MASTER
                - playeffect at:<[player].location.above[0.22]> effect:cloud quantity:3 offset:0.18,0.1,0.18 data:0.05
                - playeffect at:<[player].location.above[0.22]> effect:cloud quantity:8 offset:0.18,0.1,0.18 data:0.16
                - define sneak <[player].location.forward[1].above[0.18].sub[<[loc]>].mul[0.11]>
                - definemap map:
                    GENERIC_GRAVITY: 0.018
                - adjust <[player]> attribute_base_values:<[map]>
            - define dist <[rloc].distance[<[loc]>].add[<[lloc].distance[<[loc]>]>].power[-1].mul[0.4]>
            - define v <[rloc].sub[<[loc]>].add[<[lloc].sub[<[loc]>]>].mul[<[dist]>].mul[0.28]>
            - if <[rloc].y> > <[loc].y> || <[lloc].y> > <[loc].y>:
                - define yred <[v].with_y[<[v].y.mul[0.08]>]>
            - adjust <[player]> velocity:<[player].velocity.add[<[v]>].add[<[sneak]>].add[<[yred]>]>
            - wait 1t
            - while next
        - else:
            - define hloc <[player].flag[item.doublehook.<[hook]>.loc]>
            - if <[player].is_sneaking>:
                - playsound <[player]> sound:item_firecharge_use volume:0.02 pitch:0.878 sound_category:MASTER
                - playeffect at:<[player].location.above[0.22]> effect:cloud quantity:3 offset:0.18,0.1,0.18 data:0.05
                - playeffect at:<[player].location.above[0.22]> effect:cloud quantity:8 offset:0.18,0.1,0.18 data:0.16
                - define sneak <[player].location.forward[1].above[0.18].sub[<[loc]>].mul[0.11]>
                - definemap map:
                    GENERIC_GRAVITY: 0.018
                - adjust <[player]> attribute_base_values:<[map]>
            - define dist <[hloc].distance[<[loc]>].power[-1].mul[0.4]>
            - define v <[hloc].sub[<[loc]>].mul[<[dist]>].mul[0.28]>
            - if <[hloc].y> > <[loc].y>:
                - define yred <[v].with_y[<[v].y.mul[0.08]>]>
            - adjust <[player]> velocity:<[player].velocity.add[<[v]>].add[<[sneak]>].add[<[yred]>]>
            - wait 1t
            - while next
    - definemap map:
        GENERIC_GRAVITY: 0.068
    - adjust <[player]> attribute_base_values:<[map]>