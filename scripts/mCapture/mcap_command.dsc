###########################
# This file is part of mCap / Motion Capture.
# Refer to the header of "mcap_config.dsc" for more information.
##############

mcapture_cmd_data:
    type: data
    debug: false
    # Note: must not include the '.' symbol
    # (both for security reasons, and because that's the flag submapping key symbol)
    valid_chars: abcdefghijklmnopqrstuvwxyz0123456789_-/

mcapture_tab_1:
    type: procedure
    debug: false
    script:
    - define list <list>
    - foreach record|play as:key:
        - if <player.has_permission[mcapture.<[key]>]||true>:
            - define list:->:<[key]>
    - determine <[list]>

cmd_mcapture:
    type: command
    debug: false
    name: mcapture
    usage: /mcapture [record/play]
    description: mcapture
    permission: mcapture.help
    tab completions:
        1: <proc[mcapture_tab_1]>
    script:
    - if !<context.args.get[1].exists>:
        - narrate "<gold>List of valid subcommands:"
        - narrate "<gray>- record|stop"
        - narrate "<gray>- play"
        - stop
    - choose <context.args.get[1]>:
        - case record:
            - if <player.has_flag[motion_capture.is_recording]>:
                - run mcapture_stop
            - else:
                - run mcapture_record def.phase:<context.args.get[2]>
        - case play:
            - if !<context.args.get[2].exists>:
                - narrate "<red>Type in a recording filename to play!"
                - stop
            - if !<util.has_file[mcapture/<context.args.get[2]>.yml]>:
                - narrate "<red>File does not exist!"
                - stop
            - if !<context.args.get[3].exists>:
                - narrate "<red>Specify an NPC id to play the recording!"
                - stop
            - run mcapture_play def.file:<context.args.get[2]> def.npc:<context.args.get[3]>