# Wiki / Jekyll sources

This tree is copied into the **[GitHub wiki](https://github.com/bolabaden/kinoite-daily-driver/wiki)** git submodule at `wiki/` in the main repository.

## Local preview

```bash
cd wiki-source   # or wiki/ after submodule checkout
bundle install
bundle exec jekyll serve
```

Open `http://127.0.0.1:4000`.

## Regenerate mirrored docs from the main repo

From **wiki-source/** (or let the root `scripts/Sync-WikiSubmodule.ps1` run this for you):

```powershell
.\sync-docs-from-parent.ps1 -RepoRoot G:\path\to\Kinoite
```

## GitHub Wiki bootstrap

The wiki remote does not exist until **one page** is created on GitHub: open [the wiki](https://github.com/bolabaden/kinoite-daily-driver/wiki), click **Create the first page**, save, then run `git submodule update --init` from the main repo and `.\scripts\Sync-WikiSubmodule.ps1`.
