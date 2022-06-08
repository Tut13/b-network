fishing_spawn:
  type: world
  debug: false
  events:
    on player enters no_swim_zone:
      - stop if:<context.to.advanced_matches[!water]>
      - if <player.is_inside_vehicle>:
        - wait 1s
      - title title:<black><&font[fade:white]><&chr[0004]><&chr[F801].font[utility:spacing]><&chr[0004]> fade_in:5t stay:0s fade_out:1s
      - wait 5t
      - teleport <server.flag[behr.spawn.no_swim_zone_respawns].sort_by_number[distance[<player.location>]].first>
      - playsound <player> sound:BLOCK_BEACON_ACTIVATE

    on *boat enters no_swim_zone:
      - wait 1s
      - playeffect effect:EXPLOSION_large at:<context.entity.location> offset:1 quantity:3
      - playeffect effect:lava at:<context.entity.location.above[0.2]> offset:1 quantity:6
      - playsound sound:ENTITY_DRAGON_FIREBALL_EXPLODE <context.entity.location> volume:2
      - playsound sound:ENTITY_GENERIC_EXTINGUISH_FIRE <context.entity.location> pitch:1 volume:0.2
      - remove <context.entity>

    on player enters fishing_area_spawnable:
      - flag server behr.playing_fish.players:->:<player>
      - if !<server.has_flag[behr.playing_fish.fish]>:
        - run its_fishing_time

    on player exits fishing_area_spawnable:
      - flag server behr.playing_fish.players:<-:<player>
      #- if !<server.has_flag[behr.playing_fish.players]> || <server.flag[behr.playing_fish.players].is_empty>:
      - remove <server.flag[behr.playing_fish.fish].filter[is_truthy]>
      - flag server behr.playing_fish.fish:!

    on player enters fishing_area:
      - repeat 2:
        - actionbar "<&f>🐠 <&color[#000001]>Fishing Area <&f>🦀"
        - wait 2s

    #on player fishes:
    #  - narrate <context.state>

    on player fishes while fishing:
      - define timeout <util.time_now.add[4s]>
      - flag player hook_maybe:<context.hook.if_null[invalid]>
      - flag player left_hook_delay expire:1t
      #! attachments
      #!- spawn light_that_boy_up <context.hook.location> if:<context.hook.is_truthy> save:light
      #!- attach <entry[light].spawned_entity> to:<context.hook> if:<context.hook.is_truthy>
      - waituntil <util.time_now.is_after[<[timeout]>]> || !<context.hook.is_truthy> || <context.hook.fish_hook_state.advanced_matches[HOOKED_ENTITY|BOBBING]>
      - stop if:!<context.hook.is_truthy>
      - if <context.hook.fish_hook_state> == hooked_entity && <context.hook.fish_hook_hooked_entity.script.name.if_null[invalid]> == spawn_fish:
        - narrate catch!
        - flag player hook_maybe:!
        - wait 2s
        - remove <context.hook> if:<context.hook.is_truthy>
      - else:
        - repeat 5:
          - if <player.has_flag[left_hook_delay]>:
            - wait 1s
          - stop if:!<context.hook.is_truthy>
          - if !<context.hook.location.find_entities[spawn_fish].within[0.5].is_empty>:
            - narrate catch!
            - flag player hook_maybe:!
            - wait 2s
            - remove <context.hook> if:<context.hook.is_truthy>
            - repeat stop
          - wait 5t
      #!- remove <entry[light].spawned_entity>

    on player fishes spawn_fish while caught_entity:
      - determine passively cancelled
      - remove <context.hook>

    on player clicks block with:fishing_rod flagged:!left_hook_delay:
      - stop if:<context.click_type.contains_text[right]>
      - flag player left_hook_delay expire:2s
      - define hook <player.flag[hook_maybe].if_null[null]>
      - if <[hook].is_truthy>:
        - playsound <player.location> sound:ENTITY_FISHING_BOBBER_THROW pitch:0 volume:0.2
        - adjust <[hook]> velocity:<[hook].velocity.add[<player.location.forward[0.5].up[0.5].sub[<player.location>]>]>

#fishing_spawn_debug:
#  type: world
#  debug: true
#  events:

