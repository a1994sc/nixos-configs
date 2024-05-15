let
  machines = {
    puck = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAZaQwDJxTMR4S6yQjuqoDj2c8r6e588kW1wcm0zquRM"
      "age1zsuk65xk39mdnewvm4z8mhp5r9ry36lfuafvp4d460a9vezpduxsnhwa75"
    ];
    dns1 = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHrskuv6/PHpm8CZuGhM0OKero9Gg0PAfmaoY7PmkWM"
      "age12ys8lgxx32m8a4qzhh9e0uqzcyheetanny28x9zvfr27khz47f7s0q7a9f"
    ];
    dns2 = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfGgBA82odhRNiKrflxSbyNgwDMcnf0ckbRcpQZHUfo"
      "age1q5urgt9hszq2j9p2qtprl853w6gcy9wapzt73r73xmjla4zhq98scpl8rm"
    ];
  };

  system.allen = [
    "age1yubikey1q20jh97qrk9kspzfmh4hrs8qgvuq34lvhm2pum9dae7p97gq78tsghyyha3"
    "age1yubikey1qf42tcrzealy89zpmat6c9fzza9pgt8f3nwl42pvj7sk7lllf623vmjq30d"
    "age1yubikey1q0kv8am08zj3pdakl8407xd8j0qxxytzwqx09vrtk64dsw2r5qragk5kd4f"
  ];

  secrets = {
    hello-world = machines.puck ++ machines.dns1;
  };
in
builtins.listToAttrs (
  map
    (secretName: {
      name = "encrypt/${secretName}.age";
      value.publicKeys = secrets."${secretName}" ++ system.allen;
    })
    (builtins.attrNames secrets)
)
