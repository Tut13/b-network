gamemode_command:
  type: command
  name: gamemode
  debug: false
  description: Adjusts your gamemode
  usage: /gamemode <&lt>adventure|builder|creative|survival|spectator<&gt>
  script:
  # % ██ [ check if using too many arguments       ] ██:
    - if <context.args.size> > 1:
      - narrate "<&c>Invalid usage"
      - stop

  # % ██ [ check if opening the gui                ] ██:
    - if <context.args.is_empty>:
      - define items <list>
      - foreach adventure|builder|creative|survival|spectator as:gamemode:
        - define item <item[gamemode_button].with[display=<&b><[gamemode].to_titlecase>].with_flag[gamemode:<[gamemode]>]>
        - if <player.has_flag[behr.essentials.permission.<[gamemode]>]>:
          - if <player.flag[behr.essentials.gamemode]> == <[gamemode]>:
            - define item <[item].with[material=lime_stained_glass]>
            - define item <[item].with[lore=<&a>Current gamemode]>
          - else:
            - define item <[item].with[material=white_stained_glass]>
            - define item <[item].with[lore=<&a><&a>Click to change to|<&a><[gamemode]> gamemode]>
        - else:
          - define item <[item].with[material=black_stained_glass]>
          - define item <[item].with[lore=<&c>Unavailable]>
        - define items <[items].include_single[<[item]>].include_single[air]>
        - define inventory <inventory[gamemode_main_menu]>
        - inventory set destination:<[inventory]> origin:<[items].remove[last]>
        - flag server behr.essentials.guis.gamemode.pregenerated:<[inventory]>
        - inventory open d:<server.flag[behr.essentials.guis.gamemode.pregenerated]>
        - playsound <player> entity_player_levelup pitch:<util.random.decimal[0.8].to[1.2]> volume:0.3 if:<player.has_flag[behr.essentials.settings.playsounds]>
      - stop

    - define gamemodes <list[adventure|builder|creative|survival|spectator]>
    - define current_gamemode <player.flag[behr.essentials.gamemode]>
    - define new_gamemode <context.args.first>

    - choose <[new_gamemode]>:
      - case adventure creative survival spectator:
        - if <player.has_flag[behr.essentials.permission.<[new_gamemode]>]>:
          - adjust <player> gamemode:<[new_gamemode]>
        - else:
          - narrate "<&c>That gamemode is unavailable"

      - case builder:
          - inject builder_gamemode_task

      - default:
        - narrate "<&c>Invalid usage - <&e>valid options are <[gamemodes].exclude[<[current_gamemode]>].filter_tag[<player.has_flag[behr.essentials.permission.<[filter_value]>]>]>"
        - stop

    - playsound <player> entity_player_levelup pitch:<util.random.decimal[0.8].to[1.2]> volume:0.3 if:<player.has_flag[behr.essentials.settings.playsounds]>
    - flag <player> behr.essentials.last_gamemode:<[current_gamemode]>
    - flag <player> behr.essentials.gamemode:<[new_gamemode]>
    - narrate "<&a>Changed gamemode to <[new_gamemode]>"