move_fish:
  type: task
  script:
  - define fish <server.flag[behr.playing_fish.fish]>
  - define location <cuboid[fishing_area_fish_spawn].blocks.random>
  - define rate 10

  - repeat <[rate]>:
  # percent is 0 -1, eases from location a to location b, with a type (sine, quad, cubic, quart, quint, exp, circ, back, elastic, bounce) and a direction (in, out, inout)
      - define loc1 <[fish].location>
      - define loc2 <proc[lib_ease_location].context[<[value].div[<[rate]>]>|<[fish].location.above>|<[location].above>|quad|inout]>
      - define vector <[loc2].sub[<[loc1]>].normalize.mul[0.5].with_y[0]>
      - playeffect at:<[loc1].above[0.5]> effect:bubble offset:0.3,0,0.3 quantity:5 visibility:100
      - playeffect at:<[loc1].above[0.3]> effect:WATER_SPLASH offset:0.4,0,0.4 quantity:15 visibility:100
      - adjust <[fish]> velocity:<[vector]>
      #- teleport <[fish]> <proc[lib_ease_location].context[<[value].div[<[rate]>]>|<[fish].location>|<[location]>|quad|in]>
      #- playeffect effect:redstone at:<proc[lib_ease_location].context[<[value].div[<[rate]>]>|<[fish].location.above>|<[location].above>|quad|inout]> offset:0 special_data:4|<color[red].with_hue[<element[255].div[<[value].div[<[rate]>]>].round_down>]> visibility:100
      - wait 2t

its_fishing_time:
  type: task
  debug: false
  definitions: fish
  sub_scripts:
    move_fish:
      - define rate 10
      - while <server.has_flag[behr.playing_fish.fish]> && <[fish].is_truthy>:
        - define location <cuboid[fishing_area_fish_spawn].blocks.random>
        - playsound at:<[fish].location> sound:ENTITY_BOAT_PADDLE_WATER volume:2
        - repeat <[rate]>:
          - stop if:!<[fish].is_truthy>
          - define loc1 <[fish].location>
          - define loc2 <proc[lib_ease_location].context[<[value].div[<[rate]>]>|<[fish].location.above>|<[location].above>|quad|inout]>
          - define vector <[loc2].sub[<[loc1]>].normalize.mul[0.5].with_y[0]>
          - playeffect at:<[loc1].above[0.5]> effect:bubble offset:0.3,0,0.3 quantity:5 visibility:100
          - playeffect at:<[loc1].above[0.3]> effect:WATER_SPLASH offset:0.4,0,0.4 quantity:15 visibility:100
          - adjust <[fish]> velocity:<[vector]>
          - wait 2t
        - wait <util.random.int[80].to[500]>t
      - remove <[fish]> if:<[fish].is_truthy>
        #- wait 3s

    playeffect:
      - while <server.has_flag[behr.playing_fish.fish]> && <[fish].is_truthy>:
        - playeffect at:<[fish].location.above[0.25]> effect:bubble offset:0.4,0,0.4 quantity:15 visibility:100
        - playeffect at:<[fish].location.above[0.3]> effect:WATER_SPLASH offset:0.4,0,0.4 quantity:5 visibility:100
        - wait 1t

  script:
    - if !<server.has_flag[behr.playing_fish.fish]> || !<server.flag[behr.playing_fish.fish].is_truthy>:
      - repeat 3:
        - spawn spawn_fish <cuboid[fishing_area_fish_spawn].blocks.random> save:fish
        - flag server behr.playing_fish.fish:->:<entry[fish].spawned_entity>

    - define fishies <server.flag[behr.playing_fish.fish]>
    - wait 2s
    - foreach <[fishies]> as:fish:
      - run its_fishing_time.sub_scripts.playeffect def:<[fish]>
      - run its_fishing_time.sub_scripts.move_fish def:<[fish]>


spawn_fish:
  type: entity
  debug: false
  entity_type: vex
  mechanisms:
    is_aware: false
    equipment: air|air|air|stick[custom_model_data=3000]
    item_in_hand: torch
    invulnerable: true
    silent: true
    potion_effects:
      type: INVISIBILITY
      aplifier: 1
      duration: 9999h
      ambient: true
      particles: false

light_that_boy_up:
  type: entity
  entity_type: armor_stand
  mechanisms:
    item_in_hand: torch
    marker: true
    is_small: true
    visible: false

