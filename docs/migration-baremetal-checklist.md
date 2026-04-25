# Migration checklist: WSL lab → bare-metal Kinoite

- [ ] Export **Flatpak** list: `flatpak list --app --columns=application`
- [ ] Save **SSH keys** and **GPG** stubs (not private material in cloud).
- [ ] Document **`rpm-ostree` layers** you actually used on real ostree (not applicable if `rpm-ostree` never worked in WSL).
- [ ] Re-create **Podman** volumes / quadlets from compose files kept in this workspace.
- [ ] Verify **firmware** updates (`fwupd`) on the laptop/desktop before go-live.