gamemode_menu_handler:
  type: world
  debug: false
  events:
    after player clicks gamemode_button in gamemode_main_menu:
      - define new_gamemode <context.item.flag[gamemode]>
      - define current_gamemode <player.flag[behr.essentials.gamemode]>
      - playsound <player> entity_player_levelup pitch:<util.random.decimal[0.8].to[1.2]> volume:0.3 if:<player.has_flag[behr.essentials.settings.playsounds]>

      - if <[current_gamemode]> == <[new_gamemode]>:
        - narrate "<&c>You're already in <[new_gamemode]>"
        - stop

      - if !<player.has_flag[behr.essentials.permission.<[new_gamemode]>]>:
        - narrate "<&c>That gamemode is unavailable"
        - stop

      - if <[new_gamemode]> == builder:
        - inject builder_gamemode_task

      - definemap slot_map:
          1: adventure
          3: builder
          5: creative
          7: survival
          9: spectator

      - inventory adjust destination:<context.inventory> slot:<context.slot> material:lime_stained_glass
      - inventory adjust destination:<context.inventory> slot:<context.slot> "lore:<&a>Current gamemode"
      - define old_slot <[slot_map].invert.get[<[current_gamemode]>]>
      - inventory adjust destination:<context.inventory> slot:<[old_slot]> material:white_stained_glass
      - inventory adjust destination:<context.inventory> slot:<[old_slot]> "lore:<&a>Click to change to|<&a><[slot_map.<context.slot>]> gamemode"

      - flag <player> behr.essentials.last_gamemode:<[current_gamemode]>
      - flag <player> behr.essentials.gamemode:<[new_gamemode]>
      - adjust <player> gamemode:<[new_gamemode]>
      - narrate "<&a>Changed gamemode to <[new_gamemode]>"

    after player joins flagged:!behr.essentials.gamemode:
      - flag player behr.essentials.gamemode:survival

gamemode_main_menu:
  type: inventory
  debug: false
  inventory: chest
  title: Select Gamemode
  size: 9
  gui: true
  definitions:
    x: air
  slots:
    - [] [x] [] [x] [] [x] [] [x] []

gamemode_button:
  type: item
  material: stone
  mechanisms:
    hides: all

gma_command:
  type: command
  name: gma
  debug: false
  description: Changes your gamemode to adventure
  usage: /gma
  script:
    - inject gamemode_alias_task

gmb_command:
  type: command
  name: gmb
  debug: false
  description: Changes your gamemode to builder
  usage: /gmb
  script:
    - inject gamemode_alias_task

gmc_command:
  type: command
  name: gmc
  debug: false
  description: Changes your gamemode to creative
  usage: /gmc
  script:
    - inject gamemode_alias_task

gms_command:
  type: command
  name: gms
  debug: false
  description: Changes your gamemode to survival
  usage: /gms
  script:
    - inject gamemode_alias_task

gmsp_command:
  type: command
  name: gmsp
  debug: false
  description: Changes your gamemode to spectator
  usage: /gmsp
  script:
    - inject gamemode_alias_task


gamemode_alias_task:
  type: task
  debug: false
  data:
    alias_map:
      gma: adventure
      gmb: builder
      gmc: creative
      gms: survival
      gmsp: spectator
  script:
  # % ██ [ check if using too many arguments       ] ██
    - if !<context.args.is_empty>:
      - narrate "<&c>Invalid usage"
      - stop

    - define new_gamemode <context.args.first>
    - define current_gamemode <player.flag[behr.essentials.gamemode]>
    - define gamemodes <script.data_key[data.alias_map].values>

    - if <[new_gamemode]> !in <[gamemodes]>:
        - narrate "<&c>Invalid usage - <&e>valid options are <[gamemodes].exclude[<[current_gamemode]>].filter_tag[<player.has_flag[behr.essentials.permission.<[filter_value]>]>]>"
        - stop

    - if <[current_gamemode]> == <[new_gamemode]>:
      - narrate "<&c>You're already in <[new_gamemode]>"
      - stop

    - if !<player.has_flag[behr.essentials.permission.<[new_gamemode]>]>:
      - narrate "<&c>That gamemode is unavailable"
      - stop

    - if <[new_gamemode]> == builder:
      - inject builder_gamemode_task

    - flag <player> behr.essentials.last_gamemode:<[current_gamemode]>
    - flag <player> behr.essentials.gamemode:<[new_gamemode]>
    - adjust <player> gamemode:<[new_gamemode]>
    - narrate "<&a>Changed gamemode to <[new_gamemode]>"

builder_gamemode_task:
  type: task
  script:
    - if !<player.has_flag[behr.essentials.permission.builder]>:
      - narrate "<&e>Nothing interesting happens"
      - stop

    - adjust <player> gamemode:survival
    - adjust <player> can_fly:true
    - adjust <player> flying:!<player.is_on_ground>
    - narrate "<&a>Changed gamemode to Builder"
    - stop
