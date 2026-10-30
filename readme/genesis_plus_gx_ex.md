## Paprium

This core plays Paprium. The hmod does not include the game or its music.

- Keep the `.bin` next to a folder called `paprium` with the MP3 files.
- The first time, pick the language, play the Vaporware mini-game once and quit through RetroArch. That creates the save; until it exists the game only shows the mini-game.
- Launch it with `--save-data-backing-file`, with the save folder outside the game folder, or the console discards the save when the game closes.
- A `.wav` with the same name as an `.mp3` (PCM, 16 bit, stereo, 48 kHz) is read instead of the MP3, without decoding.

## Credits

Genesis Plus GX is by Charles MacDonald and Eke-Eke. The Paprium support comes from the Expanded ROM Size fork of RapidEdwin08 and BillyTimeGames, and this build adds the memory changes that make it fit on the console.
