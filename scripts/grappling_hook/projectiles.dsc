vanilla_overrides_projectile:
    type: world
    debug: false
    events:
        on projectile hits priority:10:
        - if <context.hit_entity.exists>:
            - determine cancelled
        - if <context.hit_block.exists>:
            - remove <context.projectile>
        player picks up launched arrow:
        - determine cancelled passively
        - remove <context.arrow>