# | <[target]> is the playertag/npctag to change the skin of
# |            (npctag only if it's a valid player's name)
# | <[default_name]> is the default skin to use if the APIs fail to generate a new skin
# |            (this is saved in the default_skins data script below)
# | run skin_change_task def:<[target]>|<[default_name]>
skin_change_task:
    type: task
    definitions: target|default_name
    script:
      - if <server.has_flag[behr.saved_skins.<[target].name>]>:
        - adjust <[target]> skin_blob:<server.flag[behr.saved_skins.<[target].name>]>
        - stop

      - define combine_api_url https://image-merger.herokuapp.com/api/v1.0/merge-images/
      - define mineskin_api_url https://api.mineskin.org/generate/url
      - definemap data:
          foreground_url: <script[default_skins].parsed_key[defaults.<[default_name]>.overlay_url]>
          background_url: https://minotar.net/skin/<[target].name>.png
      - definemap headers:
          Content-Type: application/json
          User-Agent: B

      - repeat 1:
        - ~webget <[combine_api_url]> data:<[data].to_json> headers:<[headers]> save:response
        - if <entry[response].failed>:
          - wait 3s
          - repeat next

        - definemap data:
            url: <util.parse_yaml[<entry[response].result>].deep_get[output_image.url]>

        - ~webget <[mineskin_api_url]> method:POST data:<[data].to_json> headers:<[headers]> timeout:5s save:response
        - if !<entry[response].failed>:
          - define skin_blob <util.parse_yaml[<entry[response].result>].deep_get[data.texture.value]>;<util.parse_yaml[<entry[response].result>].deep_get[data.texture.signature]>
          - flag server behr.saved_skins.<[target].name>.<[default_name]>:<[skin_blob]>  expire:30d
        - else:
          - wait 3s
          - repeat next


      - define skin_blob <script[default_skins].parsed_key[defaults.<[default_name]>.skin_blob]> if:!<[skin_blob].exists>
      - adjust <[target]> skin_blob:<[skin_blob]>

default_skins:
  type: data
  defaults:
    Pescetarian_Puffman:
      overlay_url: https://cdn.discordapp.com/attachments/980166207426670633/984184991128891492/puffer_overlay.png
      skin_blob: ewogICJ0aW1lc3RhbXAiIDogMTY1NDcxOTI4NDA2MiwKICAicHJvZmlsZUlkIiA6ICIxNmFkYTc5YjFjMDk0MjllOWEyOGQ5MjgwZDNjNjE5ZiIsCiAgInByb2ZpbGVOYW1lIiA6ICJMYXp1bGl0ZV9adG9uZSIsCiAgInNpZ25hdHVyZVJlcXVpcmVkIiA6IHRydWUsCiAgInRleHR1cmVzIiA6IHsKICAgICJTS0lOIiA6IHsKICAgICAgInVybCIgOiAiaHR0cDovL3RleHR1cmVzLm1pbmVjcmFmdC5uZXQvdGV4dHVyZS9hNTNjMTA2Mjc0ZTY4NWY3ZjUwMzU5MzNkYzhhNDMwM2IyZjhhYjNlYjFhYzY4YjcyNTEwNjA0ZjM4Mzg0ZjVkIgogICAgfQogIH0KfQ==;Bzw2pn0Xeq04thd5FUbe5UT4YYRbtbcAerPEjW/kfDECOV+wyB2VqyR3vYdIHz3Jz9PoM9LeqFc4fywQFWemC+vyXU273wO2+bUp8jmF6DYiQxpNH365Ln6dtnkYR0th1/WYINkLVUTZLwzy5QzSfRYQ08bi7C5PN2BUw14t+ulJmwtGbU4vSEJbRYm6x9HKQqoRA1VHD2W/BcLahcuERhYDrjBqlrJXMqx0gcPDk9h3gs46N/ERRY5Rok7YX+TcP4cZ4J2f9wc8MWO9Efsmev5UL9teBj7Y4r0suDjhyUr3suE4Yl9umXE3c/Rk7o/LmRd8oaE1a4tkdrJ1ec63/p0M1jh0JnAyGMfnH4+/2XQ8oAXvu6xngYBmtQw90eRLJnbsK/ABYH+nCnUnxsJAL+/wYgwdMClnH9mko7h7wiVLejtYgzNlCysVfb8qBv6f82yRAHRKbKPxJrsEyhOfWi6ow8mSHAD6N7nBxXHbj1zF1Y83AiKZ3moGJ6ZOs6VBDOcXqOkCeNuZEyANRNSRdyrrSkFgen0j/WSUHI3ta2lQ+RfXkgZ87FSED7HErgcPxAh06zUXJgkO0eJP8I7Bzu/mfKFJoLhghGqrcd5G7x+uXGnV3nzPllCt6C1D3r/6gwKatYs93xN2lvRsvokeTp/4KFz0xcxHc0gSnivbxwU=
