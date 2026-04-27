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

From the **Kinoite repo root**:

```powershell
.\scripts\Kinoite-Wiki.ps1 -Action GenerateDocs
.\scripts\Kinoite-Wiki.ps1 -Action Sync
```

## GitHub Wiki bootstrap

The wiki remote does not exist until **one page** is created on GitHub: open [the wiki](https://github.com/bolabaden/kinoite-daily-driver/wiki), click **Create the first page**, save, then run `git submodule update --init` from the main repo and `.\scripts\Kinoite-Wiki.ps1 -Action Sync`.
