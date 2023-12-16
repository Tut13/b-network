ping_command:
  type: command
  name: ping
  debug: false
  description: Shows yours or another player's ping
  usage: /ping (player)
  tab completions:
    1: <server.online_players.exclude[<player>].parse[name]>
  script:
  # % ██ [ check if player is typing too much    ] ██
    - if <context.args.size> > 1:
      - inject command_syntax_error

  # % ██ [ check if typing another player or not ] ██
    - if <context.args.is_empty>:
      - narrate "<&a>Your ping is <&e><player.ping><&6>ms"

    - else:
      - define player_name <context.args.first>
      - inject command_online_player_verification
      - narrate "<&e><[player_name]><&a><&sq>s ping is <&e><[player].ping><&6>ms"
