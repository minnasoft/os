# os

> Because you deserve a good os.

os is a NixOS framework/template defining tidy little systems.

Systems should be simple; as simple as this:

```nix
{
  os = {
    profile.workstation = true;
    tailscale = true;
    ephemeral = true;
  };
}
```

## Why os?

Omakase works. This is omakase for me.

I run on multiple machines and I'm dumb, so I want to think at as high a level as possible and not get bogged down in details.

I'd like to think I have decent taste too... os won't be a generic solution for everything, I'm not that smart, but it will be a good solution for anything the heck I want to do on a computer.

os is for machines/users that want:

- tiny host definitions
- plain NixOS modules so you're not locked into anything
- multiple machines that share a lot of configuration
- some leaky abstractions and patterns to make things easier
- your configs to be pretty

## TODO

- [ ] implement ci from the start
- [ ] bootstrap flake with minimal VM host
- [ ] define the public `os.*` option namespace
- [ ] add package accumulation
- [ ] add home manager
- [ ] add a host builder w/ auto-imports
- [ ] add recursive module auto-imports
- [ ] implement profiles
- [ ] add tailscale
- [ ] add ephemeral
- [ ] add docker
- [ ] add gaming
- [ ] add bluetooth
- [ ] add audio
- [ ] add power
- [ ] lowercase XDG directories incl projects
- [ ] zfs
- [ ] add hardware
- [ ] add proxy
- [ ] migrate iroha first

## License

MIT
